import { query } from "../config/database";

export const getProducts = async (
  category?: string,
  search?: string,
  minPrice?: number,
  maxPrice?: number,
  inStock?: boolean,
  sortBy: string = "name",
  page: number = 1,
  limit: number = 20
) => {
  const offset = (page - 1) * limit;
  let queryText = `
      SELECT DISTINCT p.*, c.name as category_name, c.icon as category_icon,
             MIN(sp.price) as min_price, MAX(sp.price) as max_price,
             COUNT(DISTINCT sp.store_id) as store_count,
             BOOL_OR(sp.is_available AND sp.stock_count > 0) as is_available,
             (ARRAY_AGG(sp.store_id ORDER BY sp.price ASC))[1] as store_id,
             (ARRAY_AGG(s.name ORDER BY sp.price ASC))[1] as store_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN store_products sp ON p.id = sp.product_id
      LEFT JOIN stores s ON sp.store_id = s.id
    `;

  const params: any[] = [];
  const conditions: string[] = [];

  if (category) {
    params.push(category);
    conditions.push(`p.category_id = $${params.length}`);
  }

  if (search) {
    params.push(`%${search}%`);
    conditions.push(
      `(p.name ILIKE $${params.length} OR p.description ILIKE $${params.length})`
    );
  }

  if (inStock) {
    conditions.push("sp.is_available = true AND sp.stock_count > 0");
  }

  if (conditions.length > 0) {
    queryText += " WHERE " + conditions.join(" AND ");
  }

  queryText += " GROUP BY p.id, c.name, c.icon";

  if (minPrice) {
    queryText += ` HAVING MIN(sp.price) >= ${minPrice}`;
  }
  if (maxPrice) {
    if (minPrice) {
      queryText += ` AND MAX(sp.price) <= ${maxPrice}`;
    } else {
      queryText += ` HAVING MAX(sp.price) <= ${maxPrice}`;
    }
  }

  switch (sortBy) {
    case "price_asc":
      queryText += " ORDER BY min_price ASC NULLS LAST";
      break;
    case "price_desc":
      queryText += " ORDER BY min_price DESC NULLS LAST";
      break;
    case "name":
    default:
      queryText += " ORDER BY p.name ASC";
  }

  // Count total
  const countResult = await query(
    `SELECT COUNT(DISTINCT p.id) FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN store_products sp ON p.id = sp.product_id
       ${conditions.length > 0 ? "WHERE " + conditions.join(" AND ") : ""}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  params.push(limit, offset);
  queryText += ` LIMIT $${params.length - 1} OFFSET $${params.length}`;

  const result = await query(queryText, params);

  return {
    items: result.rows,
    total,
    page,
    limit,
    total_pages: Math.ceil(total / limit),
  };
};

export const searchProductsAndStores = async (q: string, limit: number = 10) => {
  if (!q || q.length < 2) {
    return { products: [], stores: [] };
  }

  // 1. Try exact phrase match first
  let products = await query(
    `SELECT p.*, c.name as category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.name ILIKE $1 OR p.brand ILIKE $1
       ORDER BY p.name
       LIMIT $2`,
    [`%${q}%`, limit]
  );

  // 2. If no results, try splitting terms (e.g. "Coco cola" -> "Coco", "cola")
  if (products.rows.length === 0) {
      const terms = q.split(/\s+/).filter(t => t.length > 2);
      if (terms.length > 0) {
          const conditions = terms.map((_, i) => `(p.name ILIKE $${i + 1} OR p.description ILIKE $${i + 1})`).join(" OR "); 
          // Using OR for broader reach, or AND for stricter? 
          // "Coco cola" -> "Coca Cola". "Coco" fails, "Cola" matches. OR is better for fuzzy.
          
          products = await query(
            `SELECT p.*, c.name as category_name
               FROM products p
               LEFT JOIN categories c ON p.category_id = c.id
               WHERE ${conditions}
               ORDER BY p.name
               LIMIT $${terms.length + 1}`,
            [...terms.map(t => `%${t}%`), limit]
          );
      }
  }

  const stores = await query(
    `SELECT id, name, logo_url, address, rating
       FROM stores
       WHERE name ILIKE $1 OR address ILIKE $1
       ORDER BY rating DESC
       LIMIT $2`,
    [`%${q}%`, limit]
  );

  return {
    products: products.rows,
    stores: stores.rows,
  };
};

export const getProductDetails = async (id: string) => {
  const product = await query(
    `SELECT p.*, c.name as category_name, c.icon as category_icon
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = $1`,
    [id]
  );

  if (product.rows.length === 0) {
    return null;
  }

  const stores = await query(
    `SELECT s.id, s.name, s.logo_url, s.address, s.rating,
              sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
       FROM store_products sp
       JOIN stores s ON sp.store_id = s.id
       WHERE sp.product_id = $1 AND s.is_active = true
       ORDER BY sp.price ASC`,
    [id]
  );

  const reviewStats = await query(
    `SELECT 
         COUNT(*) as total_reviews,
         AVG(rating)::numeric(2,1) as avg_rating,
         COUNT(*) FILTER (WHERE rating = 5) as five_star,
         COUNT(*) FILTER (WHERE rating = 4) as four_star,
         COUNT(*) FILTER (WHERE rating = 3) as three_star,
         COUNT(*) FILTER (WHERE rating = 2) as two_star,
         COUNT(*) FILTER (WHERE rating = 1) as one_star
       FROM reviews WHERE product_id = $1`,
    [id]
  );

  return {
    product: product.rows[0],
    stores: stores.rows,
    review_stats: reviewStats.rows[0],
  };
};

export const addReview = async (
  userId: number,
  productId: string,
  rating: number,
  reviewText?: string,
  storeId?: string
) => {
  if (rating < 1 || rating > 5) throw new Error("Rating must be between 1 and 5");

  const existing = await query(
    "SELECT id FROM reviews WHERE user_id = $1 AND product_id = $2",
    [userId, productId]
  );

  if (existing.rows.length > 0) {
    throw new Error("You have already reviewed this product");
  }

  const result = await query(
    `INSERT INTO reviews (user_id, product_id, store_id, rating, review_text)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
    [userId, productId, storeId || null, rating, reviewText || null]
  );

  return result.rows[0];
};

