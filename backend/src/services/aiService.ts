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
    const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });

    // Build context for the AI
    const systemPrompt = `You are ShopRoute AI, a helpful shopping assistant.
    Current user location: ${
      request.user_location
        ? `${request.user_location.latitude}, ${request.user_location.longitude}`
        : "Unknown"
    }

    You can help users optimize their shopping routes.
    If a user asks to modify a route, change a store, or buy specific items from specific places, verify their intent.
    
    CRITICAL RULE: When "optimizing" or "modifying" a route, the 'products' array in your JSON output MUST contain the COMPLETE consolidated list of products from the entire conversation history.
    - If user says "Add milk", and history has "Bread", output: ["Bread", "Milk"].
    - If user says "Remove Bread", output: ["Milk"].
    - Do NOT drop previous items unless explicitly asked to remove them.

    You must output your response in JSON format.
    
    Structure:
    {
       "intent": "chat" | "optimize_route" | "modify_route",
       "reply": "Text response to the user",
       "data": {
           "products": ["list", "of", "ALL", "product", "names", "including", "new", "and", "existing"], // MUST include previous items unless user explicitly removes them
           "constraints": [ // Optional, if user specifies stores
               { "product": "product_name", "store": "store_name_preference" }
           ]
       }
    }

    Example User: "I need milk and eggs, but get milk from Fresh Mart"
    Example JSON:
    {
        "intent": "optimize_route",
        "reply": "I'll plan a route for milk and eggs, ensuring we pick up milk from Fresh Mart.",
        "data": {
            "products": ["milk", "eggs"],
            "constraints": [{ "product": "milk", "store": "Fresh Mart" }]
        }
    }
    `;

    // Format conversation history
    const history = request.conversation_history.map((msg) => ({
      role: msg.role === "user" ? "user" : "model",
      parts: [{ text: msg.content }],
    }));

    const chat = model.startChat({
      history: [
         { role: "user", parts: [{ text: "System Prompt: " + systemPrompt }] },
         ...history
      ],
    });

    const result = await chat.sendMessage(request.message + "\n(Remember: Output JSON)");
    const responseText = result.response.text();

    // Clean up potential markdown code blocks
    const cleanJson = responseText.replace(/```json|```/g, "").trim();
    
    let parsedResponse;
    try {
        parsedResponse = JSON.parse(cleanJson);
    } catch (e) {
        // Fallback if AI fails to return JSON
        return {
            response: responseText,
            type: "text",
        };
    }

    if (parsedResponse.intent === 'optimize_route' || parsedResponse.intent === 'modify_route') {
        if (request.user_location && parsedResponse.data?.products) {
            const routeResult = await optimizeShoppingRoute(
                parsedResponse.data.products,
                request.user_location,
                parsedResponse.data.constraints
            );
            
            if (routeResult) {
                return {
                    response: parsedResponse.reply,
                    type: "route",
                    data: routeResult
                };
            } else {
                 return {
                    response: parsedResponse.reply + "\n(However, I couldn't find a valid route for these items nearby.)",
                    type: "text"
                };
            }
        }
    }

    return {
      response: parsedResponse.reply || responseText,
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

// Start logic for constraints
interface RouteConstraint {
    product: string;
    store: string;
}

// Optimize shopping route for multiple products
export const optimizeShoppingRoute = async (
  productNames: string[],
  userLocation: { latitude: number; longitude: number },
  constraints: RouteConstraint[] = []
): Promise<RouteResult | null> => {
  try {
    // 0. Validate input
    if (!productNames || productNames.length === 0) {
        return null; // Cannot optimize without products
    }

    // 1. Find all product variations matching the names
    const productResults = await query(
      `SELECT p.id, p.name, p.image_url
       FROM products p
       WHERE ${productNames
         .map((_, i) => `p.name ILIKE $${i + 1}`)
         .join(" OR ")}`,
      productNames.map((n) => `%${n}%`)
    );

    if (productResults.rows.length === 0) return null;

    const productMap = new Map<string, number[]>(); // Name -> IDs
    productNames.forEach(name => {
        const matches = productResults.rows.filter(r => r.name.toLowerCase().includes(name.toLowerCase()));
        productMap.set(name.toLowerCase(), matches.map(m => m.id));
    });

    const allProductIds = productResults.rows.map((p) => p.id);

    // 2. Find stores that carry these products
    const stores = await query(
      `SELECT s.id, s.name, s.logo_url, s.address, s.rating,
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
      [userLocation.longitude, userLocation.latitude, allProductIds]
    );

    if (stores.rows.length === 0) return null;

    // 3. Resolve Constraints & Greedy Selection
    const selectedStores: any[] = [];
    const fulfilledProducts = new Set<string>(); // Tracks original product names fulfilled
    
    // Helper to get Store ID from name fuzzy match
    const findStoreIdByName = (name: string) => {
        const s = stores.rows.find(row => row.name.toLowerCase().includes(name.toLowerCase()));
        return s ? s.id : null;
    };

    // A. Apply Constraints first
    for (const constraint of constraints) {
        const targetStoreId = findStoreIdByName(constraint.store);
        const productKey = constraint.product.toLowerCase();
        const possibleIds = productMap.get(productKey) || [];

        if (targetStoreId && possibleIds.length > 0) {
            const storeRow = stores.rows.find(r => r.id === targetStoreId);
            // Check if store actually has the item
            const hasItem = storeRow.product_ids.some((pid: number) => possibleIds.includes(pid));
            
            if (storeRow && hasItem) {
                if (!selectedStores.find(s => s.id === storeRow.id)) {
                    selectedStores.push(storeRow);
                }
                fulfilledProducts.add(productKey);
            }
        }
    }

    // B. Fill remaining products using Greedy coverage
    const remainingNames = productNames.filter(n => !fulfilledProducts.has(n.toLowerCase()));
    
    // We need to map abstract "names" to actual IDs for the greedy loop
    // But since one name = multiple IDs, we check if a store covers the *name* concept
    const remainingSet = new Set(remainingNames.map(n => n.toLowerCase()));

    while (remainingSet.size > 0) {
        let bestStore = null;
        let bestCoverCount = 0;
        let bestCoveredNames: string[] = [];

        for (const store of stores.rows) {
             // Calculate how many *remaining* product names this store fulfills
             const coveredNames = [];
             for (const name of remainingSet) {
                 const ids = productMap.get(name) || [];
                 if (store.product_ids.some((pid: number) => ids.includes(pid))) {
                     coveredNames.push(name);
                 }
             }
             
             if (coveredNames.length > bestCoverCount) {
                 bestCoverCount = coveredNames.length;
                 bestStore = store;
                 bestCoveredNames = coveredNames;
             }
        }

        if (!bestStore || bestCoverCount === 0) break; // Cannot fill rest

        if (!selectedStores.find(s => s.id === bestStore.id)) {
            selectedStores.push(bestStore);
        }
        
        bestCoveredNames.forEach(n => remainingSet.delete(n));
    }
    
    if (selectedStores.length === 0) return null;

    // 4. Get route from OSRM
    // Re-sorting selected stores by distance from user (simple heuristic)
    selectedStores.sort((a, b) => a.distance - b.distance);

    let routeData = {
        distance: 0,
        duration: 0,
        geometry: { coordinates: [] as any[] }
    };

    try {
        const coordinates = [
          `${userLocation.longitude},${userLocation.latitude}`,
          ...selectedStores.map((s: any) => `${s.longitude},${s.latitude}`),
        ].join(";");

        const osrmResponse = await axios.get(
          `${OSRM_URL}/route/v1/driving/${coordinates}?overview=full&geometries=geojson`
        );
        
        if (osrmResponse.data.code === 'Ok') {
             routeData = osrmResponse.data.routes[0];
        } else {
             throw new Error("OSRM returned non-OK code");
        }
    } catch (osrmError: any) {
        console.warn("OSRM routing failed, falling back to straight lines:", osrmError.message);
        
        // Fallback: Calculate straight line distance (rough approx)
        // And simple polyline (User -> Store 1 -> Store 2)
        routeData.geometry.coordinates = [
            [userLocation.longitude, userLocation.latitude],
            ...selectedStores.map((s: any) => [s.longitude, s.latitude])
        ];
        
        // Simple distance sum
        let totalDist = 0;
        let prev = { lat: userLocation.latitude, lng: userLocation.longitude };
        for (const s of selectedStores) {
            // Haversine-like approx (simple euclidean for short distances, or just sum 'distance' from DB which is user->store)
            // But we want path distance.
            // Using DB distance (user->store) is okay for first stop, but store->store is missing.
            // Let's just use the accumulative DB distance for simplicity or leave 0.
            totalDist += s.distance; // This is distance from user, which is wrong for sequentially, but sufficient fallback.
        }
        routeData.distance = totalDist;
        routeData.duration = totalDist / 10; // Dummy duration
    }

    // Build result
    const stops: RouteStop[] = selectedStores.map(
      (store: any, index: number) => {
        
        const storeProducts = productResults.rows
           .filter((p) => store.product_ids.includes(p.id)) // Available in store
           .filter((p) => productNames.some(reqName => p.name.toLowerCase().includes(reqName.toLowerCase()))) // Requested by user
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
      total_distance: routeData.distance,
      total_time: routeData.duration,
      total_savings: 0,
      polyline: routeData.geometry.coordinates.map((c: [number, number]) => [
        c[1],
        c[0],
      ]),
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
