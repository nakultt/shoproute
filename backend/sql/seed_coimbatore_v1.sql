-- Seed Data for ShopRoute (Coimbatore) - v2 Expanded

-- Clear existing data
TRUNCATE TABLE reviews, store_products, products, categories, stores RESTART IDENTITY CASCADE;

-- 1. Categories
INSERT INTO categories (name, icon, color, sort_order) VALUES
('Fruits & Vegetables', 'apple', 'FF6B6B', 1),
('Dairy & Breakfast', 'egg', '4ECDC4', 2),
('Rice & Grains', 'grain', 'FFE66D', 3),
('Bakery & Snacks', 'cake', 'FF9F43', 4),
('Beverages', 'local_drink', '54A0FF', 5),
('Personal Care', 'soap', '6C5CE7', 6),
('Household', 'cleaning_services', 'A3CB38', 7);

-- 2. Stores (Coimbatore Locations)
INSERT INTO stores (name, address, location, phone, rating, review_count, opening_hours, logo_url) VALUES
(
    'Fresh Mart Gandhipuram',
    '100 Feet Road, Gandhipuram, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9658, 11.0168), 4326),
    '+91 9876543210',
    4.5,
    120,
    '{"Mon": "9:00-22:00", "Tue": "9:00-22:00"}',
    'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=200&q=80'
),
(
    'RS Puram Organics',
    'Diwan Bahadur Road, RS Puram, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9458, 11.0068), 4326),
    '+91 9876543211',
    4.8,
    85,
    '{"Mon": "8:00-21:00"}',
    'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=200&q=80'
),
(
    'Peelamedu SuperStore',
    'Avinashi Road, Peelamedu, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(77.0058, 11.0268), 4326),
    '+91 9876543212',
    4.2,
    210,
    '{"Mon": "24 Hours"}',
    'https://images.unsplash.com/photo-1580913428706-c311abaf7940?auto=format&fit=crop&w=200&q=80'
),
(
    'Sai Baba Colony Grocers',
    'NSR Road, Sai Baba Colony, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9358, 11.0368), 4326),
    '+91 9876543213',
    3.9,
    45,
    '{"Mon": "9:00-21:30"}',
    'https://images.unsplash.com/photo-1604719312566-b76d4685332e?auto=format&fit=crop&w=200&q=80'
),
(
    'Saravanampatti Daily Needs',
    'Sathy Road, Saravanampatti, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9958, 11.0868), 4326),
    '+91 9876543214',
    4.1,
    60,
    '{"Mon": "7:00-23:00"}',
    'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=200&q=80'
),
(
    'Kuniyamuthur Rice Mandi',
    'Palakkad Main Road, Kuniyamuthur, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9421, 10.9664), 4326),
    '+91 9876543215',
    4.4,
    95,
    '{"Mon": "6:00-20:00"}',
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=200&q=80'
),
(
    'Ukkadam Wholesale Market',
    'Ukkadam, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9592, 10.9926), 4326),
    '+91 9876543216',
    4.0,
    300,
    '{"Mon": "4:00-18:00"}',
    'https://images.unsplash.com/photo-1606206591513-58580227914e?auto=format&fit=crop&w=200&q=80'
),
(
    'Town Hall Spice Bazaar',
    'Town Hall, Coimbatore, TN',
    ST_SetSRID(ST_MakePoint(76.9616, 11.0018), 4326),
    '+91 9876543217',
    4.6,
    150,
    '{"Mon": "9:30-21:00"}',
    'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=200&q=80'
);

