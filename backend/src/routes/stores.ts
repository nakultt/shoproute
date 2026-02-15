import { Router, Response } from "express";
import { AuthenticatedRequest } from "../types";
import { optionalAuthMiddleware } from "../middleware/auth";
import * as storeService from "../services/storeService";

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

      const stores = await storeService.getNearbyStores(
        parseFloat(lat as string),
        parseFloat(lng as string),
        parseFloat(radius as string),
        category as string,
        parseInt(limit as string)
      );

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

    const stores = await storeService.getStoresWithProduct(
      productId,
      lat ? parseFloat(lat as string) : undefined,
      lng ? parseFloat(lng as string) : undefined,
      sort_by as string
    );

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

    const data = await storeService.getStoreDetails(
      id,
      lat ? parseFloat(lat as string) : undefined,
      lng ? parseFloat(lng as string) : undefined
    );

    if (!data) {
      return res.status(404).json({
        success: false,
        error: "Store not found",
      });
    }

    res.json({
      success: true,
      data,
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

    const result = await storeService.getAllStores(
      lat ? parseFloat(lat as string) : undefined,
      lng ? parseFloat(lng as string) : undefined,
      search as string,
      min_rating ? parseFloat(min_rating as string) : undefined,
      parseInt(page as string),
      parseInt(limit as string)
    );

    res.json({
      success: true,
      data: result,
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
