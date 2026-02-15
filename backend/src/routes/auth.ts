import { Router, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import Joi from "joi";
import { query } from "../config/database";
import { AuthenticatedRequest, RegisterRequest, LoginRequest } from "../types";
import {
  generateOTP,
  sendVerificationEmail,
  sendPasswordResetEmail,
} from "../services/emailService";
import { authMiddleware } from "../middleware/auth";

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key";
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

// Validation schemas
const registerSchema = Joi.object({
  full_name: Joi.string().min(2).max(255).required(),
  email: Joi.string().email().required(),
  phone: Joi.string()
    .pattern(/^\+?[1-9]\d{1,14}$/)
    .required(),
  password: Joi.string().min(8).required(),
});

const loginSchema = Joi.object({
  email_or_username: Joi.string().required(),
  password: Joi.string().required(),
});

const verifyEmailSchema = Joi.object({
  email: Joi.string().email().required(),
  otp: Joi.string().length(6).required(),
});

// POST /api/auth/register
router.post("/register", async (req, res: Response) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
      });
    }

    const { full_name, email, phone, password }: RegisterRequest = value;

    // Check if email or phone already exists
    const existingUser = await query(
      "SELECT id FROM users WHERE email = $1 OR phone = $2",
      [email, phone]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: "Email or phone number already registered",
      });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 12);

    // Generate OTP
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Insert user
    const result = await query(
      `INSERT INTO users (full_name, email, phone, password_hash, email_otp, email_otp_expires)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, full_name, email, phone, email_verified, created_at`,
      [full_name, email, phone, password_hash, otp, otpExpires]
    );

    // Create default preferences
    await query("INSERT INTO user_preferences (user_id) VALUES ($1)", [
      result.rows[0].id,
    ]);

    // Send verification email
    await sendVerificationEmail(email, otp, full_name);

    res.status(201).json({
      success: true,
      message: "Registration successful. Please verify your email.",
      data: {
        userId: result.rows[0].id,
        email: result.rows[0].email,
      },
    });
  } catch (err) {
    console.error("Registration error:", err);
    res.status(500).json({
      success: false,
      error: "Registration failed. Please try again.",
    });
  }
});

// POST /api/auth/verify-email
router.post("/verify-email", async (req, res: Response) => {
  try {
    const { error, value } = verifyEmailSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
      });
    }

    const { email, otp } = value;

    const result = await query(
      `SELECT id, email_otp, email_otp_expires, email_verified
       FROM users WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }

    const user = result.rows[0];

    if (user.email_verified) {
      return res.status(400).json({
        success: false,
        error: "Email already verified",
      });
    }

    if (user.email_otp !== otp) {
      return res.status(400).json({
        success: false,
        error: "Invalid OTP",
      });
    }

    if (new Date() > new Date(user.email_otp_expires)) {
      return res.status(400).json({
        success: false,
        error: "OTP has expired",
      });
    }

    // Update user as verified
    await query(
      `UPDATE users SET email_verified = true, email_otp = NULL, email_otp_expires = NULL
       WHERE id = $1`,
      [user.id]
    );

    res.json({
      success: true,
      message: "Email verified successfully",
      verified: true,
    });
  } catch (err) {
    console.error("Email verification error:", err);
    res.status(500).json({
      success: false,
      error: "Verification failed. Please try again.",
    });
  }
});

// POST /api/auth/resend-otp
router.post("/resend-otp", async (req, res: Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        error: "Email is required",
      });
    }

    const result = await query(
      "SELECT id, full_name, email_verified FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }

    if (result.rows[0].email_verified) {
      return res.status(400).json({
        success: false,
        error: "Email already verified",
      });
    }

    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);

    await query(
      "UPDATE users SET email_otp = $1, email_otp_expires = $2 WHERE email = $3",
      [otp, otpExpires, email]
    );

    await sendVerificationEmail(email, otp, result.rows[0].full_name);

    res.json({
      success: true,
      message: "OTP sent successfully",
    });
  } catch (err) {
    console.error("Resend OTP error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to resend OTP",
    });
  }
});

// POST /api/auth/login
router.post("/login", async (req, res: Response) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
      });
    }

    const { email_or_username, password }: LoginRequest = value;

    const result = await query(
      `SELECT id, full_name, email, phone, password_hash, email_verified, profile_picture, created_at
       FROM users WHERE email = $1 OR phone = $1`,
      [email_or_username]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: "Invalid credentials",
      });
    }

    const user = result.rows[0];

    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        error: "Invalid credentials",
      });
    }

    if (!user.email_verified) {
      return res.status(403).json({
        success: false,
        error: "Please verify your email before logging in",
        requiresVerification: true,
      });
    }

    // Generate JWT
    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN as any,
    });

    // Remove password_hash from response
    const { password_hash, ...userWithoutPassword } = user;

    res.json({
      success: true,
      data: {
        token,
        user: userWithoutPassword,
      },
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({
      success: false,
      error: "Login failed. Please try again.",
    });
  }
});

// POST /api/auth/forgot-password
router.post("/forgot-password", async (req, res: Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        error: "Email is required",
      });
    }

    const result = await query(
      "SELECT id, full_name FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      // Don't reveal if email exists
      return res.json({
        success: true,
        message:
          "If an account exists with this email, a reset code has been sent.",
      });
    }

    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);

    await query(
      "UPDATE users SET email_otp = $1, email_otp_expires = $2 WHERE email = $3",
      [otp, otpExpires, email]
    );

    await sendPasswordResetEmail(email, otp, result.rows[0].full_name);

    res.json({
      success: true,
      message:
        "If an account exists with this email, a reset code has been sent.",
    });
  } catch (err) {
    console.error("Forgot password error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to process request",
    });
  }
});

// POST /api/auth/reset-password
router.post("/reset-password", async (req, res: Response) => {
  try {
    const { email, otp, new_password } = req.body;

    if (!email || !otp || !new_password) {
      return res.status(400).json({
        success: false,
        error: "Email, OTP, and new password are required",
      });
    }

    if (new_password.length < 8) {
      return res.status(400).json({
        success: false,
        error: "Password must be at least 8 characters",
      });
    }

    const result = await query(
      "SELECT id, email_otp, email_otp_expires FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "User not found",
      });
    }

    const user = result.rows[0];

    if (user.email_otp !== otp) {
      return res.status(400).json({
        success: false,
        error: "Invalid OTP",
      });
    }

    if (new Date() > new Date(user.email_otp_expires)) {
      return res.status(400).json({
        success: false,
        error: "OTP has expired",
      });
    }

    const password_hash = await bcrypt.hash(new_password, 12);

    await query(
      `UPDATE users SET password_hash = $1, email_otp = NULL, email_otp_expires = NULL
       WHERE id = $2`,
      [password_hash, user.id]
    );

    res.json({
      success: true,
      message: "Password reset successfully",
    });
  } catch (err) {
    console.error("Reset password error:", err);
    res.status(500).json({
      success: false,
      error: "Failed to reset password",
    });
  }
});

// GET /api/auth/me - Get current user
router.get(
  "/me",
  authMiddleware,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const result = await query(
        `SELECT id, full_name, email, phone, date_of_birth, email_verified, profile_picture, created_at
       FROM users WHERE id = $1`,
        [req.user!.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: "User not found",
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } catch (err) {
      console.error("Get user error:", err);
      res.status(500).json({
        success: false,
        error: "Failed to get user",
      });
    }
  }
);

export default router;
