import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

import { errorHandler, notFoundHandler } from "./middleware/errorHandler";
import authRoutes from "./routes/auth";
import productsRoutes from "./routes/products";
import storesRoutes from "./routes/stores";
import cartRoutes from "./routes/cart";
import userRoutes from "./routes/user";
import aiRoutes from "./routes/ai";
import categoriesRoutes from "./routes/categories";
import pantryRoutes from "./routes/pantry";
import substitutionsRoutes from "./routes/substitutions";
import ratingsRoutes from "./routes/ratings";

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    error: "Too many requests, please try again later.",
  },
});
app.use("/api/", limiter);

// Body parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "ShopRoute API is running",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
  });
});

// API routes
app.use("/api/auth", authRoutes);
app.use("/api/products", productsRoutes);
app.use("/api/stores", storesRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/user", userRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/categories", categoriesRoutes);
app.use("/api/pantry", pantryRoutes);
app.use("/api/substitutions", substitutionsRoutes);
app.use("/api/ratings", ratingsRoutes);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   🛒 ShopRoute API Server                             ║
║   ──────────────────────────                          ║
║                                                       ║
║   Server running on port ${PORT}                         ║
║   Environment: ${(process.env.NODE_ENV || "development").padEnd(
    15
  )}                   ║
║                                                       ║
║   Endpoints:                                          ║
║   • GET  /health              - Health check          ║
║   • POST /api/auth/register   - Register user         ║
║   • POST /api/auth/login      - Login                 ║
║   • GET  /api/products        - List products         ║
║   • GET  /api/stores/nearby   - Nearby stores         ║
║   • POST /api/ai/chat         - AI assistant          ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
  `);
});

export default app;
