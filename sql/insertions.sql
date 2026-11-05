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

-- Заполнение справочников
INSERT INTO "Standard_Unit" (Name, short_name) VALUES
('Грамм', 'г'),				-- 1
('Килограмм', 'кг'),		-- 2
('Литр', 'л'),				-- 3
('Стакан', 'ст'),			-- 4
('Чайная ложка', 'ч.л.'),	-- 5
('Штука', 'шт');			-- 6

INSERT INTO "Non_Standard_Unit" (Name) VALUES
('Стакан'),			-- 1
('Чайная ложка'),	-- 2
('Штука');			-- 3

INSERT INTO "Equipment" (Name) VALUES
('Духовой шкаф'),	-- 1
('Сковорода'),		-- 2
('Кастрюля'),		-- 3
('Миксер'),			-- 4
('Блендер');		-- 5

INSERT INTO "Ingredient" (Name, description) VALUES
('Мука пшеничная', 'Высший сорт'),			-- 1
('Яйцо куриное', 'Категория С0'),			-- 2
('Сахар', 'Белый кристаллический'),			-- 3
('Молоко', 'Жирность 3.2%'),				-- 4
('Соль', 'Поваренная пищевая'),				-- 5
('Оливковое масло', 'Extra Virgin'),		-- 6
('Подсолнечное масло', 'Рафинированное');	-- 7

-- Заполнение Unit_Conversion
INSERT INTO "Unit_Conversion" (Ingredient_id, Standard_Unit_id, Non_Standard_Unit_id, Standard_in_Non_Standard) VALUES
(1, 1, 1, 160.00), -- Мука: 1 Стакан = 160 Грамм
(3, 1, 1, 200.00), -- Сахар: 1 Стакан = 200 Грамм
(5, 1, 2, 7.00),   -- Соль: 1 Чайная ложка = 7 Грамм
(2, 1, 3, 55.00);  -- Яйцо: 1 Штука = 55 Грамм

-- Заполнение Категорий
INSERT INTO "Category" (Parent_id, Name, vertical_order, horizontal_order) VALUES 
(NULL, 'Выпечка', 1, 1);
INSERT INTO "Category" (Parent_id, Name, vertical_order, horizontal_order) VALUES 
(NULL, 'Завтраки', 1, 2);
INSERT INTO "Category" (Parent_id, Name, vertical_order, horizontal_order) VALUES 
(1, 'Сладкая выпечка', 2, 1);
INSERT INTO "Category" (Parent_id, Name, vertical_order, horizontal_order) VALUES 
(1, 'Блины', 2, 2);
INSERT INTO "Category" (Parent_id, Name, vertical_order, horizontal_order) VALUES 
(2, 'Быстрые завтраки', 2, 1);

-- Заполнение Блюд
INSERT INTO "Dish" (Name, cooking_time, instruction, description) VALUES
('Блины классические', '00:40:00', 'Смешать молоко, яйца и муку.', 'Тонкие домашние блинчики'),
('Бисквит', '01:00:00', 'Взбить яйца с сахаром, добавить муку.', 'Пышный бисквит'),
('Омлет', '00:15:00', 'Взбить яйца с молоком и солью.', 'Сытный завтрак'),
('Салат', '00:10:00', 'Нарезать овощи и заправить маслом.', 'Свежий салат с маслом');

-- Связи Блюда-Категории и Блюда-Оборудование
INSERT INTO "Category_Dish" (Category_id, Dish_id) VALUES
(4, 1), (3, 2), (5, 3), (1, 1), (1, 2), (2, 3), (2, 4);

INSERT INTO "Dish_Equipment" (Dish_id, Equipment_id) VALUES
(1, 2), (1, 4), (2, 1), (2, 4), (3, 2), (4, 5);

-- Заполнение рецептов
-- Standard_Unit id: 1=Грамм, 4=Стакан, 5=Ч.Ложка, 6=Штука
INSERT INTO "Ingredient_Dish" (Dish_id, Ingredient_id, Standard_Unit_id, Standard_amount) VALUES
-- Блины
(1, 1, 4, 2.00),   -- Мука: 2 Стакана
(1, 4, 1, 500.00), -- Молоко: 500 Грамм (не требует конвертации)
(1, 2, 6, 3.00),   -- Яйцо: 3 Штуки
(1, 5, 5, 1.00),   -- Соль: 1 Чайная ложка

-- Бисквит
(2, 1, 4, 1.50),   -- Мука: 1.5 Стакана
(2, 3, 4, 1.00),   -- Сахар: 1 Стакан
(2, 2, 6, 5.00),   -- Яйцо: 5 Штук

-- Омлет
(3, 2, 6, 4.00),   -- Яйцо: 4 Штуки
(3, 4, 1, 100.00), -- Молоко: 100 Грамм
(3, 5, 5, 0.50),   -- Соль: 0.5 Чайной ложки

-- Салат
(4, 6, 1, 30.00),  -- Оливковое масло: 30 Грамм
(4, 7, 1, 20.00);  -- Подсолнечное масло: 20 Грамм