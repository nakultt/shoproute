import { Router, Response } from "express";
import { query } from "../config/database";
import { AuthenticatedRequest } from "../types";
import { optionalAuthMiddleware } from "../middleware/auth";
import { generateSubstitutions } from "../services/foodRecommendationService";

const router = Router();

// GET /api/substitutions/:productId - Get substitutions for a product
router.get(
  "/:productId",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { productId } = req.params;
      const { user_location, include_prices = "true" } = req.query;

      // Get the original product
      const originalProduct = await query(
        `SELECT p.*, c.name as category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = $1`,
        [productId]
      );

      if (originalProduct.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "Product not found",
        });
      }

      // Check if product is in stock anywhere
      const availability = await query(
        `SELECT sp.*, s.name as store_name
       FROM store_products sp
       JOIN stores s ON sp.store_id = s.id
       WHERE sp.product_id = $1 AND sp.is_available = true AND sp.stock_count > 0
       LIMIT 1`,
        [productId]
      );

      const isOutOfStock = availability.rows.length === 0;

      // Get existing substitutions from database
      let substitutions = await query(
        `SELECT ps.*, p.name, p.image_url, p.brand, p.description,
              MIN(sp.price) as min_price, MAX(sp.stock_count) as max_stock
       FROM product_substitutions ps
       JOIN products p ON ps.substitute_product_id = p.id
       LEFT JOIN store_products sp ON p.id = sp.product_id AND sp.is_available = true
       WHERE ps.original_product_id = $1
       GROUP BY ps.id, p.id
       HAVING MAX(sp.stock_count) > 0
       ORDER BY ps.similarity_score DESC
       LIMIT 5`,
        [productId]
      );

      // If no substitutions found or product is out of stock, generate AI suggestions
      if (substitutions.rows.length === 0 || isOutOfStock) {
        const product = originalProduct.rows[0];
        const aiSubstitutions = await generateSubstitutions(product);

        // Save AI substitutions to database
        for (const sub of aiSubstitutions) {
          if (sub.product_id) {
            await query(
              `INSERT INTO product_substitutions (original_product_id, substitute_product_id, similarity_score, reason, is_ai_generated)
             VALUES ($1, $2, $3, $4, true)
             ON CONFLICT (original_product_id, substitute_product_id) DO UPDATE
             SET similarity_score = $3, reason = $4`,
              [productId, sub.product_id, sub.similarity_score, sub.reason]
            );
          }
        }

        // Re-fetch substitutions
        substitutions = await query(
          `SELECT ps.*, p.name, p.image_url, p.brand, p.description,
                MIN(sp.price) as min_price, MAX(sp.stock_count) as max_stock
         FROM product_substitutions ps
         JOIN products p ON ps.substitute_product_id = p.id
         LEFT JOIN store_products sp ON p.id = sp.product_id AND sp.is_available = true
         WHERE ps.original_product_id = $1
         GROUP BY ps.id, p.id
         HAVING MAX(sp.stock_count) > 0
         ORDER BY ps.similarity_score DESC
         LIMIT 5`,
          [productId]
        );
      }

      // Format response with helpful suggestions
      const formattedSubstitutions = substitutions.rows.map((sub, index) => ({
        id: sub.id,
        product_id: sub.substitute_product_id,
        name: sub.name,
        brand: sub.brand,
        image_url: sub.image_url,
        price: sub.min_price
          ? `$${parseFloat(sub.min_price).toFixed(2)}`
          : null,
        similarity_score: sub.similarity_score,
        reason: sub.reason,
        in_stock: sub.max_stock > 0,
        recommendation_rank: index + 1,
      }));

      res.json({
        success: true,
        data: {
          original_product: {
            id: originalProduct.rows[0].id,
            name: originalProduct.rows[0].name,
            is_out_of_stock: isOutOfStock,
          },
          substitutions: formattedSubstitutions,
          message: isOutOfStock
            ? `${originalProduct.rows[0].name} is out of stock. Here are some alternatives:`
            : "Here are similar products you might like:",
        },
      });
    } catch (err) {
      console.error("Get substitutions error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to get substitutions",
      });
    }
  }
);

// POST /api/substitutions - Manually add a substitution
router.post(
  "/",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { original_product_id, substitute_product_id, reason } = req.body;

      if (!original_product_id || !substitute_product_id) {
        return res.status(400).json({
          success: false,
          error:
            "Both original_product_id and substitute_product_id are required",
        });
      }

      const result = await query(
        `INSERT INTO product_substitutions (original_product_id, substitute_product_id, reason, is_ai_generated)
       VALUES ($1, $2, $3, false)
       ON CONFLICT (original_product_id, substitute_product_id) DO UPDATE
       SET reason = $3
       RETURNING *`,
        [original_product_id, substitute_product_id, reason]
      );

      res.status(201).json({
        success: true,
        data: result.rows[0],
      });
    } catch (err) {
      console.error("Add substitution error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to add substitution",
      });
    }
  }
);

export default router;
