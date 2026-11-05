# Cooking Book — база данных электронной поваренной книги

Учебный проект по проектированию реляционной базы данных и демонстрации
возможностей PostgreSQL: нормализованная схема, ограничения целостности,
триггеры, функции, представления, пользовательский агрегат и оконные функции.

## Предметная область

Поваренная книга хранит блюда, категории, ингредиенты, оборудование и единицы
измерения. Одно блюдо может входить в несколько категорий, использовать разное
оборудование и содержать много ингредиентов с количеством в разных единицах.
Для ингредиентов поддерживаются синонимы и коэффициенты пересчёта единиц.

## Схема

13 таблиц:

| Таблица | Назначение |
|---|---|
| `Category` | дерево категорий (родитель, порядок отображения) |
| `Dish` | блюда, инструкция приготовления, время, сложность |
| `Equipment` | кухонное оборудование |
| `Ingredient` | ингредиенты |
| `Standard_Unit`, `Non_Standard_Unit` | стандартные и бытовые единицы |
| `Unit_Conversion` | коэффициенты пересчёта |
| `Category_Dish` | связь many-to-many категорий и блюд |
| `Dish_Equipment` | оборудование блюда |
| `Ingredient_Dish` | состав блюда с количеством |
| `Dish_Image`, `Ingredient_Image` | изображения |
| `Synonym` | синонимы ингредиентов |

Полная схема — [`sql/create-tables.sql`](sql/create-tables.sql),
тестовые данные — [`sql/insertions.sql`](sql/insertions.sql).
ER-диаграммы в формате pgAdmin — в [`diagrams/`](diagrams/).

## Что реализовано в SQL

- **Ограничения и каскады** — внешние ключи, `CHECK`, уникальные пары.
- **Триггеры-ограничители** — не более 50 блюд в категории и 50 ингредиентов
  в блюде (`sql/lab5 tasks.sql`).
- **Функция** `count_dishes_by_name(search_term)` — подсчёт блюд по названию.
- **Пользовательский агрегат** `get_unique_ingredients(TEXT)` — уникальные
  ингредиенты с собственным transition/final state.
- **Обновляемое представление** `view_dish_details` с `INSTEAD OF UPDATE`.
- **ADT-множество** на функциях `init_set`, `add_to_set`, `delete_from_set`,
  `empty_set`.
- **Аналитические запросы** — CTE, пересчёт единиц в граммы, оконные функции,
  `STRING_AGG`, поиск блюд только из универсальных ингредиентов.
- **Bogosort** на массиве `INT[]` — шуточная демонстрация рекурсивного CTE и
  случайных перестановок (`sql/lab5 bogosort.sql`).

## Приложение

Консольный CRUD-клиент на Python для категорий и блюд:

```text
app/
  main.py              меню и сценарии
  dbconnection.py      подключение psycopg2
  dbtable.py           базовый класс таблицы
  project_config.py    чтение config.yaml
  tables/
    category_table.py
    dish_table.py
```

## Запуск

1. Создайте базу:

```bash
createdb cooking_python
psql -d cooking_python -f sql/create-tables.sql
psql -d cooking_python -f sql/insertions.sql
```

2. Установите зависимости:

```bash
python -m venv .venv
# активируйте venv
pip install -r app/requirements.txt
```

3. Создайте конфигурацию:

```bash
cd app
cp config.example.yaml config.yaml
```

Укажите в `config.yaml` хост, порт, пользователя и пароль PostgreSQL.

4. Запуск:

```bash
cd app
python main.py
```

Меню позволяет смотреть категории, сбрасывать и инициализировать таблицы,
добавлять и удалять записи. SQL-лаборатории запускаются отдельно через `psql`.

## Демонстрация лабораторий

```bash
psql -d cooking_python -f "sql/lab3 tasks.sql"
psql -d cooking_python -f "sql/lab5 tasks.sql"
psql -d cooking_python -f "sql/lab5 tests.sql"
psql -d cooking_python -f "sql/lab6 tasks.sql"
```

## Ограничения

- Приложение рассчитано на локальную PostgreSQL и не содержит миграций.
- Часть лабораторных запросов изменяет данные — запускайте на тестовой базе.
- `config.yaml` с паролем не входит в репозиторий.

## Лицензия

MIT.
