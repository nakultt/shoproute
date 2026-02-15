import { query } from "../config/database";

export const getNearbyStores = async (
  lat: number,
  lng: number,
  radius: number = 5000,
  category?: string,
  limit: number = 50
) => {
  let queryText = `
      SELECT s.*,
             ST_Distance(s.location::geography, ST_MakePoint($1, $2)::geography) as distance
      FROM stores s
      WHERE s.is_active = true
        AND ST_DWithin(s.location::geography, ST_MakePoint($1, $2)::geography, $3)
    `;

  const params: any[] = [lng, lat, radius];

  if (category) {
    queryText += `
        AND EXISTS (
          SELECT 1 FROM store_products sp
          JOIN products p ON sp.product_id = p.id
          WHERE sp.store_id = s.id AND p.category_id = $4
        )`;
    params.push(category);
  }

  queryText += " ORDER BY distance ASC LIMIT $" + (params.length + 1);
  params.push(limit);

  const result = await query(queryText, params);

  return result.rows.map((store: any) => ({
    ...store,
    distance: Math.round(store.distance),
    distance_km: (store.distance / 1000).toFixed(2),
  }));
};

export const getStoresWithProduct = async (
  productId: string,
  lat?: number,
  lng?: number,
  sortBy: string = "price"
) => {
  let queryText = `
      SELECT s.*, sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
    `;

  const params: any[] = [productId];

  if (lat && lng) {
    queryText += `,
        ST_Distance(s.location::geography, ST_MakePoint($2, $3)::geography) as distance`;
    params.push(lng, lat);
  }

  queryText += `
      FROM store_products sp
      JOIN stores s ON sp.store_id = s.id
      WHERE sp.product_id = $1 AND s.is_active = true`;

  if (sortBy === "distance" && lat && lng) {
    queryText += " ORDER BY distance ASC";
  } else if (sortBy === "rating") {
    queryText += " ORDER BY s.rating DESC";
  } else {
    queryText += " ORDER BY sp.price ASC";
  }

  const result = await query(queryText, params);

  return result.rows.map((store: any) => ({
    ...store,
    distance_km: store.distance ? (store.distance / 1000).toFixed(2) : null,
  }));
};

export const getStoreDetails = async (id: string, lat?: number, lng?: number) => {
  let queryText = "SELECT s.*";
  const params: any[] = [id];

  if (lat && lng) {
    queryText += `,
        ST_Distance(s.location::geography, ST_MakePoint($2, $3)::geography) as distance`;
    params.push(lng, lat);
  }

  queryText += " FROM stores s WHERE s.id = $1";

  const store = await query(queryText, params);

  if (store.rows.length === 0) {
    return null;
  }

  const products = await query(
    `SELECT p.*, c.name as category_name,
              sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
       FROM store_products sp
       JOIN products p ON sp.product_id = p.id
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE sp.store_id = $1 AND sp.is_available = true
       ORDER BY p.name
       LIMIT 50`,
    [id]
  );

  const reviews = await query(
    `SELECT r.*, u.full_name as user_name, u.profile_picture as user_avatar
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.store_id = $1
       ORDER BY r.created_at DESC
       LIMIT 10`,
    [id]
  );

  const storeData = store.rows[0];
  if (storeData.distance) {
    storeData.distance_km = (storeData.distance / 1000).toFixed(2);
  }

  return {
    store: storeData,
    products: products.rows,
    reviews: reviews.rows,
  };
};

export const getAllStores = async (
  lat?: number,
  lng?: number,
  search?: string,
  minRating?: number,
  page: number = 1,
  limit: number = 20
) => {
  const offset = (page - 1) * limit;
  let queryText = "SELECT s.*";
  const params: any[] = [];
  const conditions: string[] = ["s.is_active = true"];

  if (lat && lng) {
    queryText += `,
        ST_Distance(s.location::geography, ST_MakePoint($1, $2)::geography) as distance`;
    params.push(lng, lat);
  }

  queryText += " FROM stores s";

  if (search) {
    params.push(`%${search}%`);
    conditions.push(
      `(s.name ILIKE $${params.length} OR s.address ILIKE $${params.length})`
    );
  }

  if (minRating) {
    params.push(minRating);
    conditions.push(`s.rating >= $${params.length}`);
  }

  queryText += " WHERE " + conditions.join(" AND ");

  if (lat && lng) {
    queryText += " ORDER BY distance ASC";
  } else {
    queryText += " ORDER BY s.rating DESC";
  }

  // Count total (separate query for simplicity, could be optimized)
  // Re-evaluating params for count query since it doesn't need distance/lat/lng if not filtering by it (but here we don't filter by distance in WHERE, just sort)
  // Actually, we need to be careful with params indices.
  // Let's reconstruct params for count to be safe or just use the same params and ignore the first 2 if they are lat/lng?
  // Easier to just run a separate clean query or handle logic carefully.
  // For now, let's copy logic:
  
  const countParams = [];
  const countConditions = ["s.is_active = true"];
  if (search) {
      countParams.push(`%${search}%`);
      countConditions.push(`(s.name ILIKE $${countParams.length} OR s.address ILIKE $${countParams.length})`);
  }
  if (minRating) {
      countParams.push(minRating);
      countConditions.push(`s.rating >= $${countParams.length}`);
  }

  const countResult = await query(
    `SELECT COUNT(*) FROM stores s WHERE ${countConditions.join(" AND ")}`,
    countParams
  );
  const total = parseInt(countResult.rows[0].count);

  params.push(limit, offset);
  queryText += ` LIMIT $${params.length - 1} OFFSET $${params.length}`;

  const result = await query(queryText, params);

  const stores = result.rows.map((store: any) => ({
    ...store,
    distance_km: store.distance ? (store.distance / 1000).toFixed(2) : null,
  }));

  return {
    items: stores,
    total,
    page,
    limit,
    total_pages: Math.ceil(total / limit),
  };
};
