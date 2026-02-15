import { GoogleGenerativeAI } from "@google/generative-ai";
import { query } from "../config/database";
import { RouteResult, RouteStop } from "../types";
import axios from "axios";
import * as storeService from "./storeService";
import * as cartService from "./cartService";
import * as productService from "./productService";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const OSRM_URL = process.env.OSRM_SERVER_URL || "http://router.project-osrm.org";

// Define Tools
const tools = [
  {
    function_declarations: [
      {
        name: "find_stores",
        description: "Find stores nearby based on location or search query. Use this when user asks 'where can I buy...', 'stores near me', or looks for specific shops.",
        parameters: {
          type: "OBJECT",
          properties: {
            location: {
              type: "OBJECT",
              properties: {
                lat: { type: "NUMBER" },
                lng: { type: "NUMBER" },
              },
              description: "User's current location. default to context location if available.",
            },
            query: {
              type: "STRING",
              description: "Search filter for store name (e.g., 'Walmart') or category (e.g., 'bakery').",
            },
            radius: {
              type: "NUMBER",
              description: "Search radius in meters (default 5000)",
            },
          },
          required: ["location"],
        },
      },
      {
        name: "add_to_cart",
        description: "Add a product to the shopping cart. EXTRACT ONLY THE PRODUCT NAME. Example: 'add milk to cart' -> product_name='milk'.",
        parameters: {
          type: "OBJECT",
          properties: {
            product_name: {
              type: "STRING",
              description: "The specific product name to find and add. Do not include 'add', 'buy', 'to cart' etc.",
            },
             store_name: {
              type: "STRING",
              description: "Preferred store name if specified.",
            },
            quantity: {
              type: "NUMBER",
              description: "Quantity to add (default 1)",
            },
            user_id: {
                type: "NUMBER",
                description: "User ID",
            }
          },
          required: ["product_name", "user_id"],
        },
      },
      {
        name: "view_cart",
        description: "Get the current items in the user's cart. Use this for requests like 'what is in my cart', 'show cart', 'check cart'.",
        parameters: {
          type: "OBJECT",
          properties: {
            user_id: { type: "NUMBER" },
          },
          required: ["user_id"],
        },
      },
      {
        name: "optimize_route",
        description: "Re-optimize the shopping route with specific constraints (e.g., max stores). Use this when user says 'only go to 2 stores' or 'I want to visit fewer shops'.",
        parameters: {
          type: "OBJECT",
          properties: {
            max_stores: {
              type: "NUMBER",
              description: "Maximum number of stores to visit.",
            },
            allow_missing_items: {
              type: "BOOLEAN",
              description: "Whether it is okay to leave some items unbought to meet the store limit.",
            },
          },
          required: ["max_stores"],
        },
      },
      {
        name: "get_store_products",
        description: "Get a list of products available at a specific store. Use this when user asks 'what is sold at [Store Name]?' or 'inventory of [Store Name]'.",
        parameters: {
          type: "OBJECT",
          properties: {
             store_name: {
               type: "STRING",
               description: "Name of the store to search for.",
             },
             location: {
               type: "OBJECT",
               properties: {
                 lat: { type: "NUMBER" },
                 lng: { type: "NUMBER" },
               },
               description: "User's current location (optional, helps find nearest match).",
             },
          },
          required: ["store_name"],
        },
      },
    ],
  },
];

const systemInstruction = `You are ShopRoute's AI shopping assistant.
Your role is to help users find products, manage their cart, and locate stores.
You have access to real-time tools.
RULES:
1. ALWAYS use the \`view_cart\` tool when the user asks about their cart content.
2. ALWAYS use the \`add_to_cart\` tool when the user wants to buy something.
3. When extracting \`product_name\` for \`add_to_cart\`, be concise. Remove filler words.
   - "Add coca cola to cart" -> "coca cola"
   - "buy some milk" -> "milk"
4. If a tool call fails (e.g., product not found), apologize and suggest alternatives or ask for clarification.
5. Keep responses concise and helpful.`;

const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
  systemInstruction: systemInstruction,
  tools: tools as any,
});

export interface ChatRequest {
  message: string;
  conversation_history: { role: "user" | "model"; parts: { text: string }[] }[];
  user_location?: { latitude: number; longitude: number };
  user_id?: number;
  context_products?: string[];
}

