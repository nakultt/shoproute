import { Router, Response } from "express";
import { query } from "../config/database";
import { AuthenticatedRequest } from "../types";
import { authMiddleware, optionalAuthMiddleware } from "../middleware/auth";

const router = Router();

// GET /api/products - List products with filters
router.get(
  "/",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const {
        category,
        page = "1",
        limit = "20",
        sort_by = "name",
        search,
        min_price,
        max_price,
        in_stock,
      } = req.query;

      const pageNum = Math.max(1, parseInt(page as string));
      const limitNum = Math.min(50, Math.max(1, parseInt(limit as string)));
      const offset = (pageNum - 1) * limitNum;

      let queryText = `
      SELECT DISTINCT p.*, c.name as category_name, c.icon as category_icon,
             MIN(sp.price) as min_price, MAX(sp.price) as max_price,
             COUNT(DISTINCT sp.store_id) as store_count,
             BOOL_OR(sp.is_available AND sp.stock_count > 0) as is_available,
             (ARRAY_AGG(sp.store_id ORDER BY sp.price ASC))[1] as store_id,
             (ARRAY_AGG(s.name ORDER BY sp.price ASC))[1] as store_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN store_products sp ON p.id = sp.product_id
      LEFT JOIN stores s ON sp.store_id = s.id
    `;

      const params: any[] = [];
      const conditions: string[] = [];

      if (category) {
        params.push(category);
        conditions.push(`p.category_id = $${params.length}`);
      }

      if (search) {
        params.push(`%${search}%`);
        conditions.push(
          `(p.name ILIKE $${params.length} OR p.description ILIKE $${params.length})`
        );
      }

      if (in_stock === "true") {
        conditions.push("sp.is_available = true AND sp.stock_count > 0");
      }

      if (conditions.length > 0) {
        queryText += " WHERE " + conditions.join(" AND ");
      }

      queryText += " GROUP BY p.id, c.name, c.icon";

      if (min_price) {
        queryText += ` HAVING MIN(sp.price) >= ${parseFloat(
          min_price as string
        )}`;
      }
      if (max_price) {
        if (min_price) {
          queryText += ` AND MAX(sp.price) <= ${parseFloat(
            max_price as string
          )}`;
        } else {
          queryText += ` HAVING MAX(sp.price) <= ${parseFloat(
            max_price as string
          )}`;
        }
      }

      // Sorting
      switch (sort_by) {
        case "price_asc":
          queryText += " ORDER BY min_price ASC NULLS LAST";
          break;
        case "price_desc":
          queryText += " ORDER BY min_price DESC NULLS LAST";
          break;
        case "name":
        default:
          queryText += " ORDER BY p.name ASC";
      }

      // Count total
      const countResult = await query(
        `SELECT COUNT(DISTINCT p.id) FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN store_products sp ON p.id = sp.product_id
       LEFT JOIN stores s ON sp.store_id = s.id
       ${conditions.length > 0 ? "WHERE " + conditions.join(" AND ") : ""}`,
        params
      );
      const total = parseInt(countResult.rows[0].count);

      // Add pagination
      params.push(limitNum, offset);
      queryText += ` LIMIT $${params.length - 1} OFFSET $${params.length}`;

      const result = await query(queryText, params);

      res.json({
        success: true,
        data: {
          items: result.rows,
          total,
          page: pageNum,
          limit: limitNum,
          total_pages: Math.ceil(total / limitNum),
        },
      });
    } catch (err) {
      console.error("Get products error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to fetch products",
      });
    }
  }
);

// GET /api/products/search?q=query
router.get("/search", async (req, res: Response) => {
  try {
    const { q, limit = "10" } = req.query;

    if (!q || (q as string).length < 2) {
      return res.json({ success: true, data: { products: [], stores: [] } });
    }

    const limitNum = Math.min(20, parseInt(limit as string));

    // Search products
    const products = await query(
      `SELECT p.*, c.name as category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.name ILIKE $1 OR p.brand ILIKE $1
       ORDER BY p.name
       LIMIT $2`,
      [`%${q}%`, limitNum]
    );

    // Search stores
    const stores = await query(
      `SELECT id, name, logo_url, address, rating
       FROM stores
       WHERE name ILIKE $1 OR address ILIKE $1
       ORDER BY rating DESC
       LIMIT $2`,
      [`%${q}%`, limitNum]
    );

    res.json({
      success: true,
      data: {
        products: products.rows,
        stores: stores.rows,
      },
    });
  } catch (err) {
    console.error("Search error:", err);
    res.status(500).json({
      success: false,
      error: "Search failed",
    });
  }
});

// GET /api/products/suggestions?q=query
router.get("/suggestions", async (req, res: Response) => {
  try {
    const { q } = req.query;

    if (!q || (q as string).length < 1) {
      return res.json({ success: true, data: [] });
    }

    const result = await query(
      `SELECT DISTINCT name FROM products
       WHERE name ILIKE $1
       ORDER BY name
       LIMIT 8`,
      [`${q}%`]
    );

    res.json({
      success: true,
      data: result.rows.map((r) => r.name),
    });
  } catch (err) {
    console.error("Suggestions error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to get suggestions",
    });
  }
});

