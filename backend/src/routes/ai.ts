import { Router, Response } from "express";
import { AuthenticatedRequest } from "../types";
import { authMiddleware, optionalAuthMiddleware } from "../middleware/auth";
import {
  generateChatResponse,
  optimizeShoppingRoute,
  getRecommendations,
  ChatRequest,
} from "../services/aiService";
import { query } from "../config/database";

const router = Router();

// POST /api/ai/chat - Send message to AI
router.post(
  "/chat",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { message, conversation_history = [], user_location } = req.body;

      if (!message) {
        return res.status(400).json({
          success: false,
          error: "Message is required",
        });
      }

      const request: ChatRequest = {
        message,
        conversation_history,
        user_location,
        user_id: req.user?.id,
      };

      const response = await generateChatResponse(request);

      // Save conversation if user is authenticated
      if (req.user?.id) {
        const existingConvo = await query(
          "SELECT id, messages FROM ai_conversations WHERE user_id = $1 ORDER BY updated_at DESC LIMIT 1",
          [req.user.id]
        );

        const newMessages = [
          ...conversation_history,
          { role: "user", content: message },
          { role: "assistant", content: response.response },
        ];

        if (existingConvo.rows.length > 0) {
          await query(
            "UPDATE ai_conversations SET messages = $1 WHERE id = $2",
            [JSON.stringify(newMessages), existingConvo.rows[0].id]
          );
        } else {
          await query(
            "INSERT INTO ai_conversations (user_id, messages) VALUES ($1, $2)",
            [req.user.id, JSON.stringify(newMessages)]
          );
        }
      }

      res.json({
        success: true,
        data: response,
      });
    } catch (err) {
      console.error("AI chat error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to process chat",
      });
    }
  }
);

// POST /api/ai/route-optimization - Optimize shopping route
router.post(
  "/route-optimization",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { products, user_location } = req.body;

      if (!products || !Array.isArray(products) || products.length === 0) {
        return res.status(400).json({
          success: false,
          error: "Products array is required",
        });
      }

      if (
        !user_location ||
        !user_location.latitude ||
        !user_location.longitude
      ) {
        return res.status(400).json({
          success: false,
          error: "User location is required",
        });
      }

      // Get product names from IDs if numeric, otherwise use as names
      let productNames: string[];
      if (typeof products[0] === "number") {
        const result = await query(
          "SELECT name FROM products WHERE id = ANY($1)",
          [products]
        );
        productNames = result.rows.map((r) => r.name);
      } else {
        productNames = products;
      }

      const route = await optimizeShoppingRoute(productNames, user_location);

      if (!route) {
        return res.status(404).json({
          success: false,
          error: "Could not find a suitable route for the requested products",
        });
      }

      res.json({
        success: true,
        data: route,
      });
    } catch (err) {
      console.error("Route optimization error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to optimize route",
      });
    }
  }
);

// GET /api/ai/recommendations - Get AI-powered recommendations
router.get(
  "/recommendations",
  optionalAuthMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { preferences, budget, category } = req.query;

      const prefArray = preferences
        ? (preferences as string).split(",").map((p) => p.trim())
        : [];

      const budgetNum = budget ? parseFloat(budget as string) : undefined;
      const categoryNum = category ? parseInt(category as string) : undefined;

      const recommendations = await getRecommendations(
        prefArray,
        budgetNum,
        categoryNum
      );

      res.json({
        success: true,
        data: recommendations,
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

// GET /api/ai/conversation-history - Get user's AI conversation history
router.get(
  "/conversation-history",
  authMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const result = await query(
        "SELECT id, messages, created_at, updated_at FROM ai_conversations WHERE user_id = $1 ORDER BY updated_at DESC LIMIT 10",
        [req.user!.id]
      );

      res.json({
        success: true,
        data: result.rows,
      });
    } catch (err) {
      console.error("Get conversation history error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to fetch conversation history",
      });
    }
  }
);

// DELETE /api/ai/conversation-history - Clear conversation history
router.delete(
  "/conversation-history",
  authMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      await query("DELETE FROM ai_conversations WHERE user_id = $1", [
        req.user!.id,
      ]);

      res.json({
        success: true,
        message: "Conversation history cleared",
      });
    } catch (err) {
      console.error("Clear conversation history error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to clear conversation history",
      });
    }
  }
);

export default router;
