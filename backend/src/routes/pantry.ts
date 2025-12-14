import { Router, Response } from "express";
import { query } from "../config/database";
import { AuthenticatedRequest } from "../types";
import { authMiddleware } from "../middleware/auth";
import {
  getRecipeSuggestions,
  extractIngredients,
  generateSubstitutions,
} from "../services/foodRecommendationService";

const router = Router();

// All pantry routes require authentication
router.use(authMiddleware);

// GET /api/pantry - Get user's pantry items
router.get("/", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const {
      location,
      sort_by = "expiry_date",
      show_expired = "false",
    } = req.query;

    let queryText = `
      SELECT pi.*, p.name as product_name, p.image_url as product_image, p.category_id,
             c.name as category_name, c.icon as category_icon,
             CASE 
               WHEN pi.expiry_date IS NULL THEN NULL
               WHEN pi.expiry_date < CURRENT_DATE THEN 'expired'
               WHEN pi.expiry_date <= CURRENT_DATE + INTERVAL '3 days' THEN 'expiring_soon'
               ELSE 'fresh'
             END as freshness_status,
             pi.expiry_date - CURRENT_DATE as days_until_expiry
      FROM pantry_items pi
      LEFT JOIN products p ON pi.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE pi.user_id = $1
    `;

    const params: any[] = [req.user!.id];

    if (location) {
      params.push(location);
      queryText += ` AND pi.location = $${params.length}`;
    }

    if (show_expired !== "true") {
      queryText += ` AND (pi.expiry_date IS NULL OR pi.expiry_date >= CURRENT_DATE)`;
    }

    switch (sort_by) {
      case "expiry_date":
        queryText +=
          " ORDER BY pi.expiry_date ASC NULLS LAST, pi.created_at DESC";
        break;
      case "name":
        queryText += " ORDER BY COALESCE(p.name, pi.custom_name) ASC";
        break;
      case "quantity":
        queryText += " ORDER BY pi.quantity ASC";
        break;
      default:
        queryText += " ORDER BY pi.created_at DESC";
    }

    const result = await query(queryText, params);

    // Group by location
    const grouped = {
      pantry: result.rows.filter((r) => r.location === "pantry"),
      fridge: result.rows.filter((r) => r.location === "fridge"),
      freezer: result.rows.filter((r) => r.location === "freezer"),
    };

    // Get expiring soon count
    const expiringCount = result.rows.filter(
      (r) => r.freshness_status === "expiring_soon"
    ).length;

    // Get low stock count
    const lowStockCount = result.rows.filter((r) => r.is_low_stock).length;

    res.json({
      success: true,
      data: {
        items: result.rows,
        grouped,
        total_count: result.rows.length,
        expiring_soon_count: expiringCount,
        low_stock_count: lowStockCount,
      },
    });
  } catch (err) {
    console.error("Get pantry error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch pantry items",
    });
  }
});

