import { Router, Response } from "express";
import { query } from "../config/database";
import { AuthenticatedRequest } from "../types";
import { authMiddleware } from "../middleware/auth";

const router = Router();

// All user routes require authentication
router.use(authMiddleware);

// GET /api/user/profile
router.get("/profile", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const user = await query(
      `SELECT id, full_name, email, phone, date_of_birth, email_verified, profile_picture, created_at
       FROM users WHERE id = $1`,
      [req.user!.id]
    );

    if (user.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }

    res.json({
      success: true,
      data: user.rows[0],
    });
  } catch (err) {
    console.error("Get profile error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch profile",
    });
  }
});

// PUT /api/user/profile
router.put("/profile", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { full_name, phone, date_of_birth } = req.body;

    const result = await query(
      `UPDATE users 
       SET full_name = COALESCE($1, full_name),
           phone = COALESCE($2, phone),
           date_of_birth = COALESCE($3, date_of_birth)
       WHERE id = $4
       RETURNING id, full_name, email, phone, date_of_birth, email_verified, profile_picture`,
      [full_name, phone, date_of_birth, req.user!.id]
    );

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error("Update profile error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to update profile",
    });
  }
});

// GET /api/user/statistics
router.get("/statistics", async (req: AuthenticatedRequest, res: Response) => {
  try {
    // Get various statistics
    const [favorites, reviews, lists] = await Promise.all([
      query(
        `SELECT 
           COUNT(*) FILTER (WHERE item_type = 'product') as saved_products,
           COUNT(*) FILTER (WHERE item_type = 'store') as saved_stores
         FROM favorites WHERE user_id = $1`,
        [req.user!.id]
      ),
      query("SELECT COUNT(*) as review_count FROM reviews WHERE user_id = $1", [
        req.user!.id,
      ]),
      query(
        "SELECT COUNT(*) as list_count FROM shopping_lists WHERE user_id = $1",
        [req.user!.id]
      ),
    ]);

    res.json({
      success: true,
      data: {
        saved_products: parseInt(favorites.rows[0].saved_products),
        saved_stores: parseInt(favorites.rows[0].saved_stores),
        reviews_written: parseInt(reviews.rows[0].review_count),
        shopping_lists: parseInt(lists.rows[0].list_count),
      },
    });
  } catch (err) {
    console.error("Get statistics error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch statistics",
    });
  }
});

// GET /api/user/preferences
router.get("/preferences", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const result = await query(
      "SELECT * FROM user_preferences WHERE user_id = $1",
      [req.user!.id]
    );

    if (result.rows.length === 0) {
      // Create default preferences
      await query("INSERT INTO user_preferences (user_id) VALUES ($1)", [
        req.user!.id,
      ]);
      return res.json({
        success: true,
        data: {
          theme: "system",
          language: "en",
          default_view: "grid",
          sort_by: "distance",
          unit_system: "metric",
          distance_limit: 10,
          dietary_preferences: [],
          notification_settings: {},
        },
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error("Get preferences error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch preferences",
    });
  }
});

// PUT /api/user/preferences
router.put("/preferences", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const {
      theme,
      language,
      default_view,
      sort_by,
      unit_system,
      distance_limit,
      dietary_preferences,
      notification_settings,
    } = req.body;

    const result = await query(
      `INSERT INTO user_preferences (user_id, theme, language, default_view, sort_by, unit_system, distance_limit, dietary_preferences, notification_settings)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       ON CONFLICT (user_id) DO UPDATE SET
         theme = COALESCE($2, user_preferences.theme),
         language = COALESCE($3, user_preferences.language),
         default_view = COALESCE($4, user_preferences.default_view),
         sort_by = COALESCE($5, user_preferences.sort_by),
         unit_system = COALESCE($6, user_preferences.unit_system),
         distance_limit = COALESCE($7, user_preferences.distance_limit),
         dietary_preferences = COALESCE($8, user_preferences.dietary_preferences),
         notification_settings = COALESCE($9, user_preferences.notification_settings)
       RETURNING *`,
      [
        req.user!.id,
        theme,
        language,
        default_view,
        sort_by,
        unit_system,
        distance_limit,
        dietary_preferences ? JSON.stringify(dietary_preferences) : null,
        notification_settings ? JSON.stringify(notification_settings) : null,
      ]
    );

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error("Update preferences error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to update preferences",
    });
  }
});

// GET /api/user/favorites/:type
router.get(
  "/favorites/:type",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { type } = req.params;

      if (type !== "products" && type !== "stores") {
        return res.status(400).json({
          success: false,
          error: 'Invalid type. Must be "products" or "stores"',
        });
      }

      const itemType = type === "products" ? "product" : "store";

      let result;
      if (type === "products") {
        result = await query(
          `SELECT f.id as favorite_id, f.created_at as favorited_at,
                p.*, c.name as category_name,
                MIN(sp.price) as min_price
         FROM favorites f
         JOIN products p ON f.item_id = p.id
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN store_products sp ON p.id = sp.product_id
         WHERE f.user_id = $1 AND f.item_type = $2
         GROUP BY f.id, p.id, c.name
         ORDER BY f.created_at DESC`,
          [req.user!.id, itemType]
        );
      } else {
        result = await query(
          `SELECT f.id as favorite_id, f.created_at as favorited_at, s.*
         FROM favorites f
         JOIN stores s ON f.item_id = s.id
         WHERE f.user_id = $1 AND f.item_type = $2
         ORDER BY f.created_at DESC`,
          [req.user!.id, itemType]
        );
      }

      res.json({
        success: true,
        data: result.rows,
      });
    } catch (err) {
      console.error("Get favorites error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to fetch favorites",
      });
    }
  }
);

