import { GoogleGenerativeAI } from "@google/generative-ai";
import { query } from "../config/database";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

export interface ExtractedIngredient {
  name: string;
  quantity: number | null;
  unit: string | null;
  product_id?: number;
  available_at_stores?: {
    store_id: number;
    store_name: string;
    price: number;
  }[];
}

export interface RecipeSuggestion {
  name: string;
  description: string;
  prep_time: number;
  cook_time: number;
  servings: number;
  difficulty: string;
  ingredients: { name: string; quantity: string; have_it: boolean }[];
  missing_ingredients: string[];
  instructions: string[];
  use_before_expires: string[];
}

export interface SubstitutionSuggestion {
  product_id?: number;
  name: string;
  price?: string;
  reason: string;
  similarity_score: number;
}

// Extract ingredients from text (recipe, shopping list, etc.) using AI
export const extractIngredients = async (
  text: string
): Promise<ExtractedIngredient[]> => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    const prompt = `Extract ingredients from the following text. For each ingredient, identify:
1. Name (just the ingredient name, no quantity)
2. Quantity (number only, or null if not specified)
3. Unit (cups, tablespoons, pieces, kg, lbs, etc., or null if not specified)

Text: "${text}"

Respond ONLY with a JSON array in this exact format, no other text:
[
  {"name": "milk", "quantity": 2, "unit": "cups"},
  {"name": "eggs", "quantity": 3, "unit": null}
]`;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();

    // Parse JSON from response
    const jsonMatch = responseText.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      console.error("No JSON found in AI response");
      return [];
    }

    const ingredients: ExtractedIngredient[] = JSON.parse(jsonMatch[0]);

    // Try to match with products in database
    for (const ingredient of ingredients) {
      const productMatch = await query(
        `SELECT p.id, p.name FROM products p WHERE p.name ILIKE $1 LIMIT 1`,
        [`%${ingredient.name}%`]
      );

      if (productMatch.rows.length > 0) {
        ingredient.product_id = productMatch.rows[0].id;

        // Find stores with this product
        const stores = await query(
          `SELECT sp.store_id, s.name as store_name, sp.price
           FROM store_products sp
           JOIN stores s ON sp.store_id = s.id
           WHERE sp.product_id = $1 AND sp.is_available = true
           ORDER BY sp.price ASC
           LIMIT 3`,
          [ingredient.product_id]
        );

        ingredient.available_at_stores = stores.rows;
      }
    }

    return ingredients;
  } catch (error) {
    console.error("Extract ingredients error:", error);
    return [];
  }
};

// Get recipe suggestions based on available ingredients
export const getRecipeSuggestions = async (
  ingredients: string[]
): Promise<RecipeSuggestion[]> => {
  try {
    if (ingredients.length === 0) {
      return [];
    }

    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    const prompt = `Given these available ingredients: ${ingredients.join(", ")}

Suggest 3 recipes that can be made with these ingredients. Prioritize recipes that:
1. Use ingredients that might expire soon (dairy, produce, meat)
2. Require minimal additional ingredients
3. Are practical and delicious

For each recipe, provide:
1. Name
2. Brief description
3. Prep time (minutes)
4. Cook time (minutes)
5. Servings
6. Difficulty (easy/medium/hard)
7. Full ingredient list with quantities (mark which ones the user has)
8. Step-by-step instructions

Respond ONLY with a JSON array in this format:
[
  {
    "name": "Recipe Name",
    "description": "Brief description",
    "prep_time": 15,
    "cook_time": 30,
    "servings": 4,
    "difficulty": "easy",
    "ingredients": [
      {"name": "milk", "quantity": "2 cups", "have_it": true},
      {"name": "butter", "quantity": "2 tbsp", "have_it": false}
    ],
    "missing_ingredients": ["butter"],
    "instructions": ["Step 1...", "Step 2..."],
    "use_before_expires": ["milk", "eggs"]
  }
]`;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();

    // Parse JSON from response
    const jsonMatch = responseText.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      console.error("No JSON found in AI response");
      return [];
    }

    const recipes: RecipeSuggestion[] = JSON.parse(jsonMatch[0]);
    return recipes;
  } catch (error) {
    console.error("Get recipe suggestions error:", error);
    return [];
  }
};