export const getPersonalizedRecommendations = async (userId: number) => {
  // Get recent purchases/favorites for personalization
  const favorites = await query(
    `SELECT item_id FROM favorites
       WHERE user_id = $1 AND item_type = 'product'
       ORDER BY created_at DESC LIMIT 10`,
    [userId]
  );

  let result;
  if (favorites.rows.length > 0) {
    result = await query(
      `SELECT DISTINCT p.*, c.name as category_name,
                MIN(sp.price) as min_price, COUNT(DISTINCT r.id) as review_count
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN store_products sp ON p.id = sp.product_id
         LEFT JOIN reviews r ON p.id = r.product_id
         WHERE p.category_id IN (
           SELECT DISTINCT category_id FROM products WHERE id = ANY($1)
         )
         AND p.id NOT IN (SELECT item_id FROM favorites WHERE user_id = $2 AND item_type = 'product')
         GROUP BY p.id, c.name
         ORDER BY review_count DESC
         LIMIT 20`,
      [favorites.rows.map((f: any) => f.item_id), userId]
    );
  } else {
    // Default: trending products
    result = await query(
      `SELECT p.*, c.name as category_name,
                MIN(sp.price) as min_price, COUNT(DISTINCT r.id) as review_count
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN store_products sp ON p.id = sp.product_id
         LEFT JOIN reviews r ON p.id = r.product_id
         GROUP BY p.id, c.name
         ORDER BY review_count DESC
         LIMIT 20`
    );
  }

  return result.rows;
};
