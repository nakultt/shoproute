import { Router, Response } from "express";
import { AuthenticatedRequest } from "../types";
import { authMiddleware, optionalAuthMiddleware } from "../middleware/auth";
import * as productService from "../services/productService";

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

      const result = await productService.getProducts(
        category as string,
        search as string,
        min_price ? parseFloat(min_price as string) : undefined,
        max_price ? parseFloat(max_price as string) : undefined,
        in_stock === "true",
        sort_by as string,
        parseInt(page as string),
        parseInt(limit as string)
      );

      res.json({
        success: true,
        data: result,
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

    const result = await productService.searchProductsAndStores(
      q as string,
      parseInt(limit as string)
    );

    res.json({
      success: true,
      data: result,
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
  // Keeping this simple query inline as it's very specific and small
  try {
    const { q } = req.query;
    // ... logic for suggestions (kept inline or moved if needed, but keeping simple for now)
    // Actually, let's just leave it inline or move to service if we want 100% purity.
    // For consistency, I will assume we can leave it or move it.
    // Let's implement it in service if I missed it, checking...
    // I didn't add suggestion logic to `getProducts` specifically, but I added `searchProductsAndStores`.
    // Let's leave it inline for now as it wasn't critical for AI tools, or adding it to service is easy.
    // Re-reading my service implementation... I didn't implement `getSuggestions`.
    // I will implementation it inline here to save time, or add to service.
    // Let's add it to service for completeness if I can script it, but I'll stick to replacing file content.
    // I will keep the original implementation for suggestions since I didn't port it to service?
    // Wait, I replaced the WHOLE file. If I didn't put it in service, I need to put it back here.
    // I'll re-implement the DB query here for now to avoid breaking it, or add to service in a fix-up.
    // Better: I will re-implement the query here as it was small.
    
    // Actually, I'll just check if I can skip it? No, user might need it.
    // I'll add the query back here directly.
    const { query } = require("../config/database"); // Need to re-import query locally for this one fallback
    
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
      data: result.rows.map((r: any) => r.name),
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

    const data = await productService.getProductDetails(id);

    if (!data) {
      return res.status(404).json({
        success: false,
        error: "Product not found",
      });
    }

    res.json({
      success: true,
      data,
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

    // We can reuse getStoresWithProduct from storeService! 
    // But wait, this route was in products.ts. logic is "stores that have this product".
    // I added `getStoresWithProduct` to `storeService`.
    // So I should use that.
    
    const { getStoresWithProduct } = require("../services/storeService");

    const stores = await getStoresWithProduct(
      id,
      lat ? parseFloat(lat as string) : undefined,
      lng ? parseFloat(lng as string) : undefined,
      sort_by as string
    );

    res.json({
      success: true,
      data: stores,
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
     // I didn't strictly port "get reviews list" to service, only "get product details" which includes stats.
     // I should probably add `getProductReviews` to service or just use query here.
     // To keep this clean, I'll re-implement query here or add to service. 
     // I'll add the query here to avoid context switching risk.
     const { query } = require("../config/database");
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

      try {
        const review = await productService.addReview(
            req.user!.id,
            id,
            rating,
            review_text,
            store_id
        );
        res.status(201).json({
            success: true,
            data: review,
        });
      } catch (e: any) {
          if (e.message.includes("already reviewed")) {
              return res.status(409).json({ success: false, error: e.message });
          }
          return res.status(400).json({ success: false, error: e.message });
      }
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
      const result = await productService.getPersonalizedRecommendations(req.user!.id);

      res.json({
        success: true,
        data: result,
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
