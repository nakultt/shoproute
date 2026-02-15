import { Router, Response } from "express";
import { AuthenticatedRequest } from "../types";
import { authMiddleware } from "../middleware/auth";
import * as cartService from "../services/cartService";

const router = Router();

// All cart routes require authentication
router.use(authMiddleware);

// GET /api/cart - Get user's cart
router.get("/", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const data = await cartService.getCart(req.user!.id);
    res.json({
      success: true,
      data,
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

    try {
      const item = await cartService.addToCart(
        req.user!.id,
        product_id,
        store_id,
        quantity
      );
      res.status(201).json({
        success: true,
        data: item,
      });
    } catch (e: any) {
      return res.status(400).json({
        success: false,
        error: e.message,
      });
    }
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

      try {
        const item = await cartService.updateCartItem(
          req.user!.id,
          itemId,
          quantity
        );
        res.json({
          success: true,
          data: item,
        });
      } catch (e: any) {
        return res.status(400).json({
          success: false,
          error: e.message,
        });
      }
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

      try {
        await cartService.removeCartItem(req.user!.id, itemId);
        res.json({
          success: true,
          message: "Item removed from cart",
        });
      } catch (e: any) {
        return res.status(404).json({
          success: false,
          error: e.message,
        });
      }
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
    await cartService.clearCart(req.user!.id);
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