export interface AIResponse {
  response: string;
  type: "text" | "action_result" | "route" | "recommendations" | "comparison";
  data?: any;
}

export const generateChatResponse = async (
  request: ChatRequest
): Promise<AIResponse> => {
  console.log("GenerateChatResponse Request:", JSON.stringify({ 
      message: request.message, 
      context_products: request.context_products,
      user_location: request.user_location 
  }, null, 2));

  try {
    let history = request.conversation_history.map((h: any) => ({
        role: (h.role as string) === 'assistant' ? 'model' : h.role,
        parts: h.parts || [{ text: h.content }] // Handle both formats
    }));

    // VALIDATION: Gemini history must start with 'user'
    if (history.length > 0 && history[0].role === 'model') {
        history.unshift({
            role: 'user',
            parts: [{ text: "Context: Previous conversation started." }]
        });
    }

    const chat = model.startChat({
      history: history as any,
    });

    // Provide context about user
    let msgWithContext = request.message;
    if (request.user_location) {
        msgWithContext += `\n[Context: User Location: ${request.user_location.latitude}, ${request.user_location.longitude}]`;
    }
    if (request.user_id) {
        msgWithContext += `\n[Context: User ID: ${request.user_id}]`;
    }

    const result = await chat.sendMessage(msgWithContext);
    const response = result.response;
    const functionCalls = response.functionCalls();

    if (functionCalls && functionCalls.length > 0) {
      // Handle Function Calls
      const call = functionCalls[0];
      const args: any = call.args;

      if (call.name === "find_stores") {
        if (!args.location && request.user_location) {
             args.location = { lat: request.user_location.latitude, lng: request.user_location.longitude };
        }
        
        if (args.location) {
             const stores = await storeService.getNearbyStores(
                args.location.lat,
                args.location.lng,
                args.radius || 5000,
                undefined, // category
                5 // limit
            );
            
            // Feed result back to Gemini
            const resultParts = [
                {
                    functionResponse: {
                        name: "find_stores",
                        response: {
                           stores: stores.map((s: any) => ({ name: s.name, distance: s.distance_km + "km", address: s.address }))
                        }
                    }
                }
            ];
            
            const finalResult = await chat.sendMessage(resultParts);
            return {
                response: finalResult.response.text(),
                type: "action_result",
                data: stores
            };
        }
      }

      if (call.name === "view_cart") {
          const userId = args.user_id || request.user_id;
          if (userId) {
              const cart = await cartService.getCart(userId);
              
               const resultParts = [
                {
                    functionResponse: {
                        name: "view_cart",
                        response: {
                           items: cart.items.map((i: any) => `${i.quantity}x ${i.product_name} from ${i.store_name}`),
                           total: cart.subtotal
                        }
                    }
                }
            ];
             const finalResult = await chat.sendMessage(resultParts);
             return {
                 response: finalResult.response.text(),
                 type: "action_result",
                 data: cart
             };
          }
      }

      if (call.name === "add_to_cart") {
          const userId = args.user_id || request.user_id;
          if (userId && args.product_name) {
              // 1. Find product ID (fuzzy search)
              const searchRes = await productService.searchProductsAndStores(args.product_name, 1);
              if (searchRes.products.length > 0) {
                  const product = searchRes.products[0];
                  
                  // 2. Find store ID (if not provided, pick best one or ask?)
                  // For now, let's pick the first store that has it near user
                  let storeId = null;
                  if (request.user_location) {
                       const stores = await storeService.getStoresWithProduct(
                           product.id, 
                           request.user_location.latitude,
                           request.user_location.longitude
                       );
                       if (stores.length > 0) storeId = stores[0].id;
                  }
                  
                  if (storeId) {
                      await cartService.addToCart(userId, product.id, storeId, args.quantity || 1);
                       const resultParts = [
                            {
                                functionResponse: {
                                    name: "add_to_cart",
                                    response: { success: true, message: `Added ${product.name} to cart.` }
                                }
                            }
                        ];
                        const finalResult = await chat.sendMessage(resultParts);
                        return {
                            response: finalResult.response.text(),
                            type: "action_result",
                            data: { product, storeId }
                        };
                  } else {
                        // Return error to AI
                         const resultParts = [{
                                functionResponse: {
                                    name: "add_to_cart",
                                    response: { success: false, message: "Found product but no nearby store has it in stock." }
                                }
                            }];
                         const finalResult = await chat.sendMessage(resultParts);
                         return { response: finalResult.response.text(), type: "text" };
                  }
              } else {
                   const resultParts = [{
                        functionResponse: {
                            name: "add_to_cart",
                            response: { success: false, message: "Product not found." }
                        }
                    }];
                   const finalResult = await chat.sendMessage(resultParts);
                   return { response: finalResult.response.text(), type: "text" };
              }
          }
      }
      if (call.name === "optimize_route") {
          let productsToOptimize: string[] = [];
          let constraints: RouteConstraint[] = [];

          // 1. Try to fetch from current Cart (Source of Truth)
          const userId = request.user_id;
          if (userId) {
              try {
                  const cart = await cartService.getCart(userId);
                  if (cart && cart.items.length > 0) {
                      productsToOptimize = cart.items.map((i: any) => i.product_name);
                      // Create constraints for each item to respect the chosen store
                      constraints = cart.items.map((i: any) => ({
                          product: i.product_name,
                          store: i.store_name
                      }));
                  }
              } catch (e) {
                  console.warn("Failed to fetch cart for optimization:", e);
              }
          }

          // 2. Fallback to context_products if cart is empty/failed
          if (productsToOptimize.length === 0 && request.context_products && request.context_products.length > 0) {
               productsToOptimize = request.context_products;
               // No constraints if falling back to context (we don't know the stores)
          }

          if (productsToOptimize.length === 0) {
               const resultParts = [{
                    functionResponse: {
                        name: "optimize_route",
                        response: { success: false, message: "I couldn't find any items to optimize. Please add items to your cart or use 'Find Route' first." }
                    }
                }];
               const finalResult = await chat.sendMessage(resultParts);
               return { response: finalResult.response.text(), type: "text" };
          }
           
          const maxStores = args.max_stores;
          const allowMissing = args.allow_missing_items || false;
          
          if (request.user_location) {
              const route = await optimizeShoppingRoute(
                  productsToOptimize,
                  { latitude: request.user_location.latitude, longitude: request.user_location.longitude },
                  constraints, // Pass the constraints!
                  maxStores,
                  allowMissing
              );
              
              if (route) {
                   const resultParts = [{
                        functionResponse: {
                            name: "optimize_route",
                            response: { 
                                success: true, 
                                message: `Calculated new route with ${route.stops.length} stops.`,
                                total_distance: route.total_distance,
                                total_time: route.total_time
                            }
                        }
                   }];
                   const finalResult = await chat.sendMessage(resultParts);
                   return { 
                       response: finalResult.response.text(), 
                       type: "route", 
                       data: route 
                   };
              } else {
                   const resultParts = [{
                        functionResponse: {
                            name: "optimize_route",
                            response: { success: false, message: "Could not find a route meeting these constraints." }
                        }
                   }];
                   const finalResult = await chat.sendMessage(resultParts);
                   return { response: finalResult.response.text(), type: "text" };
              }
          }
      }
      if (call.name === "get_store_products") {
          const storeName = args.store_name;
          // 1. Find the store
          let lat = request.user_location?.latitude;
          let lng = request.user_location?.longitude;
          if (args.location) {
             lat = args.location.lat;
             lng = args.location.lng;
          }

          const storesSearchResult = await storeService.getAllStores(lat, lng, storeName, undefined, 1, 1);
          
          if (storesSearchResult.items.length > 0) {
              const store = storesSearchResult.items[0];
              // 2. Get details (products)
              const details = await storeService.getStoreDetails(store.id.toString(), lat, lng);
              
              if (details && details.products.length > 0) {
                   const productList = details.products.map((p: any) => 
                       `- ${p.name} (₹${p.price}) [${p.is_available ? 'In Stock' : 'Out of Stock'}]`
                   ).join("\n");

                   const resultParts = [{
                        functionResponse: {
                            name: "get_store_products",
                            response: { 
                                found: true, 
                                store_name: store.name,
                                products: productList
                            }
                        }
                   }];
                   const finalResult = await chat.sendMessage(resultParts);
                   return { response: finalResult.response.text(), type: "text" };
              } else {
                   const resultParts = [{
                        functionResponse: {
                            name: "get_store_products",
                            response: { found: true, store_name: store.name, message: "Store found, but no products listed." }
                        }
                   }];
                   const finalResult = await chat.sendMessage(resultParts);
                   return { response: finalResult.response.text(), type: "text" };
              }
          } else {
               const resultParts = [{
                    functionResponse: {
                        name: "get_store_products",
                        response: { found: false, message: `Could not find any store named '${storeName}'.` }
                    }
               }];
               const finalResult = await chat.sendMessage(resultParts);
               return { response: finalResult.response.text(), type: "text" };
          }
      }
    }

    return {
      response: result.response.text(),
      type: "text",
    };

  } catch (error: any) {
    console.error("Gemini API error:", error);
    if (error.response) {
      console.error("Error details:", JSON.stringify(error.response, null, 2));
    }
    return {
      response: "I'm having trouble connecting to my brain right now. (Error: " + (error.message || "Unknown") + ")",
      type: "text",
    };
  }
};

