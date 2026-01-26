-- Trigger to update store rating and review count
CREATE OR REPLACE FUNCTION update_store_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE stores
    SET 
        rating = (
            SELECT COALESCE(ROUND(AVG(rating), 1), 0)
            FROM reviews
            WHERE store_id = COALESCE(NEW.store_id, OLD.store_id)
        ),
        review_count = (
            SELECT COUNT(*)
            FROM reviews
            WHERE store_id = COALESCE(NEW.store_id, OLD.store_id)
        )
    WHERE id = COALESCE(NEW.store_id, OLD.store_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_store_rating_trigger ON reviews;

CREATE TRIGGER update_store_rating_trigger
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_store_rating();
