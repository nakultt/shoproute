// TypeScript interfaces for ShopRoute

// User types
export interface User {
  id: number;
  full_name: string;
  email: string;
  phone: string;
  password_hash?: string;
  date_of_birth?: Date;
  email_verified: boolean;
  profile_picture?: string;
  created_at: Date;
  updated_at: Date;
}

export interface UserPreferences {
  user_id: number;
  theme: "light" | "dark" | "system";
  language: string;
  default_view: "grid" | "list";
  sort_by: "distance" | "price" | "rating";
  unit_system: "metric" | "imperial";
  distance_limit: number;
  dietary_preferences: string[];
  notification_settings: NotificationSettings;
}

export interface NotificationSettings {
  push: boolean;
  email: boolean;
  price_drop: boolean;
  back_in_stock: boolean;
  new_deals: boolean;
  weekly_summary: boolean;
}

// Store types
export interface Store {
  id: number;
  name: string;
  logo_url?: string;
  address: string;
  location: {
    latitude: number;
    longitude: number;
  };
  phone?: string;
  email?: string;
  website?: string;
  opening_hours?: Record<string, string>;
  rating: number;
  review_count: number;
  is_active: boolean;
  distance?: number; // Calculated field
  created_at: Date;
  updated_at: Date;
}

// Category types
export interface Category {
  id: number;
  name: string;
  icon?: string;
  color?: string;
  sort_order: number;
  is_active: boolean;
}

// Product types
export interface Product {
  id: number;
  name: string;
  description?: string;
  image_url?: string;
  category_id?: number;
  category?: Category;
  brand?: string;
  unit?: string;
  nutritional_info?: Record<string, any>;
  created_at: Date;
  updated_at: Date;
}

export interface StoreProduct {
  id: number;
  store_id: number;
  product_id: number;
  store?: Store;
  product?: Product;
  price: number;
  compare_at_price?: number;
  stock_count: number;
  is_available: boolean;
  discount_percentage: number;
  updated_at: Date;
}

// Review types
export interface Review {
  id: number;
  user_id: number;
  user?: Pick<User, "id" | "full_name" | "profile_picture">;
  product_id: number;
  store_id: number;
  rating: number;
  review_text?: string;
  helpful_count: number;
  created_at: Date;
}

// Cart & Shopping List types
export interface CartItem {
  id: number;
  user_id: number;
  product_id: number;
  store_id: number;
  product?: Product;
  store?: Store;
  store_product?: StoreProduct;
  quantity: number;
  added_at: Date;
}

export interface ShoppingList {
  id: number;
  user_id: number;
  name: string;
  items?: ShoppingListItem[];
  item_count?: number;
  created_at: Date;
  updated_at: Date;
}

export interface ShoppingListItem {
  id: number;
  list_id: number;
  product_id: number;
  product?: Product;
  quantity: number;
  is_checked: boolean;
  notes?: string;
}

// Favorite types
export interface Favorite {
  id: number;
  user_id: number;
  item_type: "product" | "store";
  item_id: number;
  created_at: Date;
}

// AI types
export interface ChatMessage {
  role: "user" | "assistant";
  content: string;
  timestamp: Date;
  data?: RouteResult | ProductRecommendation[];
}

export interface RouteResult {
  stops: RouteStop[];
  total_distance: number; // in meters
  total_time: number; // in seconds
  total_savings?: number;
  polyline: [number, number][]; // [lat, lng] pairs
}

export interface RouteStop {
  store: Store;
  products: StoreProduct[];
  subtotal: number;
  order: number;
}

export interface ProductRecommendation {
  product: Product;
  stores: StoreProduct[];
  reason: string;
}

// API types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

// Auth types
export interface LoginRequest {
  email_or_username: string;
  password: string;
}

export interface RegisterRequest {
  full_name: string;
  email: string;
  phone: string;
  password: string;
}

export interface AuthResponse {
  token: string;
  user: Omit<User, "password_hash">;
}

// Search types
export interface SearchResult {
  products: Product[];
  stores: Store[];
}

// Route optimization request
export interface RouteOptimizationRequest {
  products: number[];
  user_location: {
    latitude: number;
    longitude: number;
  };
}

// Express extensions
import { Request } from "express";

export interface AuthenticatedRequest extends Request {
  user?: {
    id: number;
    email: string;
  };
}