-- 3. Products
INSERT INTO products (name, description, image_url, category_id, brand, unit, nutritional_info) VALUES
-- Fruits & Veg (1)
('Fresh Tomatoes', 'Locally grown organic tomatoes', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=400&q=80', 1, 'Local Farm', 'kg', '{"calories": 18}'),
('Red Onions', 'Premium quality large red onions', 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=400&q=80', 1, 'Local Farm', 'kg', '{"calories": 40}'),
('Bananas (Robusta)', 'Fresh Robusta bananas', 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?auto=format&fit=crop&w=400&q=80', 1, 'Local Farm', 'kg', '{"calories": 89}'),
('Ooty Carrots', 'Sweet and crunchy carrots from Ooty', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=400&q=80', 1, 'Ooty Special', 'kg', '{"calories": 41}'),
('Green Chillies', 'Spicy fresh green chillies', 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?auto=format&fit=crop&w=400&q=80', 1, 'Local Farm', '250g', '{"calories": 10}'),
('Potatoes', 'Large potatoes for cooking', 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=400&q=80', 1, 'Local Farm', 'kg', '{"calories": 77}'),

-- Dairy (2)
('Aavin Milk (Blue)', 'Standardized milk 500ml', 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80', 2, 'Aavin', 'pack', '{"calories": 60}'),
('Amul Butter', 'Pasteurized butter 100g', 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=400&q=80', 2, 'Amul', 'pack', '{"calories": 717}'),
('Farm Fresh Eggs', 'Brown eggs pack of 6', 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=400&q=80', 2, 'Local Farm', 'pack', '{"calories": 155}'),
('Paneer', 'Fresh cottage cheese 200g', 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=400&q=80', 2, 'Milky Mist', 'pack', '{"calories": 296}'),

-- Rice & Grains (3)
('Ponni Boiled Rice', 'Premium aged Ponni rice', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80', 3, 'India Gate', 'kg', '{"calories": 130}'),
('Toor Dal', 'Unpolished Toor Dal', 'https://images.unsplash.com/photo-1551462147-37885acc36f1?auto=format&fit=crop&w=400&q=80', 3, 'Tata Sampann', 'kg', '{"calories": 343}'),
('Sunflower Oil', 'Refined sunflower oil 1L', 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=400&q=80', 3, 'Gold Winner', 'liter', '{"calories": 884}'),
('Basmati Rice', 'Long grain basmati rice', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=400&q=80', 3, 'Daawat', 'kg', '{"calories": 130}'),

-- Bakery (4)
('Wheat Bread', 'Whole wheat sliced bread', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80', 4, 'Modern', 'pack', '{"calories": 250}'),
('Marie Gold Biscuits', 'Tea time biscuits', 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?auto=format&fit=crop&w=400&q=80', 4, 'Britannia', 'pack', '{"calories": 450}'),
('Dark Fantasy', 'Choco fille biscuits', 'https://images.unsplash.com/photo-1623086885317-2c9b36c4b2b3?auto=format&fit=crop&w=400&q=80', 4, 'Sunfeast', 'pack', '{"calories": 500}'),

-- Beverages (5)
('Tata Tea Gold', 'Premium Assam tea 250g', 'https://images.unsplash.com/photo-1564890369478-c5af4691bb00?auto=format&fit=crop&w=400&q=80', 5, 'Tata', 'pack', '{"calories": 0}'),
('Bru Instant Coffee', 'Instant coffee powder 50g', 'https://images.unsplash.com/photo-1558667615-188c634dd72e?auto=format&fit=crop&w=400&q=80', 5, 'Bru', 'jar', '{"calories": 2}'),
('Coca Cola', 'Carbonated soft drink 750ml', 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=400&q=80', 5, 'Coca Cola', 'bottle', '{"calories": 140}'),

-- Personal Care (6)
('Dettol Soap', 'Antiseptic soap 125g', 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80', 6, 'Dettol', 'bar', '{}'),
('Colgate Toothpaste', 'Strong teeth toothpaste 200g', 'https://images.unsplash.com/photo-1559563362-c667ba5f5480?auto=format&fit=crop&w=400&q=80', 6, 'Colgate', 'tube', '{}'),

-- Household (7)
('Rin Detergent', 'Detergent powder 1kg', 'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?auto=format&fit=crop&w=400&q=80', 7, 'Rin', 'pack', '{}'),
('Vim Bar', 'Dishwash bar 200g', 'https://images.unsplash.com/photo-1585721832479-7a7102e3dcda?auto=format&fit=crop&w=400&q=80', 7, 'Vim', 'bar', '{}');


-- 4. Store Products (Inventory - Complex Relations)
-- Store 1: Fresh Mart (Premium)
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(1, 1, 45, 50, 100, true), (1, 2, 80, 90, 80, true), (1, 3, 40, 45, 60, true),
(1, 4, 60, 70, 50, true), (1, 5, 20, 25, 40, true), (1, 7, 26, 26, 150, true),
(1, 8, 55, 60, 30, true), (1, 11, 65, 75, 100, true), (1, 13, 160, 180, 50, true),
(1, 15, 35, 40, 20, true), (1, 19, 250, 260, 40, true);

-- Store 2: RS Puram Organics
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(2, 1, 55, 60, 40, true), (2, 2, 95, 100, 0, false), -- Out of stock
(2, 3, 45, 50, 30, true), (2, 4, 75, 80, 25, true), (2, 9, 70, 80, 15, true),
(2, 11, 80, 90, 40, true), (2, 14, 150, 170, 30, true);

-- Store 3: Peelamedu SuperStore (Wholesale)
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(3, 1, 38, 50, 500, true), (3, 2, 70, 90, 400, true), (3, 3, 30, 40, 300, true),
(3, 6, 35, 45, 200, true), (3, 7, 24, 26, 200, true), (3, 11, 58, 75, 500, true),
(3, 12, 135, 160, 200, true), (3, 13, 145, 180, 250, true), (3, 17, 30, 35, 100, true),
(3, 21, 45, 50, 150, true), (3, 23, 120, 140, 100, true);

-- Store 4: Sai Baba Colony Grocers
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(4, 1, 42, 48, 20, true), (4, 7, 26, 26, 0, false), -- OOS
(4, 15, 40, 45, 15, true), (4, 16, 10, 10, 50, true), (4, 18, 120, 130, 20, true);

-- Store 5: Saravanampatti Daily Needs
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(5, 7, 26, 26, 50, true), (5, 9, 60, 65, 30, true), (5, 15, 38, 40, 10, true),
(5, 16, 12, 15, 60, true), (5, 19, 240, 250, 15, true), (5, 20, 45, 45, 40, true);

-- Store 6: Kuniyamuthur Rice Mandi
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(6, 11, 56, 70, 1000, true), (6, 12, 130, 150, 500, true),
(6, 14, 110, 130, 400, true);

-- Store 7: Ukkadam Market (Cheapest)
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(7, 1, 35, 45, 1000, true), (7, 2, 65, 80, 1000, true), (7, 5, 15, 20, 500, true),
(7, 6, 30, 40, 600, true);

-- Store 8: Town Hall Spice Bazaar
INSERT INTO store_products (store_id, product_id, price, compare_at_price, stock_count, is_available) VALUES
(8, 12, 140, 160, 200, true), (8, 5, 20, 25, 50, true), (8, 19, 255, 260, 60, true);
