
DROP TABLE IF EXISTS "Category" CASCADE;
DROP TABLE IF EXISTS "Category_Dish" CASCADE;
DROP TABLE IF EXISTS "Dish" CASCADE;
DROP TABLE IF EXISTS "Equipment" CASCADE;
DROP TABLE IF EXISTS "Dish_Equipment" CASCADE;
DROP TABLE IF EXISTS "Dish_Image" CASCADE;
DROP TABLE IF EXISTS "Ingredient" CASCADE;
DROP TABLE IF EXISTS "Ingredient_Dish" CASCADE;
DROP TABLE IF EXISTS "Ingredient_Image" CASCADE;
DROP TABLE IF EXISTS "Synonym" CASCADE;
DROP TABLE IF EXISTS "Standard_Unit" CASCADE;
DROP TABLE IF EXISTS "Non_Standard_Unit" CASCADE;
DROP TABLE IF EXISTS "Unit_Conversion" CASCADE;


CREATE TABLE IF NOT EXISTS "Category" (
    id serial,
    Parent_id integer,
    Name character varying(64) NOT NULL,
	vertical_order integer NOT NULL CHECK ("vertical_order" > 0),
	horizontal_order integer NOT NULL CHECK ("horizontal_order" > 0),
    PRIMARY KEY (id),
    FOREIGN KEY (Parent_id) REFERENCES "Category" (id)
);

CREATE TABLE IF NOT EXISTS "Dish" (
    id serial,
    Name character varying(64) NOT NULL,
    cooking_time interval CHECK (cooking_time >= INTERVAL '0'),
    instruction text,
    description text,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Equipment" (
    id serial,
    Name character varying(64) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Ingredient" (
    id serial,
    Name character varying(64) NOT NULL,
    description text,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Standard_Unit" (
    id serial,
    Name character varying(32) NOT NULL,
    short_name character varying(10),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Non_Standard_Unit" (
    id serial,
    Name character varying(64) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS "Category_Dish" (
    id serial,
    Category_id integer,
    Dish_id integer,
    PRIMARY KEY (id),
    FOREIGN KEY (Category_id) REFERENCES "Category" (id),
    FOREIGN KEY (Dish_id) REFERENCES "Dish" (id)
);

CREATE TABLE IF NOT EXISTS "Dish_Equipment" (
    id serial,
    Dish_id integer,
    Equipment_id integer,
    PRIMARY KEY (id),
    FOREIGN KEY (Dish_id) REFERENCES "Dish" (id),
    FOREIGN KEY (Equipment_id) REFERENCES "Equipment" (id)
);

CREATE TABLE IF NOT EXISTS "Dish_Image" (
    id serial,
    Dish_id integer,
    Image_Path character varying(128) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (Dish_id) REFERENCES "Dish" (id)
);

CREATE TABLE IF NOT EXISTS "Ingredient_Dish" (
    id serial,
    Ingredient_id integer,
    Dish_id integer,
    Standard_Unit_id integer,
    Standard_amount numeric(10, 4) CHECK (Standard_amount > 0 OR Standard_amount = Null),
    PRIMARY KEY (id),
    FOREIGN KEY (Ingredient_id) REFERENCES "Ingredient" (id),
    FOREIGN KEY (Dish_id) REFERENCES "Dish" (id),
    FOREIGN KEY (Standard_Unit_id) REFERENCES "Standard_Unit" (id)
);

CREATE TABLE IF NOT EXISTS "Ingredient_Image" (
    id serial,
    Ingredient_id integer NOT NULL,
    Image_Path character varying(128) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (Ingredient_id) REFERENCES "Ingredient" (id)
);

CREATE TABLE IF NOT EXISTS "Synonym" (
    id serial,
    Ingredient_id integer NOT NULL,
    Synonym character varying(64) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (Ingredient_id) REFERENCES "Ingredient" (id)
);

CREATE TABLE IF NOT EXISTS "Unit_Conversion" (
    id serial,
    Ingredient_id integer NOT NULL,
    Standard_Unit_id integer NOT NULL,
    Non_Standard_Unit_id integer NOT NULL,
    Standard_in_Non_Standard numeric(10, 4) NOT NULL CHECK (Standard_in_Non_Standard > 0),
    PRIMARY KEY (id),
    FOREIGN KEY (Ingredient_id) REFERENCES "Ingredient" (id),
    FOREIGN KEY (Standard_Unit_id) REFERENCES "Standard_Unit" (id),
    FOREIGN KEY (Non_Standard_Unit_id) REFERENCES "Non_Standard_Unit" (id)
);