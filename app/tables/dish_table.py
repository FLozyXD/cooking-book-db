# Таблица Блюда

from dbtable import *

class DishTable(DbTable):
    def table_name(self):
        return self.dbconn.prefix + "dish"

    def columns(self):
        # ON DELETE CASCADE гарантирует, что блюда удалятся вместе с категорией,
        # но мы также реализуем это и в коде (как требует задание)
        return {"category_id":["integer", "REFERENCES " + self.dbconn.prefix + "category(id) ON DELETE CASCADE"],
                "name":["varchar(64)", "NOT NULL"]}
    
    def primary_key(self):
        return['category_id', 'name']    

    def table_constraints(self):
        return["PRIMARY KEY(category_id, name)"]

    def all_by_category_id(self, cid):
        sql = "SELECT * FROM " + self.table_name()
        sql += " WHERE category_id = %s"
        sql += " ORDER BY name"
        cur = self.dbconn.conn.cursor()
        cur.execute(sql, (cid,))
        return cur.fetchall()