// --- LEGACY FUNCTIONS (Preserved for compatibility) ---

interface RouteConstraint {
    product: string;
    store: string;
}

export const optimizeShoppingRoute = async (
  productNames: string[],
  userLocation: { latitude: number; longitude: number },
  constraints: RouteConstraint[] = [],
  maxStores?: number,
  allowMissingItems: boolean = false
): Promise<RouteResult | null> => {
  try {
    // 0. Validate input
    if (!productNames || productNames.length === 0) {
        return null;
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

    const allProductIds = productResults.rows.map((p: any) => p.id);

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
        const s = stores.rows.find((row: any) => row.name.toLowerCase().includes(name.toLowerCase()));
        return s ? s.id : null;
    };

    // A. Apply Constraints first
    for (const constraint of constraints) {
        const targetStoreId = findStoreIdByName(constraint.store);
        const productKey = constraint.product.toLowerCase();
        const possibleIds = productMap.get(productKey) || [];

        if (targetStoreId && possibleIds.length > 0) {
            const storeRow = stores.rows.find((r: any) => r.id === targetStoreId);
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
    const remainingSet = new Set(remainingNames.map(n => n.toLowerCase()));

    while (remainingSet.size > 0) {
        // BREAK condition for max stores
        if (maxStores && selectedStores.length >= maxStores) {
            if (!allowMissingItems) {
                // If we can't miss items and hit the limit, strictly speaking we failed.
                // But for "I don't care if I miss items", we just stop adding stores.
                console.log("Hit max stores limit, stopping greedy selection.");
            }
            break;
        }

        let bestStore = null;
        let bestCoverCount = 0;
        let bestCoveredNames: string[] = [];

        for (const store of stores.rows) {
             // Skip if already selected
             if (selectedStores.find(s => s.id === store.id)) continue;

             // Calculate how many *remaining* product names this store fulfills
             const coveredNames: string[] = [];
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

        selectedStores.push(bestStore);
        bestCoveredNames.forEach(n => remainingSet.delete(n));
    }
    
    if (selectedStores.length === 0) return null;

    // 4. Get route from OSRM
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
        routeData.geometry.coordinates = [
            [userLocation.longitude, userLocation.latitude],
            ...selectedStores.map((s: any) => [s.longitude, s.latitude])
        ];
        let totalDist = 0;
        for (const s of selectedStores) {
            totalDist += s.distance;
        }
        routeData.distance = totalDist;
        routeData.duration = totalDist / 10;
    }

    const stops: RouteStop[] = selectedStores.map((store: any, index: number) => {
      const storeProducts = productResults.rows
        .filter((p: any) => store.product_ids.includes(p.id))
        .filter((p: any) => productNames.some((reqName: string) => p.name.toLowerCase().includes(reqName.toLowerCase())))
        .map((p: any) => {
          const priceInfo = store.products.find((sp: any) => sp.product_id === p.id);
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
        subtotal: storeProducts.reduce((sum: number, p: any) => sum + p.price, 0),
        order: index + 1,
      } as RouteStop;
    });

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
