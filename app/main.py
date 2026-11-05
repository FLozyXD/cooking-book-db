import sys
sys.path.append('tables')

from project_config import *
from dbconnection import *
from tables.category_table import *
from tables.dish_table import *

class Main:
    config = ProjectConfig()
    connection = DbConnection(config)

    def __init__(self):
        DbTable.dbconn = self.connection
        return

    def db_init(self):
        ct = CategoryTable()
        dt = DishTable()
        dt.drop()
        ct.drop()
        ct.create()
        dt.create()
        return

    def db_insert_somethings(self):
        ct = CategoryTable()
        dt = DishTable()
        ct.insert_one(["Выпечка"])
        ct.insert_one(["Супы"])
        ct.insert_one(["Десерты"])
        
        # Получаем ID для вставки (поскольку ID генерируются автоматически)
        categories = ct.all()
        if len(categories) >= 2:
            id_bakery = categories[0][0]
            id_soups = categories[1][0]
            dt.insert_one([id_bakery, "Блины"])
            dt.insert_one([id_bakery, "Пирог яблочный"])
            dt.insert_one([id_soups, "Борщ"])

    def db_drop(self):
        dt = DishTable()
        ct = CategoryTable()
        dt.drop()
        ct.drop()
        return

    def show_main_menu(self):
        menu = """Добро пожаловать в Электронную поваренную книгу! 
Основное меню: 
    1 - просмотр категорий;
    2 - сброс и инициализация таблиц;
    9 - выход."""
        print(menu)
        return

    def read_next_step(self):
        return input("=> ").strip()

    def after_main_menu(self, next_step):
        if next_step == "2":
            self.db_drop()
            self.db_init()
            self.db_insert_somethings()
            print("Таблицы успешно инициализированы!")
            return "0"
        elif next_step != "1" and next_step != "9":
            print("Выбрано неверное число! Повторите ввод!")
            return "0"
        else:
            return next_step
            
    def show_categories(self):
        self.category_id = -1
        print("\nПросмотр списка категорий!\n№\tНазвание категории")
        lst = CategoryTable().all()
        for i, row in enumerate(lst):
            # row[0] - id, row[1] - name
            print(f"{i + 1}\t{row[1]}")
        
        menu = """Дальнейшие операции: 
    0 - возврат в главное меню;
    3 - добавление новой категории;
    4 - удаление категории;
    5 - просмотр блюд категории;
    8 - редактировать категорию;
    9 - выход."""
        print(menu)
        return

    def after_show_categories(self, next_step):
        while True:
            if next_step == "3":
                self.add_category()
                return "1"
            elif next_step == "4":
                self.delete_category()
                return "1"
            elif next_step == "8":
                self.edit_category()
                return "1"
            elif next_step == "5":
                next_step = self.show_dishes_by_category()
            elif next_step not in["0", "9"]:
                print("Выбрано неверное число! Повторите ввод!")
                return "1"
            else:
                return next_step

    def add_category(self):
        name = input("Введите название категории (0 - отмена): ").strip()
        if name == "0":
            return
        if len(name) == 0 or len(name) > 64:
            print("Ошибка: Название должно содержать от 1 до 64 символов!")
            return
        CategoryTable().insert_one([name])
        print("Категория успешно добавлена!")

    def delete_category(self):
        num = input("Укажите номер строки для удаления (0 - отмена): ").strip()
        if num == "0": return
        if not num.isdigit():
            print("Ошибка! Введите целое число.")
            return
        cat = CategoryTable().find_by_position(int(num))
        if not cat:
            print("Ошибка! Категория с таким номером не найдена.")
            return
        
        # Удаляем блюда привязанные к категории (каскадное удаление вручную)
        DishTable().delete("category_id = %s", [cat[0]])
        # Удаляем саму категорию
        CategoryTable().delete("id = %s", [cat[0]])
        print("Категория и связанные с ней блюда успешно удалены!")

    def edit_category(self):
        num = input("Укажите номер строки для редактирования (0 - отмена): ").strip()
        if num == "0": return
        if not num.isdigit():
            print("Ошибка! Введите целое число.")
            return
        cat = CategoryTable().find_by_position(int(num))
        if not cat:
            print("Ошибка! Категория с таким номером не найдена.")
            return
        
        new_name = input(f"Введите новое название для '{cat[1]}' (0 - отмена): ").strip()
        if new_name == "0": return
        if len(new_name) == 0 or len(new_name) > 64:
            print("Ошибка: Название должно содержать от 1 до 64 символов!")
            return
        
        CategoryTable().update(["name"], [new_name], "id = %s", [cat[0]])
        print("Категория успешно обновлена!")

    def show_dishes_by_category(self):
        if self.category_id == -1:
            while True:
                num = input("Укажите номер строки категории (0 - отмена): ").strip()
                if num == "0": return "1"
                if not num.isdigit():
                    print("Ошибка! Введите целое число.")
                    continue
                
                cat = CategoryTable().find_by_position(int(num))
                if not cat:
                    print("Категория с таким номером не найдена!")
                else:
                    self.category_id = int(cat[0])
                    self.category_obj = cat
                    break
        
        print(f"\nВыбрана категория: {self.category_obj[1]}")
        print("Список блюд:\n№\tНазвание")
        self.current_dishes = DishTable().all_by_category_id(self.category_id)
        
        if not self.current_dishes:
            print("Блюд пока нет.")
            
        for i, row in enumerate(self.current_dishes):
            print(f"{i + 1}\t{row[1]}")
            
        menu = """Дальнейшие операции:
    0 - возврат в главное меню;
    1 - возврат в список категорий;
    6 - добавление нового блюда;
    7 - удаление блюда;
    8 - редактирование блюда;
    9 - выход."""
        print(menu)
        
        next_step = self.read_next_step()
        if next_step == "6":
            self.add_dish()
            return "5"
        elif next_step == "7":
            self.delete_dish()
            return "5"
        elif next_step == "8":
            self.edit_dish()
            return "5"
        return next_step

    def add_dish(self):
        name = input("Введите название блюда (0 - отмена): ").strip()
        if name == "0": return
        if len(name) == 0 or len(name) > 64:
            print("Ошибка: Название должно содержать от 1 до 64 символов!")
            return
        
        for d in self.current_dishes:
            if d[1].lower() == name.lower():
                print("Ошибка: Блюдо с таким названием уже существует в этой категории!")
                return
                
        DishTable().insert_one([self.category_id, name])
        print("Блюдо успешно добавлено!")

    def delete_dish(self):
        if not self.current_dishes:
            print("В этой категории нет блюд для удаления.")
            return
            
        num = input("Укажите номер строки блюда для удаления (0 - отмена): ").strip()
        if num == "0": return
        if not num.isdigit():
            print("Ошибка! Введите целое число.")
            return
            
        num = int(num)
        if num < 1 or num > len(self.current_dishes):
            print("Ошибка! Блюдо с таким номером не найдено.")
            return
            
        target_dish_name = self.current_dishes[num - 1][1]
        DishTable().delete("category_id = %s AND name = %s",[self.category_id, target_dish_name])
        print("Блюдо успешно удалено!")

    def edit_dish(self):
        if not self.current_dishes:
            print("В этой категории нет блюд для редактирования.")
            return
            
        num = input("Укажите номер строки блюда для редактирования (0 - отмена): ").strip()
        if num == "0": return
        if not num.isdigit():
            print("Ошибка! Введите целое число.")
            return
            
        num = int(num)
        if num < 1 or num > len(self.current_dishes):
            print("Ошибка! Блюдо с таким номером не найдено.")
            return
            
        target_dish_name = self.current_dishes[num - 1][1]
        new_name = input(f"Введите новое название для '{target_dish_name}' (0 - отмена): ").strip()
        if new_name == "0": return
        if len(new_name) == 0 or len(new_name) > 64:
            print("Ошибка: Название должно содержать от 1 до 64 символов!")
            return
            
        for d in self.current_dishes:
            if d[1].lower() == new_name.lower():
                print("Ошибка: Блюдо с таким названием уже существует в этой категории!")
                return
                
        DishTable().update(["name"], [new_name], "category_id = %s AND name = %s", [self.category_id, target_dish_name])
        print("Блюдо успешно изменено!")

    def main_cycle(self):
        current_menu = "0"
        next_step = None
        while(current_menu != "9"):
            if current_menu == "0":
                self.show_main_menu()
                next_step = self.read_next_step()
                current_menu = self.after_main_menu(next_step)
            elif current_menu == "1":
                self.show_categories()
                next_step = self.read_next_step()
                current_menu = self.after_show_categories(next_step)
            elif current_menu == "5":
                current_menu = self.show_dishes_by_category()
            elif current_menu == "2":
                self.show_main_menu()
        print("До свидания!")    
        return

if __name__ == "__main__":
    m = Main()
    m.main_cycle()