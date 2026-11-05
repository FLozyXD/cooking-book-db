--- 0
SELECT DISTINCT
	d.name as dish_name,
	i.name as ingredient_name,
	COUNT(idish.dish_id) OVER (PARTITION BY i.id) as total_use_count,
	COUNT(idish.ingredient_id) OVER (PARTITION BY d.id) as total_ingredients_in_dish
FROM "Dish" d
JOIN "Ingredient_Dish" idish ON d.id = idish.dish_id
JOIN "Ingredient" i ON idish.ingredient_id = i.id;


--- 1
SELECT
	c.name as category_name,
	STRING_AGG(d.name, ', ' ORDER BY d.name DESC) as dished_in_category
FROM "Category" c
JOIN "Category_Dish" cdish ON c.id = cdish.category_id
JOIN "Dish" d on cdish.dish_id = d.id
GROUP BY c.name;
