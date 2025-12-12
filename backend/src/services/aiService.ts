import { GoogleGenerativeAI } from "@google/generative-ai";
import { query } from "../config/database";
import { RouteResult, RouteStop } from "../types";
import axios from "axios";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const OSRM_URL =
  process.env.OSRM_SERVER_URL || "http://router.project-osrm.org";

export interface ChatRequest {
  message: string;
  conversation_history: { role: "user" | "assistant"; content: string }[];
  user_location?: { latitude: number; longitude: number };
  user_id?: number;
}

export interface AIResponse {
  response: string;
  type: "text" | "route" | "recommendations" | "comparison";
  data?: any;
}

// Generate response using Gemini
export const generateChatResponse = async (
  request: ChatRequest
): Promise<AIResponse> => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    // Build context for the AI
    const systemPrompt = `You are ShopRoute AI, a helpful shopping assistant. You help users:
1. Find the best stores for their shopping needs
2. Optimize shopping routes to save time and money
3. Recommend products based on preferences
4. Compare prices across stores
5. Create shopping lists

When a user asks about buying multiple products, identify the products and suggest optimizing the route.
When asked about dietary restrictions, recommend appropriate products.
Keep responses concise and helpful.

Current user location: ${
      request.user_location
        ? `${request.user_location.latitude}, ${request.user_location.longitude}`
        : "Unknown"
    }`;

    // Format conversation history
    const history = request.conversation_history.map((msg) => ({
      role: msg.role === "user" ? "user" : "model",
      parts: [{ text: msg.content }],
    }));

    const chat = model.startChat({
      history: [
        { role: "user", parts: [{ text: systemPrompt }] },
        {
          role: "model",
          parts: [
            {
              text: "Understood! I'm ShopRoute AI, ready to help you shop smarter and find the best routes. What do you need help with today?",
            },
          ],
        },
        ...history,
      ],
    });

    const result = await chat.sendMessage(request.message);
    const responseText = result.response.text();

    // Check if the message seems to be about route optimization
    const routeKeywords = [
      "need",
      "want",
      "buy",
      "get",
      "shopping",
      "list",
      "route",
      "plan",
    ];
    const isRouteRequest =
      routeKeywords.some((keyword) =>
        request.message.toLowerCase().includes(keyword)
      ) && request.message.includes(",");

    if (isRouteRequest && request.user_location) {
      // Try to extract products and optimize route
      const productNames = extractProductNames(request.message);
      if (productNames.length >= 2) {
        const routeResult = await optimizeShoppingRoute(
          productNames,
          request.user_location
        );
        if (routeResult) {
          return {
            response: `I found the best route for your shopping! Here's the optimized plan:`,
            type: "route",
            data: routeResult,
          };
        }
      }
    }

    return {
      response: responseText,
      type: "text",
    };
  } catch (error) {
    console.error("Gemini API error:", error);
    return {
      response:
        "I apologize, but I'm having trouble processing your request right now. Please try again.",
      type: "text",
    };
  }
};

// Extract product names from user message
const extractProductNames = (message: string): string[] => {
  // Remove common phrases and split by common delimiters
  const cleanMessage = message
    .toLowerCase()
    .replace(/i need|i want|buy|get|some|please|and|the|a|an/gi, "")
    .trim();

  const products = cleanMessage
    .split(/[,\s]+and\s+|,\s*|\s+/)
    .map((s) => s.trim())
    .filter((s) => s.length > 2);

  return [...new Set(products)]; // Remove duplicates
};

