-- Pantry/Inventory Management Tables for ShopRoute

-- Pantry items table - tracks items user has at home
CREATE TABLE pantry_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
    custom_name VARCHAR(255), -- For items not in product database
    quantity DECIMAL(10,2) DEFAULT 1,
    unit VARCHAR(50) DEFAULT 'unit',
    purchase_date DATE DEFAULT CURRENT_DATE,
    expiry_date DATE,
    opened_date DATE,
    location VARCHAR(50) DEFAULT 'pantry', -- pantry, fridge, freezer
    notes TEXT,
    is_low_stock BOOLEAN DEFAULT FALSE,
    low_stock_threshold DECIMAL(10,2) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX pantry_items_user_idx ON pantry_items(user_id);
CREATE INDEX pantry_items_expiry_idx ON pantry_items(expiry_date);

-- Recipe suggestions based on pantry items
CREATE TABLE recipes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    prep_time INTEGER, -- minutes
    cook_time INTEGER, -- minutes
    servings INTEGER DEFAULT 4,
    difficulty VARCHAR(20) DEFAULT 'medium', -- easy, medium, hard
    cuisine VARCHAR(50),
    dietary_tags JSONB DEFAULT '[]',
    instructions JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipe ingredients
CREATE TABLE recipe_ingredients (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER REFERENCES recipes(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
    ingredient_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2),
    unit VARCHAR(50),
    is_optional BOOLEAN DEFAULT FALSE
);

CREATE INDEX recipe_ingredients_recipe_idx ON recipe_ingredients(recipe_id);

-- Product substitutions - AI suggested alternatives
CREATE TABLE product_substitutions (
    id SERIAL PRIMARY KEY,
    original_product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    substitute_product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    similarity_score DECIMAL(3,2) DEFAULT 0.5, -- 0 to 1
    reason TEXT, -- "Creamy texture, similar nutrition"
    is_ai_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(original_product_id, substitute_product_id)
);

CREATE INDEX substitutions_original_idx ON product_substitutions(original_product_id);

-- User's expiry notifications settings
CREATE TABLE expiry_notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    pantry_item_id INTEGER REFERENCES pantry_items(id) ON DELETE CASCADE,
    notify_days_before INTEGER DEFAULT 3,
    is_notified BOOLEAN DEFAULT FALSE,
    notified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shopping list auto-generation preferences
ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS auto_generate_list BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS low_stock_reminder BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS expiry_reminder_days INTEGER DEFAULT 3;

-- Triggers for updated_at
CREATE TRIGGER update_pantry_items_updated_at BEFORE UPDATE ON pantry_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
