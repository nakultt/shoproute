import { Router, Response } from "express";
import { query } from "../config/database";
import { AuthenticatedRequest } from "../types";
import { authMiddleware } from "../middleware/auth";

const router = Router();

// All cart routes require authentication
router.use(authMiddleware);

// GET /api/cart - Get user's cart
router.get("/", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const result = await query(
      `SELECT ci.*, 
              p.name as product_name, p.image_url as product_image,
              s.name as store_name, s.logo_url as store_logo,
              sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       JOIN stores s ON ci.store_id = s.id
       LEFT JOIN store_products sp ON ci.product_id = sp.product_id AND ci.store_id = sp.store_id
       WHERE ci.user_id = $1
       ORDER BY ci.added_at DESC`,
      [req.user!.id]
    );

    // Calculate totals
    let subtotal = 0;
    let savings = 0;

    result.rows.forEach((item) => {
      subtotal += item.price * item.quantity;
      if (item.compare_at_price) {
        savings += (item.compare_at_price - item.price) * item.quantity;
      }
    });

    res.json({
      success: true,
      data: {
        items: result.rows,
        item_count: result.rows.length,
        subtotal: subtotal.toFixed(2),
        savings: savings.toFixed(2),
      },
    });
  } catch (err) {
    console.error("Get cart error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch cart",
    });
  }
});

// POST /api/cart/add - Add item to cart
router.post("/add", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { product_id, store_id, quantity = 1 } = req.body;

    if (!product_id || !store_id) {
      return res.status(400).json({
        success: false,
        error: "Product ID and Store ID are required",
      });
    }

    // Check if product is available at this store
    const storeProduct = await query(
      `SELECT * FROM store_products WHERE product_id = $1 AND store_id = $2`,
      [product_id, store_id]
    );

    if (storeProduct.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Product not available at this store",
      });
    }

    if (
      !storeProduct.rows[0].is_available ||
      storeProduct.rows[0].stock_count < quantity
    ) {
      return res.status(400).json({
        success: false,
        error: "Insufficient stock",
      });
    }

    // Upsert cart item
    const result = await query(
      `INSERT INTO cart_items (user_id, product_id, store_id, quantity)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id, product_id, store_id)
       DO UPDATE SET quantity = cart_items.quantity + $4
       RETURNING *`,
      [req.user!.id, product_id, store_id, quantity]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error("Add to cart error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to add item to cart",
    });
  }
});

// PUT /api/cart/update/:itemId - Update cart item quantity
router.put(
  "/update/:itemId",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { itemId } = req.params;
      const { quantity } = req.body;

      if (!quantity || quantity < 1) {
        return res.status(400).json({
          success: false,
          error: "Quantity must be at least 1",
        });
      }

      // Check ownership
      const existing = await query(
        "SELECT * FROM cart_items WHERE id = $1 AND user_id = $2",
        [itemId, req.user!.id]
      );

      if (existing.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Cart item not found",
        });
      }

      // Check stock
      const storeProduct = await query(
        `SELECT stock_count FROM store_products 
       WHERE product_id = $1 AND store_id = $2`,
        [existing.rows[0].product_id, existing.rows[0].store_id]
      );

      if (storeProduct.rows[0].stock_count < quantity) {
        return res.status(400).json({
          success: false,
          error: "Insufficient stock",
        });
      }

      const result = await query(
        "UPDATE cart_items SET quantity = $1 WHERE id = $2 RETURNING *",
        [quantity, itemId]
      );

      res.json({
        success: true,
        data: result.rows[0],
      });
    } catch (err) {
      console.error("Update cart error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to update cart",
      });
    }
  }
);

// DELETE /api/cart/remove/:itemId - Remove item from cart
router.delete(
  "/remove/:itemId",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { itemId } = req.params;

      const result = await query(
        "DELETE FROM cart_items WHERE id = $1 AND user_id = $2 RETURNING *",
        [itemId, req.user!.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Cart item not found",
        });
      }

      res.json({
        success: true,
        message: "Item removed from cart",
      });
    } catch (err) {
      console.error("Remove from cart error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to remove item",
      });
    }
  }
);

// DELETE /api/cart/clear - Clear entire cart
router.delete("/clear", async (req: AuthenticatedRequest, res: Response) => {
  try {
    await query("DELETE FROM cart_items WHERE user_id = $1", [req.user!.id]);

    res.json({
      success: true,
      message: "Cart cleared",
    });
  } catch (err) {
    console.error("Clear cart error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to clear cart",
    });
  }
});

export default router;
