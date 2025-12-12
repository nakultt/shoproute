import { Router, Response } from "express";
import { query } from "../config/database";

const router = Router();

// GET /api/categories - Get all categories
router.get("/", async (req, res: Response) => {
  try {
    const result = await query(
      `SELECT c.*, COUNT(p.id) as product_count
       FROM categories c
       LEFT JOIN products p ON c.id = p.category_id
       WHERE c.is_active = true
       GROUP BY c.id
       ORDER BY c.sort_order, c.name`
    );

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (err) {
    console.error("Get categories error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch categories",
    });
  }
});

// GET /api/categories/:id - Get category by ID
router.get("/:id", async (req, res: Response) => {
  try {
    const { id } = req.params;

    const category = await query("SELECT * FROM categories WHERE id = $1", [
      id,
    ]);

    if (category.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Category not found",
      });
    }

    res.json({
      success: true,
      data: category.rows[0],
    });
  } catch (err) {
    console.error("Get category error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch category",
    });
  }
});

export default router;
