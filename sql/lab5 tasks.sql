--- 0

CREATE OR REPLACE FUNCTION check_category_limit() 
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM "Category_Dish" WHERE Category_id = NEW.Category_id) >= 50 THEN
        RAISE EXCEPTION 'В одной категории не может быть более 50 блюд';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_check_category_limit
BEFORE INSERT ON "Category_Dish"
FOR EACH ROW EXECUTE FUNCTION check_category_limit();

CREATE OR REPLACE FUNCTION check_ingredient_limit() 
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM "Ingredient_Dish" WHERE Dish_id = NEW.Dish_id) >= 50 THEN
        RAISE EXCEPTION 'В одном блюде не может быть более 50 ингредиентов';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_check_ingredient_limit
BEFORE INSERT ON "Ingredient_Dish"
FOR EACH ROW EXECUTE FUNCTION check_ingredient_limit();


--- 1

CREATE OR REPLACE FUNCTION count_dishes_by_name(search_term TEXT) 
RETURNS INTEGER AS $$
DECLARE
    dish_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO dish_count 
    FROM "Dish" 
    WHERE Name ILIKE '%' || search_term || '%';
    
    RETURN dish_count;
END;
$$ LANGUAGE plpgsql;

-- SELECT count_dishes_by_name('Блин');


--- 2

CREATE OR REPLACE FUNCTION agg_ingredients_state(state TEXT[], next_val TEXT)
RETURNS TEXT[] AS $$
BEGIN
    IF next_val IS NULL OR next_val = ANY(state) THEN
        RETURN state;
    END IF;
    RETURN array_append(state, next_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION agg_ingredients_final(state TEXT[])
RETURNS TEXT AS $$
BEGIN
    RETURN array_to_string(state, ', ');
END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE get_unique_ingredients(TEXT) (
    SFUNC = agg_ingredients_state,
    STYPE = TEXT[],
    FINALFUNC = agg_ingredients_final,
    INITCOND = '{}'
);

-- SELECT get_unique_ingredients(i.Name) 
-- FROM "Ingredient" i
-- JOIN "Ingredient_Dish" id ON i.id = id.Ingredient_id
-- WHERE id.Dish_id IN (1, 2, 3);


--- 3

CREATE OR REPLACE VIEW view_dish_details AS
SELECT 
    d.id AS dish_id,
    d.Name AS dish_name,
    d.instruction,
    string_agg(i.Name, ', ') AS ingredients_list
FROM "Dish" d
LEFT JOIN "Ingredient_Dish" id ON d.id = id.Dish_id
LEFT JOIN "Ingredient" i ON i.id = id.Ingredient_id
GROUP BY d.id, d.Name, d.instruction;

CREATE OR REPLACE FUNCTION update_dish_instruction()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE "Dish" 
    SET instruction = NEW.instruction 
    WHERE id = OLD.dish_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_instruction
INSTEAD OF UPDATE ON view_dish_details
FOR EACH ROW EXECUTE FUNCTION update_dish_instruction();

-- UPDATE view_dish_details SET instruction = 'Новый рецепт' WHERE dish_id = 1;
-- SELECT * FROM view_dish_details;


--- 4

CREATE OR REPLACE FUNCTION init_set() 
RETURNS TEXT AS $$
BEGIN
    DROP TABLE IF EXISTS my_set_storage;
    CREATE TABLE my_set_storage (
        val VARCHAR(64) PRIMARY KEY
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_to_set(item_str VARCHAR(64)) 
RETURNS VARCHAR(64) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM my_set_storage WHERE val = item_str) THEN
        RETURN NULL; -- элемент уже есть
    END IF;
    
    INSERT INTO my_set_storage (val) VALUES (item_str);
    RETURN item_str;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_from_set(item_str VARCHAR(64)) 
RETURNS VARCHAR(64) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM my_set_storage WHERE val = item_str) THEN
        RETURN NULL;
    END IF;
    
    DELETE FROM my_set_storage WHERE val = item_str;
    RETURN item_str;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION empty_set() 
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO deleted_count FROM my_set_storage;
    TRUNCATE TABLE my_set_storage;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- SELECT init_set();
-- SELECT add_to_set('Соль');      -- Вернет 'Соль'
-- SELECT add_to_set('Соль');      -- Вернет NULL (повтор)
-- SELECT add_to_set('Перец');     -- Вернет 'Перец'
-- SELECT delete_from_set('Соль'); -- Вернет 'Соль'
-- SELECT empty_set();             -- Вернет 1 (остался только Перец)