// POST /api/user/favorites
router.post("/favorites", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { item_type, item_id } = req.body;

    if (!item_type || !item_id) {
      return res.status(400).json({
        success: false,
        error: "Item type and ID are required",
      });
    }

    if (item_type !== "product" && item_type !== "store") {
      return res.status(400).json({
        success: false,
        error: "Invalid item type",
      });
    }

    const result = await query(
      `INSERT INTO favorites (user_id, item_type, item_id)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, item_type, item_id) DO NOTHING
       RETURNING *`,
      [req.user!.id, item_type, item_id]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0] || { message: "Already favorited" },
    });
  } catch (err) {
    console.error("Add favorite error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to add favorite",
    });
  }
});

// DELETE /api/user/favorites/:type/:id
router.delete(
  "/favorites/:type/:id",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { type, id } = req.params;
      const itemType = type === "products" ? "product" : "store";

      const result = await query(
        "DELETE FROM favorites WHERE user_id = $1 AND item_type = $2 AND item_id = $3 RETURNING *",
        [req.user!.id, itemType, id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Favorite not found",
        });
      }

      res.json({
        success: true,
        message: "Favorite removed",
      });
    } catch (err) {
      console.error("Delete favorite error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to remove favorite",
      });
    }
  }
);

// Shopping Lists

// GET /api/user/shopping-lists
router.get(
  "/shopping-lists",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const result = await query(
        `SELECT sl.*, COUNT(sli.id) as item_count
       FROM shopping_lists sl
       LEFT JOIN shopping_list_items sli ON sl.id = sli.list_id
       WHERE sl.user_id = $1
       GROUP BY sl.id
       ORDER BY sl.updated_at DESC`,
        [req.user!.id]
      );

      res.json({
        success: true,
        data: result.rows,
      });
    } catch (err) {
      console.error("Get shopping lists error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to fetch shopping lists",
      });
    }
  }
);

// POST /api/user/shopping-lists
router.post(
  "/shopping-lists",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { name, items } = req.body;

      if (!name) {
        return res.status(400).json({
          success: false,
          error: "List name is required",
        });
      }

      const list = await query(
        "INSERT INTO shopping_lists (user_id, name) VALUES ($1, $2) RETURNING *",
        [req.user!.id, name]
      );

      if (items && items.length > 0) {
        for (const item of items) {
          await query(
            "INSERT INTO shopping_list_items (list_id, product_id, quantity) VALUES ($1, $2, $3)",
            [list.rows[0].id, item.product_id, item.quantity || 1]
          );
        }
      }

      res.status(201).json({
        success: true,
        data: list.rows[0],
      });
    } catch (err) {
      console.error("Create shopping list error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to create shopping list",
      });
    }
  }
);

// GET /api/user/shopping-lists/:id
router.get(
  "/shopping-lists/:id",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;

      const list = await query(
        "SELECT * FROM shopping_lists WHERE id = $1 AND user_id = $2",
        [id, req.user!.id]
      );

      if (list.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Shopping list not found",
        });
      }

      const items = await query(
        `SELECT sli.*, p.name as product_name, p.image_url as product_image,
              MIN(sp.price) as min_price
       FROM shopping_list_items sli
       JOIN products p ON sli.product_id = p.id
       LEFT JOIN store_products sp ON p.id = sp.product_id
       WHERE sli.list_id = $1
       GROUP BY sli.id, p.id
       ORDER BY sli.id`,
        [id]
      );

      res.json({
        success: true,
        data: {
          ...list.rows[0],
          items: items.rows,
        },
      });
    } catch (err) {
      console.error("Get shopping list error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to fetch shopping list",
      });
    }
  }
);

// DELETE /api/user/shopping-lists/:id
router.delete(
  "/shopping-lists/:id",
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;

      const result = await query(
        "DELETE FROM shopping_lists WHERE id = $1 AND user_id = $2 RETURNING *",
        [id, req.user!.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Shopping list not found",
        });
      }

      res.json({
        success: true,
        message: "Shopping list deleted",
      });
    } catch (err) {
      console.error("Delete shopping list error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to delete shopping list",
      });
    }
  }
);

// DELETE /api/user/account
router.delete("/account", async (req: AuthenticatedRequest, res: Response) => {
  try {
    await query("DELETE FROM users WHERE id = $1", [req.user!.id]);

    res.json({
      success: true,
      message: "Account deleted successfully",
    });
  } catch (err) {
    console.error("Delete account error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to delete account",
    });
  }
});

export default router;