// POST /api/pantry - Add item to pantry
router.post("/", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const {
      product_id,
      custom_name,
      quantity = 1,
      unit = "unit",
      purchase_date,
      expiry_date,
      location = "pantry",
      notes,
      low_stock_threshold = 1,
    } = req.body;

    if (!product_id && !custom_name) {
      return res.status(400).json({
        success: false,
        error: "Either product_id or custom_name is required",
      });
    }

    const result = await query(
      `INSERT INTO pantry_items 
       (user_id, product_id, custom_name, quantity, unit, purchase_date, expiry_date, location, notes, low_stock_threshold)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        req.user!.id,
        product_id || null,
        custom_name || null,
        quantity,
        unit,
        purchase_date || new Date(),
        expiry_date || null,
        location,
        notes || null,
        low_stock_threshold,
      ]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error("Add pantry item error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to add pantry item",
    });
  }
});

// PUT /api/pantry/:id - Update pantry item
router.put("/:id", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;
    const {
      quantity,
      unit,
      expiry_date,
      location,
      notes,
      opened_date,
      is_low_stock,
    } = req.body;

    // Verify ownership
    const existing = await query(
      "SELECT * FROM pantry_items WHERE id = $1 AND user_id = $2",
      [id, req.user!.id]
    );

    if (existing.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Pantry item not found",
      });
    }

    const result = await query(
      `UPDATE pantry_items 
       SET quantity = COALESCE($1, quantity),
           unit = COALESCE($2, unit),
           expiry_date = COALESCE($3, expiry_date),
           location = COALESCE($4, location),
           notes = COALESCE($5, notes),
           opened_date = COALESCE($6, opened_date),
           is_low_stock = COALESCE($7, quantity <= low_stock_threshold)
       WHERE id = $8 AND user_id = $9
       RETURNING *`,
      [
        quantity,
        unit,
        expiry_date,
        location,
        notes,
        opened_date,
        is_low_stock,
        id,
        req.user!.id,
      ]
    );

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error("Update pantry item error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to update pantry item",
    });
  }
});

// DELETE /api/pantry/:id - Remove item from pantry (mark as used)
router.delete("/:id", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      "DELETE FROM pantry_items WHERE id = $1 AND user_id = $2 RETURNING *",
      [id, req.user!.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Pantry item not found",
      });
    }

    res.json({
      success: true,
      message: "Item removed from pantry",
    });
  } catch (err) {
    console.error("Delete pantry item error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to remove pantry item",
    });
  }
});

// GET /api/pantry/expiring - Get items expiring soon
router.get("/expiring", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { days = "7" } = req.query;
    const daysNum = parseInt(days as string);

    const result = await query(
      `SELECT pi.*, p.name as product_name, p.image_url as product_image,
              pi.expiry_date - CURRENT_DATE as days_until_expiry
       FROM pantry_items pi
       LEFT JOIN products p ON pi.product_id = p.id
       WHERE pi.user_id = $1 
         AND pi.expiry_date IS NOT NULL
         AND pi.expiry_date <= CURRENT_DATE + INTERVAL '1 day' * $2
         AND pi.expiry_date >= CURRENT_DATE
       ORDER BY pi.expiry_date ASC`,
      [req.user!.id, daysNum]
    );

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (err) {
    console.error("Get expiring items error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch expiring items",
    });
  }
});

// GET /api/pantry/low-stock - Get low stock items
router.get("/low-stock", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const result = await query(
      `SELECT pi.*, p.name as product_name, p.image_url as product_image
       FROM pantry_items pi
       LEFT JOIN products p ON pi.product_id = p.id
       WHERE pi.user_id = $1 AND pi.is_low_stock = true
       ORDER BY pi.quantity ASC`,
      [req.user!.id]
    );

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (err) {
    console.error("Get low stock items error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch low stock items",
    });
  }
});

// POST /api/pantry/generate-shopping-list - Auto-generate shopping list from low stock
router.post(
  "/generate-shopping-list",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      // Get low stock and expired items
      const lowStockItems = await query(
        `SELECT pi.*, p.name as product_name, p.id as product_id
       FROM pantry_items pi
       LEFT JOIN products p ON pi.product_id = p.id
       WHERE pi.user_id = $1 
         AND (pi.is_low_stock = true OR pi.expiry_date < CURRENT_DATE)`,
        [req.user!.id]
      );

      if (lowStockItems.rows.length === 0) {
        return res.json({
          success: true,
          data: {
            items: [],
            message: "No items need restocking",
          },
        });
      }

      // Create a new shopping list
      const listResult = await query(
        `INSERT INTO shopping_lists (user_id, name)
       VALUES ($1, $2)
       RETURNING *`,
        [req.user!.id, `Auto-generated - ${new Date().toLocaleDateString()}`]
      );

      const listId = listResult.rows[0].id;

      // Add items to the list
      for (const item of lowStockItems.rows) {
        if (item.product_id) {
          await query(
            `INSERT INTO shopping_list_items (list_id, product_id, quantity, notes)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT DO NOTHING`,
            [
              listId,
              item.product_id,
              Math.ceil(item.low_stock_threshold - item.quantity + 1),
              item.expiry_date < new Date()
                ? "Expired - needs replacement"
                : "Low stock",
            ]
          );
        }
      }

      res.json({
        success: true,
        data: {
          list_id: listId,
          items_added: lowStockItems.rows.length,
          message: "Shopping list generated successfully",
        },
      });
    } catch (err) {
      console.error("Generate shopping list error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to generate shopping list",
      });
    }
  }
);

// GET /api/pantry/recipes - Get recipe suggestions based on pantry items
router.get("/recipes", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { use_expiring_first = "true" } = req.query;

    // Get user's pantry items
    const pantryItems = await query(
      `SELECT pi.*, p.name as product_name
       FROM pantry_items pi
       LEFT JOIN products p ON pi.product_id = p.id
       WHERE pi.user_id = $1 AND pi.quantity > 0
       ORDER BY ${
         use_expiring_first === "true"
           ? "pi.expiry_date ASC NULLS LAST"
           : "pi.created_at DESC"
       }`,
      [req.user!.id]
    );

    const ingredients = pantryItems.rows.map(
      (item) => item.product_name || item.custom_name
    );

    const recipes = await getRecipeSuggestions(ingredients);

    res.json({
      success: true,
      data: recipes,
    });
  } catch (err) {
    console.error("Get recipe suggestions error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to get recipe suggestions",
    });
  }
});

// POST /api/pantry/extract-ingredients - Extract ingredients from text/recipe
router.post(
  "/extract-ingredients",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { text } = req.body;

      if (!text) {
        return res.status(400).json({
          success: false,
          error: "Text is required",
        });
      }

      const ingredients = await extractIngredients(text);

      res.json({
        success: true,
        data: ingredients,
      });
    } catch (err) {
      console.error("Extract ingredients error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to extract ingredients",
      });
    }
  }
);

export default router;