// GET /api/products/:id - Get product details
router.get("/:id", async (req, res: Response) => {
  try {
    const { id } = req.params;

    const product = await query(
      `SELECT p.*, c.name as category_name, c.icon as category_icon
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = $1`,
      [id]
    );

    if (product.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Product not found",
      });
    }

    // Get stores with this product
    const stores = await query(
      `SELECT s.id, s.name, s.logo_url, s.address, s.rating,
              sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
       FROM store_products sp
       JOIN stores s ON sp.store_id = s.id
       WHERE sp.product_id = $1 AND s.is_active = true
       ORDER BY sp.price ASC`,
      [id]
    );

    // Get reviews summary
    const reviewStats = await query(
      `SELECT 
         COUNT(*) as total_reviews,
         AVG(rating)::numeric(2,1) as avg_rating,
         COUNT(*) FILTER (WHERE rating = 5) as five_star,
         COUNT(*) FILTER (WHERE rating = 4) as four_star,
         COUNT(*) FILTER (WHERE rating = 3) as three_star,
         COUNT(*) FILTER (WHERE rating = 2) as two_star,
         COUNT(*) FILTER (WHERE rating = 1) as one_star
       FROM reviews WHERE product_id = $1`,
      [id]
    );

    res.json({
      success: true,
      data: {
        product: product.rows[0],
        stores: stores.rows,
        review_stats: reviewStats.rows[0],
      },
    });
  } catch (err) {
    console.error("Get product error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch product",
    });
  }
});

// GET /api/products/:id/stores - Get stores with price comparison
router.get("/:id/stores", async (req, res: Response) => {
  try {
    const { id } = req.params;
    const { lat, lng, sort_by = "price" } = req.query;

    let queryText = `
      SELECT s.id, s.name, s.logo_url, s.address, s.rating, s.review_count,
             sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
    `;

    const params: any[] = [id];

    if (lat && lng) {
      queryText += `,
        ST_Distance(s.location::geography, ST_MakePoint($2, $3)::geography) as distance`;
      params.push(parseFloat(lng as string), parseFloat(lat as string));
    }

    queryText += `
      FROM store_products sp
      JOIN stores s ON sp.store_id = s.id
      WHERE sp.product_id = $1 AND s.is_active = true`;

    // Sorting
    if (sort_by === "distance" && lat && lng) {
      queryText += " ORDER BY distance ASC";
    } else {
      queryText += " ORDER BY sp.price ASC";
    }

    const result = await query(queryText, params);

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (err) {
    console.error("Get product stores error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch stores",
    });
  }
});

// GET /api/products/:id/reviews
router.get("/:id/reviews", async (req, res: Response) => {
  try {
    const { id } = req.params;
    const { page = "1", limit = "10" } = req.query;

    const pageNum = Math.max(1, parseInt(page as string));
    const limitNum = Math.min(50, parseInt(limit as string));
    const offset = (pageNum - 1) * limitNum;

    const reviews = await query(
      `SELECT r.*, u.full_name as user_name, u.profile_picture as user_avatar
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.product_id = $1
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [id, limitNum, offset]
    );

    const countResult = await query(
      "SELECT COUNT(*) FROM reviews WHERE product_id = $1",
      [id]
    );
    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      data: {
        items: reviews.rows,
        total,
        page: pageNum,
        limit: limitNum,
        total_pages: Math.ceil(total / limitNum),
      },
    });
  } catch (err) {
    console.error("Get reviews error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch reviews",
    });
  }
});

// POST /api/products/:id/reviews - Add review
router.post(
  "/:id/reviews",
  authMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;
      const { rating, review_text, store_id } = req.body;

      if (!rating || rating < 1 || rating > 5) {
        return res.status(400).json({
          success: false,
          error: "Rating must be between 1 and 5",
        });
      }

      // Check if user already reviewed this product
      const existing = await query(
        "SELECT id FROM reviews WHERE user_id = $1 AND product_id = $2",
        [req.user!.id, id]
      );

      if (existing.rows.length > 0) {
        return res.status(409).json({
          success: false,
          error: "You have already reviewed this product",
        });
      }

      const result = await query(
        `INSERT INTO reviews (user_id, product_id, store_id, rating, review_text)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
        [req.user!.id, id, store_id || null, rating, review_text || null]
      );

      res.status(201).json({
        success: true,
        data: result.rows[0],
      });
    } catch (err) {
      console.error("Add review error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to add review",
      });
    }
  }
);

// GET /api/products/recommendations - AI-powered recommendations
router.get(
  "/recommendations",
  authMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      // Get user preferences
      const prefs = await query(
        "SELECT dietary_preferences FROM user_preferences WHERE user_id = $1",
        [req.user!.id]
      );

      // Get recent purchases/favorites for personalization
      const favorites = await query(
        `SELECT item_id FROM favorites
       WHERE user_id = $1 AND item_type = 'product'
       ORDER BY created_at DESC LIMIT 10`,
        [req.user!.id]
      );

      // Simple recommendation: popular products in user's favorite categories
      let result;
      if (favorites.rows.length > 0) {
        result = await query(
          `SELECT DISTINCT p.*, c.name as category_name,
                MIN(sp.price) as min_price, COUNT(DISTINCT r.id) as review_count
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN store_products sp ON p.id = sp.product_id
         LEFT JOIN reviews r ON p.id = r.product_id
         WHERE p.category_id IN (
           SELECT DISTINCT category_id FROM products WHERE id = ANY($1)
         )
         AND p.id NOT IN (SELECT item_id FROM favorites WHERE user_id = $2 AND item_type = 'product')
         GROUP BY p.id, c.name
         ORDER BY review_count DESC
         LIMIT 20`,
          [favorites.rows.map((f) => f.item_id), req.user!.id]
        );
      } else {
        // Default: trending products
        result = await query(
          `SELECT p.*, c.name as category_name,
                MIN(sp.price) as min_price, COUNT(DISTINCT r.id) as review_count
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN store_products sp ON p.id = sp.product_id
         LEFT JOIN reviews r ON p.id = r.product_id
         GROUP BY p.id, c.name
         ORDER BY review_count DESC
         LIMIT 20`
        );
      }

      res.json({
        success: true,
        data: result.rows,
      });
    } catch (err) {
      console.error("Recommendations error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to get recommendations",
      });
    }
  }
);

export default router;
