# Таблица категорий (без древовидной структуры)

from dbtable import *

class CategoryTable(DbTable):
    def table_name(self):
        return self.dbconn.prefix + "category"

    def columns(self):
        return {"id": ["serial", "PRIMARY KEY"],
                "name":["varchar(64)", "NOT NULL"]}

    def find_by_position(self, num):
        sql = "SELECT * FROM " + self.table_name()
        sql += " ORDER BY " + ", ".join(self.primary_key())
        sql += " LIMIT 1 OFFSET %s"
        cur = self.dbconn.conn.cursor()
        cur.execute(sql, (num - 1,))
        return cur.fetchone()