// Generate smart substitutions for a product
export const generateSubstitutions = async (
  product: any
): Promise<SubstitutionSuggestion[]> => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    // Get similar products from database for context
    const similarProducts = await query(
      `SELECT p.id, p.name, p.brand, MIN(sp.price) as price
       FROM products p
       JOIN store_products sp ON p.id = sp.product_id
       WHERE p.category_id = $1 AND p.id != $2 AND sp.is_available = true AND sp.stock_count > 0
       GROUP BY p.id
       ORDER BY p.name
       LIMIT 20`,
      [product.category_id, product.id]
    );

    const availableProducts = similarProducts.rows
      .map(
        (p) =>
          `${p.name} (${p.brand || "No brand"}) - $${parseFloat(
            p.price
          ).toFixed(2)}`
      )
      .join("\n");

    const prompt = `The user wants to buy: "${product.name}" (${
      product.brand || "No brand"
    })
${product.description ? `Description: ${product.description}` : ""}

This product is out of stock. Suggest the best 3 substitutes from these available products:

${availableProducts}

For each substitute, explain:
1. Why it's a good alternative (taste, texture, nutrition, etc.)
2. Price comparison (budget-friendly, similar price, premium)
3. Key differences to note

Respond ONLY with a JSON array in this format:
[
  {
    "name": "Product Name",
    "reason": "Creamy texture, similar nutrition, trending choice",
    "similarity_score": 0.85
  }
]

Similarity score should be between 0 and 1, where 1 is most similar.`;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();

    // Parse JSON from response
    const jsonMatch = responseText.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      console.error("No JSON found in AI response");
      return [];
    }

    const suggestions: SubstitutionSuggestion[] = JSON.parse(jsonMatch[0]);

    // Match with actual products
    for (const suggestion of suggestions) {
      const match = similarProducts.rows.find(
        (p) =>
          p.name.toLowerCase().includes(suggestion.name.toLowerCase()) ||
          suggestion.name.toLowerCase().includes(p.name.toLowerCase())
      );

      if (match) {
        suggestion.product_id = match.id;
        suggestion.price = `$${parseFloat(match.price).toFixed(2)}`;
      }
    }

    return suggestions.filter((s) => s.product_id); // Only return matched products
  } catch (error) {
    console.error("Generate substitutions error:", error);
    return [];
  }
};

// Calculate total cost for shopping list
export const calculateShoppingCost = async (
  items: { product_id: number; quantity: number }[],
  userLocation?: { latitude: number; longitude: number }
): Promise<{
  total: number;
  by_store: {
    store_id: number;
    store_name: string;
    items: any[];
    subtotal: number;
  }[];
  savings: number;
  optimized_route?: any;
}> => {
  try {
    let totalCost = 0;
    let totalSavings = 0;
    const storeItems: Map<number, any[]> = new Map();

    for (const item of items) {
      // Find cheapest store for this product
      const priceResult = await query(
        `SELECT sp.*, s.id as store_id, s.name as store_name, p.name as product_name
         FROM store_products sp
         JOIN stores s ON sp.store_id = s.id
         JOIN products p ON sp.product_id = p.id
         WHERE sp.product_id = $1 AND sp.is_available = true AND sp.stock_count >= $2
         ORDER BY sp.price ASC
         LIMIT 1`,
        [item.product_id, item.quantity]
      );

      if (priceResult.rows.length > 0) {
        const best = priceResult.rows[0];
        const itemTotal = best.price * item.quantity;
        totalCost += itemTotal;

        if (best.compare_at_price) {
          totalSavings += (best.compare_at_price - best.price) * item.quantity;
        }

        const storeId = best.store_id;
        if (!storeItems.has(storeId)) {
          storeItems.set(storeId, []);
        }
        storeItems.get(storeId)!.push({
          ...best,
          quantity: item.quantity,
          item_total: itemTotal,
        });
      }
    }

    const byStore = Array.from(storeItems.entries()).map(
      ([storeId, items]) => ({
        store_id: storeId,
        store_name: items[0].store_name,
        items,
        subtotal: items.reduce((sum, i: any) => sum + i.item_total, 0),
      })
    );

    return {
      total: totalCost,
      by_store: byStore,
      savings: totalSavings,
    };
  } catch (error) {
    console.error("Calculate shopping cost error:", error);
    return { total: 0, by_store: [], savings: 0 };
  }
};
