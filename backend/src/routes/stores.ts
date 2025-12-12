import { Router, Response } from "express";
import { query } from "../config/database";
import { AuthenticatedRequest } from "../types";
import { optionalAuthMiddleware } from "../middleware/auth";

const router = Router();

// GET /api/stores/nearby - Get stores near a location
router.get(
  "/nearby",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { lat, lng, radius = "5000", category, limit = "50" } = req.query;

      if (!lat || !lng) {
        return res.status(400).json({
          success: false,
          error: "Latitude and longitude are required",
        });
      }

      const latitude = parseFloat(lat as string);
      const longitude = parseFloat(lng as string);
      const radiusMeters = parseFloat(radius as string);
      const limitNum = Math.min(100, parseInt(limit as string));

      let queryText = `
      SELECT s.*,
             ST_Distance(s.location::geography, ST_MakePoint($1, $2)::geography) as distance
      FROM stores s
      WHERE s.is_active = true
        AND ST_DWithin(s.location::geography, ST_MakePoint($1, $2)::geography, $3)
    `;

      const params: any[] = [longitude, latitude, radiusMeters];

      if (category) {
        queryText += `
        AND EXISTS (
          SELECT 1 FROM store_products sp
          JOIN products p ON sp.product_id = p.id
          WHERE sp.store_id = s.id AND p.category_id = $4
        )`;
        params.push(category);
      }

      queryText += " ORDER BY distance ASC LIMIT $" + (params.length + 1);
      params.push(limitNum);

      const result = await query(queryText, params);

      // Convert distance to km for response
      const stores = result.rows.map((store) => ({
        ...store,
        distance: Math.round(store.distance), // in meters
        distance_km: (store.distance / 1000).toFixed(2),
      }));

      res.json({
        success: true,
        data: stores,
      });
    } catch (err) {
      console.error("Get nearby stores error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to fetch nearby stores",
      });
    }
  }
);

// GET /api/stores/with-product/:productId - Stores that have a specific product
router.get("/with-product/:productId", async (req, res: Response) => {
  try {
    const { productId } = req.params;
    const { lat, lng, sort_by = "price" } = req.query;

    let queryText = `
      SELECT s.*, sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
    `;

    const params: any[] = [productId];

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
    } else if (sort_by === "rating") {
      queryText += " ORDER BY s.rating DESC";
    } else {
      queryText += " ORDER BY sp.price ASC";
    }

    const result = await query(queryText, params);

    const stores = result.rows.map((store) => ({
      ...store,
      distance_km: store.distance ? (store.distance / 1000).toFixed(2) : null,
    }));

    res.json({
      success: true,
      data: stores,
    });
  } catch (err) {
    console.error("Get stores with product error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch stores",
    });
  }
});

// GET /api/stores/:id - Get store details
router.get("/:id", async (req, res: Response) => {
  try {
    const { id } = req.params;
    const { lat, lng } = req.query;

    let queryText = "SELECT s.*";
    const params: any[] = [id];

    if (lat && lng) {
      queryText += `,
        ST_Distance(s.location::geography, ST_MakePoint($2, $3)::geography) as distance`;
      params.push(parseFloat(lng as string), parseFloat(lat as string));
    }

    queryText += " FROM stores s WHERE s.id = $1";

    const store = await query(queryText, params);

    if (store.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Store not found",
      });
    }

    // Get store products
    const products = await query(
      `SELECT p.*, c.name as category_name,
              sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
       FROM store_products sp
       JOIN products p ON sp.product_id = p.id
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE sp.store_id = $1 AND sp.is_available = true
       ORDER BY p.name
       LIMIT 50`,
      [id]
    );

    // Get reviews
    const reviews = await query(
      `SELECT r.*, u.full_name as user_name, u.profile_picture as user_avatar
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.store_id = $1
       ORDER BY r.created_at DESC
       LIMIT 10`,
      [id]
    );

    const storeData = store.rows[0];
    if (storeData.distance) {
      storeData.distance_km = (storeData.distance / 1000).toFixed(2);
    }

    res.json({
      success: true,
      data: {
        store: storeData,
        products: products.rows,
        reviews: reviews.rows,
      },
    });
  } catch (err) {
    console.error("Get store error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch store",
    });
  }
});

// GET /api/stores - List all stores with optional filters
router.get("/", async (req, res: Response) => {
  try {
    const {
      lat,
      lng,
      search,
      min_rating,
      page = "1",
      limit = "20",
    } = req.query;

    const pageNum = Math.max(1, parseInt(page as string));
    const limitNum = Math.min(50, parseInt(limit as string));
    const offset = (pageNum - 1) * limitNum;

    let queryText = "SELECT s.*";
    const params: any[] = [];
    const conditions: string[] = ["s.is_active = true"];

    if (lat && lng) {
      queryText += `,
        ST_Distance(s.location::geography, ST_MakePoint($1, $2)::geography) as distance`;
      params.push(parseFloat(lng as string), parseFloat(lat as string));
    }

    queryText += " FROM stores s";

    if (search) {
      params.push(`%${search}%`);
      conditions.push(
        `(s.name ILIKE $${params.length} OR s.address ILIKE $${params.length})`
      );
    }

    if (min_rating) {
      params.push(parseFloat(min_rating as string));
      conditions.push(`s.rating >= $${params.length}`);
    }

    queryText += " WHERE " + conditions.join(" AND ");

    if (lat && lng) {
      queryText += " ORDER BY distance ASC";
    } else {
      queryText += " ORDER BY s.rating DESC";
    }

    // Count total
    const countResult = await query(
      `SELECT COUNT(*) FROM stores s WHERE ${conditions.join(" AND ")}`,
      params.slice(lat && lng ? 2 : 0)
    );
    const total = parseInt(countResult.rows[0].count);

    params.push(limitNum, offset);
    queryText += ` LIMIT $${params.length - 1} OFFSET $${params.length}`;

    const result = await query(queryText, params);

    const stores = result.rows.map((store) => ({
      ...store,
      distance_km: store.distance ? (store.distance / 1000).toFixed(2) : null,
    }));

    res.json({
      success: true,
      data: {
        items: stores,
        total,
        page: pageNum,
        limit: limitNum,
        total_pages: Math.ceil(total / limitNum),
      },
    });
  } catch (err) {
    console.error("Get stores error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch stores",
    });
  }
});

export default router;
