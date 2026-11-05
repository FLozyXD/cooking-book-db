SELECT * FROM "Dish";
SELECT * FROM "Category";
SELECT * FROM "Ingredient_Dish";
SELECT * FROM "Unit_Conversion";

--- 0
WITH IngredientCounts AS (
    SELECT i.Name, COUNT(idish.Dish_id) AS dish_count
    FROM "Ingredient" i
    JOIN "Ingredient_Dish" idish ON i.id = idish.Ingredient_id
    GROUP BY i.id, i.Name
)
SELECT Name, dish_count
FROM IngredientCounts
WHERE dish_count = (SELECT MAX(dish_count) FROM IngredientCounts);


--- 1
WITH DishWeights AS (
    SELECT 
        idish.Dish_id,
        CASE 
            WHEN su.Name = 'Грамм' THEN idish.Standard_amount
            WHEN su.Name = 'Килограмм' THEN idish.Standard_amount * 1000
            ELSE 
                COALESCE(
                    (SELECT uc.Standard_in_Non_Standard * idish.Standard_amount
                     FROM "Unit_Conversion" uc
                     JOIN "Non_Standard_Unit" nsu ON uc.Non_Standard_Unit_id = nsu.id
                     JOIN "Standard_Unit" su_target ON uc.Standard_Unit_id = su_target.id
                     WHERE uc.Ingredient_id = idish.Ingredient_id
                       AND nsu.Name = su.Name 
                       AND su_target.Name = 'Грамм'
                     LIMIT 1
                    ), 0)
        END AS weight_in_grams
    FROM "Ingredient_Dish" idish
    JOIN "Standard_Unit" su ON idish.Standard_Unit_id = su.id
),
TotalWeights AS (
    SELECT Dish_id, SUM(weight_in_grams) AS total_weight
    FROM DishWeights
    GROUP BY Dish_id
)
SELECT d.Name, tw.total_weight::numeric(8,2)
FROM "Dish" d
JOIN TotalWeights tw ON d.id = tw.Dish_id
WHERE tw.total_weight = (SELECT MAX(total_weight) FROM TotalWeights);


--- 2
SELECT d.Name,
	(SELECT COUNT(DISTINCT idish.Ingredient_id) 
        FROM "Ingredient_Dish" idish 
        WHERE d.id = idish.Dish_id
    ) AS ingredient_count
FROM "Dish" d
WHERE NOT EXISTS (
    SELECT 1 
    FROM "Ingredient_Dish" idish
    JOIN "Ingredient" i ON idish.Ingredient_id = i.id
    WHERE idish.Dish_id = d.id 
      AND i.Name NOT IN ('Мука пшеничная', 'Яйцо куриное', 'Соль', 'Молоко')
)
AND EXISTS (
    SELECT 1 FROM "Ingredient_Dish" WHERE Dish_id = d.id
);
-- напротив бисквита суммарное кол-во ингредиентов, универсально

--- 3
DELETE FROM "Ingredient_Dish"
WHERE Ingredient_id = (SELECT id FROM "Ingredient" WHERE Name = 'Подсолнечное масло')
  AND Dish_id IN (
      SELECT Dish_id 
      FROM "Ingredient_Dish" 
      WHERE Ingredient_id = (SELECT id FROM "Ingredient" WHERE Name = 'Оливковое масло')
  )
RETURNING *;


--- 4
UPDATE "Ingredient_Dish"
SET Standard_amount = Standard_amount * 8,
    Standard_Unit_id = (SELECT id FROM "Standard_Unit" WHERE Name = 'Грамм')
WHERE Standard_Unit_id = (SELECT id FROM "Standard_Unit" WHERE Name = 'Чайная ложка');


--- 5
ALTER TABLE "Dish" 
ADD COLUMN health_impact character varying(64);


--- 6
ALTER TABLE "Dish" 
ADD CONSTRAINT chk_health_impact 
CHECK (health_impact IN (
    'диетическое', 
    'вегетарианское', 
    'для диабетиков', 
    'c низким уровнем холестерина'
));