// Optimize shopping route for multiple products
export const optimizeShoppingRoute = async (
  productNames: string[],
  userLocation: { latitude: number; longitude: number }
): Promise<RouteResult | null> => {
  try {
    // Find products matching the names
    const productResults = await query(
      `SELECT p.id, p.name, p.image_url
       FROM products p
       WHERE ${productNames
         .map((_, i) => `p.name ILIKE $${i + 1}`)
         .join(" OR ")}`,
      productNames.map((n) => `%${n}%`)
    );

    if (productResults.rows.length === 0) {
      return null;
    }

    const productIds = productResults.rows.map((p) => p.id);

    // Find stores that have these products, with distance
    const stores = await query(
      `SELECT DISTINCT s.id, s.name, s.logo_url, s.address, s.rating,
              ST_Y(s.location::geometry) as latitude,
              ST_X(s.location::geometry) as longitude,
              ST_Distance(s.location::geography, ST_MakePoint($1, $2)::geography) as distance,
              array_agg(DISTINCT sp.product_id) as product_ids,
              json_agg(json_build_object(
                'product_id', sp.product_id,
                'price', sp.price,
                'stock_count', sp.stock_count
              )) as products
       FROM stores s
       JOIN store_products sp ON s.id = sp.store_id
       WHERE sp.product_id = ANY($3) AND sp.is_available = true AND s.is_active = true
       GROUP BY s.id
       ORDER BY distance`,
      [userLocation.longitude, userLocation.latitude, productIds]
    );

    if (stores.rows.length === 0) {
      return null;
    }

    // Greedy algorithm to find optimal route
    // Start with the store that has the most products
    const selectedStores: any[] = [];
    const remainingProducts = new Set(productIds);

    while (remainingProducts.size > 0 && stores.rows.length > 0) {
      // Find the store that covers the most remaining products
      let bestStore = null;
      let bestCoverage = 0;

      for (const store of stores.rows) {
        if (selectedStores.find((s) => s.id === store.id)) continue;

        const coverage = store.product_ids.filter((pid: number) =>
          remainingProducts.has(pid)
        ).length;

        if (coverage > bestCoverage) {
          bestCoverage = coverage;
          bestStore = store;
        }
      }

      if (!bestStore) break;

      selectedStores.push(bestStore);
      bestStore.product_ids.forEach((pid: number) =>
        remainingProducts.delete(pid)
      );
    }

    if (selectedStores.length === 0) {
      return null;
    }

    // Get route from OSRM
    const coordinates = [
      `${userLocation.longitude},${userLocation.latitude}`,
      ...selectedStores.map((s: any) => `${s.longitude},${s.latitude}`),
    ].join(";");

    const osrmResponse = await axios.get(
      `${OSRM_URL}/route/v1/driving/${coordinates}?overview=full&geometries=geojson`
    );

    const route = osrmResponse.data.routes[0];

    // Build result
    const stops: RouteStop[] = selectedStores.map(
      (store: any, index: number) => {
        const storeProducts = productResults.rows
          .filter((p) => store.product_ids.includes(p.id))
          .map((p) => {
            const priceInfo = store.products.find(
              (sp: any) => sp.product_id === p.id
            );
            return {
              ...p,
              price: priceInfo?.price || 0,
              stock_count: priceInfo?.stock_count || 0,
            };
          });

        return {
          store: {
            id: store.id,
            name: store.name,
            logo_url: store.logo_url,
            address: store.address,
            rating: store.rating,
            location: { latitude: store.latitude, longitude: store.longitude },
            is_active: true,
            review_count: 0,
            created_at: new Date(),
            updated_at: new Date(),
            distance: store.distance,
          },
          products: storeProducts,
          subtotal: storeProducts.reduce(
            (sum: number, p: any) => sum + p.price,
            0
          ),
          order: index + 1,
        };
      }
    );

    return {
      stops,
      total_distance: route.distance,
      total_time: route.duration,
      total_savings: 0, // Would need comparison with other routes
      polyline: route.geometry.coordinates.map((c: [number, number]) => [
        c[1],
        c[0],
      ]), // Flip to lat,lng
    };
  } catch (error) {
    console.error("Route optimization error:", error);
    return null;
  }
};

// Get product recommendations based on preferences
export const getRecommendations = async (
  preferences: string[],
  budget?: number,
  category?: number
): Promise<any[]> => {
  try {
    let queryText = `
      SELECT p.*, c.name as category_name,
             MIN(sp.price) as min_price, AVG(r.rating) as avg_rating
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN store_products sp ON p.id = sp.product_id
      LEFT JOIN reviews r ON p.id = r.product_id
      WHERE 1=1
    `;

    const params: any[] = [];

    if (category) {
      params.push(category);
      queryText += ` AND p.category_id = $${params.length}`;
    }

    queryText += " GROUP BY p.id, c.name";

    if (budget) {
      queryText += ` HAVING MIN(sp.price) <= ${budget}`;
    }

    queryText += " ORDER BY avg_rating DESC NULLS LAST LIMIT 20";

    const result = await query(queryText, params);
    return result.rows;
  } catch (error) {
    console.error("Recommendations error:", error);
    return [];
  }
};
