
import dotenv from "dotenv";
dotenv.config();

import { query } from "../config/database";

async function debug() {
  console.log("--- DEBUGGING ROUTE OPTIMIZATION ---");

  const productNames = ["Milk", "Bread"];
  console.log(`Searching for products: ${productNames.join(", ")}`);

  try {
    // 1. Check Products
    const productResults = await query(
      `SELECT p.id, p.name FROM products p WHERE ${productNames
        .map((_, i) => `p.name ILIKE $${i + 1}`)
        .join(" OR ")}`,
      productNames.map((n) => `%${n}%`)
    );

    console.log(`Found ${productResults.rows.length} products:`);
    productResults.rows.forEach((p: any) => console.log(` - ID: ${p.id}, Name: ${p.name}`));

    if (productResults.rows.length === 0) {
        console.log("!!! NO PRODUCTS FOUND !!!");
        console.log("Checking total products count...");
        const all = await query("SELECT count(*) FROM products");
        console.log(`Total products in DB: ${all.rows[0].count}`);
        return;
    }

    const allProductIds = productResults.rows.map((p: any) => p.id);

    // 2. Check Stores
    console.log(`Checking stores for product IDs: ${allProductIds.join(", ")}`);
    // Simplified query
    const stores = await query(
        `SELECT s.id, s.name, array_agg(sp.product_id) as pids
         FROM stores s
         JOIN store_products sp ON s.id = sp.store_id
         WHERE sp.product_id = ANY($1)
         GROUP BY s.id`,
        [allProductIds]
    );

    console.log(`Found ${stores.rows.length} stores with these products:`);
    stores.rows.forEach((s: any) => console.log(` - Store: ${s.name} (IDs: ${s.pids.join(", ")})`));

    if (stores.rows.length === 0) {
        console.log("!!! NO STORES FOUND WITH THESE PRODUCTS !!!");
        console.log("Checking total stores count...");
        const allStores = await query("SELECT count(*) FROM stores");
        console.log(`Total stores in DB: ${allStores.rows[0].count}`);
        
        console.log("Checking total store_products count...");
        const allSP = await query("SELECT count(*) FROM store_products");
        console.log(`Total store_products entries in DB: ${allSP.rows[0].count}`);
    }

  } catch (e) {
    console.error("Error during debug:", e);
  } finally {
      process.exit();
  }
}

debug();
