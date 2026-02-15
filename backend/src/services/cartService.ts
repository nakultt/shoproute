import { query } from "../config/database";

export const getCart = async (userId: number) => {
  const result = await query(
    `SELECT ci.*, 
            p.name as product_name, p.image_url as product_image,
            s.name as store_name, s.logo_url as store_logo,
            sp.price, sp.compare_at_price, sp.stock_count, sp.is_available, sp.discount_percentage
     FROM cart_items ci
     JOIN products p ON ci.product_id = p.id
     JOIN stores s ON ci.store_id = s.id
     LEFT JOIN store_products sp ON ci.product_id = sp.product_id AND ci.store_id = sp.store_id
     WHERE ci.user_id = $1
     ORDER BY ci.added_at DESC`,
    [userId]
  );

  let subtotal = 0;
  let savings = 0;

  result.rows.forEach((item) => {
    subtotal += item.price * item.quantity;
    if (item.compare_at_price) {
      savings += (item.compare_at_price - item.price) * item.quantity;
    }
  });

  return {
    items: result.rows,
    item_count: result.rows.length,
    subtotal: subtotal.toFixed(2),
    savings: savings.toFixed(2),
  };
};

export const addToCart = async (userId: number, productId: string, storeId: string, quantity: number = 1) => {
  // Check availability
  const storeProduct = await query(
    `SELECT * FROM store_products WHERE product_id = $1 AND store_id = $2`,
    [productId, storeId]
  );

  if (storeProduct.rows.length === 0) {
    throw new Error("Product not available at this store");
  }

  if (
    !storeProduct.rows[0].is_available ||
    storeProduct.rows[0].stock_count < quantity
  ) {
    throw new Error("Insufficient stock");
  }

  const result = await query(
    `INSERT INTO cart_items (user_id, product_id, store_id, quantity)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (user_id, product_id, store_id)
     DO UPDATE SET quantity = cart_items.quantity + $4
     RETURNING *`,
    [userId, productId, storeId, quantity]
  );

  return result.rows[0];
};

export const updateCartItem = async (userId: number, itemId: string, quantity: number) => {
  if (quantity < 1) throw new Error("Quantity must be at least 1");

  const existing = await query(
    "SELECT * FROM cart_items WHERE id = $1 AND user_id = $2",
    [itemId, userId]
  );

  if (existing.rows.length === 0) {
    throw new Error("Cart item not found");
  }

  const storeProduct = await query(
    `SELECT stock_count FROM store_products 
     WHERE product_id = $1 AND store_id = $2`,
    [existing.rows[0].product_id, existing.rows[0].store_id]
  );

  if (storeProduct.rows[0].stock_count < quantity) {
    throw new Error("Insufficient stock");
  }

  const result = await query(
    "UPDATE cart_items SET quantity = $1 WHERE id = $2 RETURNING *",
    [quantity, itemId]
  );

  return result.rows[0];
};

export const removeCartItem = async (userId: number, itemId: string) => {
  const result = await query(
    "DELETE FROM cart_items WHERE id = $1 AND user_id = $2 RETURNING *",
    [itemId, userId]
  );

  if (result.rows.length === 0) {
    throw new Error("Cart item not found");
  }

  return true;
};

export const clearCart = async (userId: number) => {
  await query("DELETE FROM cart_items WHERE user_id = $1", [userId]);
  return true;
};
