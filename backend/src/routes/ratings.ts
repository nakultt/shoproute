import { Router, Request, Response } from "express";
import Joi from "joi";

const router = Router();

// In-memory storage for ratings (replace with database in production)
const ratings: Map<
  string,
  {
    id: string;
    userId: string;
    targetId: string;
    targetType: "product" | "store";
    rating: number;
    review?: string;
    createdAt: Date;
    updatedAt: Date;
  }
> = new Map();

// Validation schemas
const ratingSchema = Joi.object({
  targetId: Joi.string().required(),
  targetType: Joi.string().valid("product", "store").required(),
  rating: Joi.number().min(1).max(5).required(),
  review: Joi.string().max(500).optional(),
});

const updateRatingSchema = Joi.object({
  rating: Joi.number().min(1).max(5).optional(),
  review: Joi.string().max(500).optional(),
});

// Get ratings for a target (product or store)
router.get("/:targetType/:targetId", (req: Request, res: Response): void => {
  const { targetType, targetId } = req.params;

  if (!["product", "store"].includes(targetType)) {
    res.status(400).json({ error: "Invalid target type" });
    return;
  }

  const targetRatings = Array.from(ratings.values()).filter(
    (r) => r.targetId === targetId && r.targetType === targetType
  );

  // Calculate average rating
  const totalRatings = targetRatings.length;
  const averageRating =
    totalRatings > 0
      ? targetRatings.reduce((sum, r) => sum + r.rating, 0) / totalRatings
      : 0;

  // Rating distribution
  const distribution = {
    1: targetRatings.filter((r) => r.rating === 1).length,
    2: targetRatings.filter((r) => r.rating === 2).length,
    3: targetRatings.filter((r) => r.rating === 3).length,
    4: targetRatings.filter((r) => r.rating === 4).length,
    5: targetRatings.filter((r) => r.rating === 5).length,
  };

  res.json({
    targetId,
    targetType,
    averageRating: Math.round(averageRating * 10) / 10,
    totalRatings,
    distribution,
    reviews: targetRatings.map((r) => ({
      id: r.id,
      userId: r.userId,
      rating: r.rating,
      review: r.review,
      createdAt: r.createdAt,
    })),
  });
});

// Create a new rating
router.post("/", (req: Request, res: Response): void => {
  const { error, value } = ratingSchema.validate(req.body);

  if (error) {
    res.status(400).json({ error: error.details[0].message });
    return;
  }

  const userId = (req as any).user?.id || "anonymous";
  const { targetId, targetType, rating, review } = value;

  // Check if user already rated this target
  const existingRating = Array.from(ratings.values()).find(
    (r) =>
      r.userId === userId &&
      r.targetId === targetId &&
      r.targetType === targetType
  );

  if (existingRating) {
    res.status(400).json({ error: "You have already rated this item" });
    return;
  }

  const id = `rating_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  const newRating = {
    id,
    userId,
    targetId,
    targetType,
    rating,
    review,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  ratings.set(id, newRating);

  res.status(201).json({
    message: "Rating submitted successfully",
    rating: newRating,
  });
});

// Update a rating
router.put("/:ratingId", (req: Request, res: Response): void => {
  const { ratingId } = req.params;
  const { error, value } = updateRatingSchema.validate(req.body);

  if (error) {
    res.status(400).json({ error: error.details[0].message });
    return;
  }

  const existingRating = ratings.get(ratingId);

  if (!existingRating) {
    res.status(404).json({ error: "Rating not found" });
    return;
  }

  const userId = (req as any).user?.id || "anonymous";
  if (existingRating.userId !== userId) {
    res.status(403).json({ error: "Not authorized to update this rating" });
    return;
  }

  const updatedRating = {
    ...existingRating,
    ...value,
    updatedAt: new Date(),
  };

  ratings.set(ratingId, updatedRating);

  res.json({
    message: "Rating updated successfully",
    rating: updatedRating,
  });
});

// Delete a rating
router.delete("/:ratingId", (req: Request, res: Response): void => {
  const { ratingId } = req.params;

  const existingRating = ratings.get(ratingId);

  if (!existingRating) {
    res.status(404).json({ error: "Rating not found" });
    return;
  }

  const userId = (req as any).user?.id || "anonymous";
  if (existingRating.userId !== userId) {
    res.status(403).json({ error: "Not authorized to delete this rating" });
    return;
  }

  ratings.delete(ratingId);

  res.json({ message: "Rating deleted successfully" });
});

// Get user's ratings
router.get("/user/:userId", (req: Request, res: Response): void => {
  const { userId } = req.params;

  const userRatings = Array.from(ratings.values()).filter(
    (r) => r.userId === userId
  );

  res.json({
    userId,
    totalRatings: userRatings.length,
    ratings: userRatings,
  });
});

export default router;
