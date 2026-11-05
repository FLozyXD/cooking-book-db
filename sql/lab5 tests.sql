TRUNCATE TABLE 
	"Category", 
	"Dish", 
	"Equipment", 
	"Ingredient", 
	"Standard_Unit", 
	"Non_Standard_Unit", 
	"Category_Dish", 
	"Dish_Equipment", 
	"Dish_Image", 
	"Ingredient_Dish", 
	"Ingredient_Image", 
	"Synonym", 
	"Unit_Conversion" 
RESTART IDENTITY CASCADE;

--- 0

DO $$
DECLARE
    test_cat_id integer;
    test_dish_id integer;
BEGIN
	
    -- 1. Создаем тестовую категорию
    INSERT INTO "Category" (Name, vertical_order, horizontal_order) 
    VALUES ('Тест лимитов 50', 1, 1) RETURNING id INTO test_cat_id;
    
    -- 2. Вставляем ровно 50 блюд (должно пройти успешно)
    FOR i IN 1..50 LOOP
        INSERT INTO "Dish" (Name) VALUES ('Блюдо ' || i) RETURNING id INTO test_dish_id;
        INSERT INTO "Category_Dish" (Category_id, Dish_id) VALUES (test_cat_id, test_dish_id);
    END LOOP;
    
    RAISE NOTICE '50 блюд успешно вставлены!';
    
    -- 3. Пытаемся вставить 51-е блюдо (Здесь должен сработать триггер)
    INSERT INTO "Dish" (Name) VALUES ('Блюдо 51 (Лишнее)') RETURNING id INTO test_dish_id;
    INSERT INTO "Category_Dish" (Category_id, Dish_id) VALUES (test_cat_id, test_dish_id);
    
    RAISE NOTICE 'Если вы видите этот текст, значит триггер НЕ сработал (а должен был!)';
    
EXCEPTION
    -- Перехватываем ошибку нашего триггера и выводим красивое сообщение
    WHEN OTHERS THEN
        RAISE EXCEPTION '✅ ТРИГГЕР УСПЕШНО СРАБОТАЛ! Поймана ошибка: %', SQLERRM;
END $$;

SELECT * FROM "Dish";

--- 1

-- Ожидаем число (например, 1, если есть "Блины классические")
SELECT count_dishes_by_name('Блин') AS "Блюд со словом 'Блин'";

-- Ищем то, чего точно нет
SELECT count_dishes_by_name('Пицца') AS "Блюд со словом 'Пицца'";


--- 2

WITH dummy_ingredients AS (
    SELECT 'Соль' AS ing_name UNION ALL
    SELECT 'Сахар' AS ing_name UNION ALL
    SELECT 'Соль' AS ing_name UNION ALL  -- Дубль!
    SELECT 'Мука' AS ing_name UNION ALL
    SELECT 'Мука' AS ing_name            -- Дубль!
)
SELECT get_unique_ingredients(ing_name) AS "Уникальный список" 
FROM dummy_ingredients;
-- ✅ Ожидаемый результат: "Соль, Сахар, Мука" (без повторений)


--- 3

-- 1. Смотрим текущую инструкцию блюда с id = 1
SELECT dish_name, instruction 
FROM view_dish_details 
WHERE dish_id = 1;

-- 2. Делаем UPDATE через представление (сработает триггер trg_update_instruction)
UPDATE view_dish_details 
SET instruction = '✅ НОВАЯ ИНСТРУКЦИЯ ИЗ ТЕСТА: Печь до золотистой корочки!' 
WHERE dish_id = 1;

-- 3. Проверяем, что в представлении данные поменялись
SELECT dish_name, instruction 
FROM view_dish_details 
WHERE dish_id = 1;

-- 4. Убеждаемся, что триггер физически обновил базовую таблицу Dish
SELECT Name, instruction 
FROM "Dish" 
WHERE id = 1;


--- 4

-- 1. Инициализация (сброс таблицы, результат: null)
SELECT init_set() AS "Инициализация";

-- 2. Добавляем уникальные элементы
SELECT add_to_set('Яблоко') AS "Добавление 1"; -- вернет 'Яблоко'
SELECT add_to_set('Банан') AS "Добавление 2";  -- вернет 'Банан'

-- 3. Пытаемся добавить дубликат (Триггер множества!)
SELECT add_to_set('Яблоко') AS "Попытка дубликата"; -- ✅ вернет null, так как уже есть

-- 4. Удаляем элемент
SELECT delete_from_set('Банан') AS "Удаление"; -- вернет 'Банан'
SELECT delete_from_set('Киви') AS "Удаление несуществующего"; -- вернет null

-- 5. Проверяем, что физически лежит в таблице-множестве
SELECT * FROM my_set_storage; -- Должно быть только 'Яблоко'

-- 6. Очищаем множество
SELECT empty_set() AS "Кол-во удаленных при очистке"; -- вернет 1 (оставалось только Яблоко)


