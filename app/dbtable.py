# Базовые действия с таблицами

class DbTable:
    dbconn = None

    def __init__(self):
        return

    def table_name(self):
        return self.dbconn.prefix + "table"

    def columns(self):
        return {"test": ["integer", "PRIMARY KEY"]}

    def column_names(self):
        return sorted(self.columns().keys(), key = lambda x: x)

    def primary_key(self):
        return ['id']

    def column_names_without_id(self):
        res = sorted(self.columns().keys(), key = lambda x: x)
        if 'id' in res:
            res.remove('id')
        return res

    def table_constraints(self):
        return []

    def create(self):
        sql = "CREATE TABLE " + self.table_name() + "("
        arr = [k + " " + " ".join(v) for k, v in sorted(self.columns().items(), key = lambda x: x[0])]
        sql += ", ".join(arr + self.table_constraints())
        sql += ")"
        cur = self.dbconn.conn.cursor()
        cur.execute(sql)
        self.dbconn.conn.commit()
        return

    def drop(self):
        sql = "DROP TABLE IF EXISTS " + self.table_name() + " CASCADE"
        cur = self.dbconn.conn.cursor()
        cur.execute(sql)
        self.dbconn.conn.commit()
        return

    def insert_one(self, vals):
        cols = self.column_names_without_id()
        placeholders = ", ".join(["%s"] * len(vals))
        sql = "INSERT INTO " + self.table_name() + " (" + ", ".join(cols) + ") VALUES (" + placeholders + ")"
        cur = self.dbconn.conn.cursor()
        cur.execute(sql, vals)
        self.dbconn.conn.commit()
        return

    def first(self):
        sql = "SELECT * FROM " + self.table_name()
        sql += " ORDER BY "
        sql += ", ".join(self.primary_key())
        cur = self.dbconn.conn.cursor()
        cur.execute(sql)
        return cur.fetchone()        

    def last(self):
        sql = "SELECT * FROM " + self.table_name()
        sql += " ORDER BY "
        sql += ", ".join([x + " DESC" for x in self.primary_key()])
        cur = self.dbconn.conn.cursor()
        cur.execute(sql)
        return cur.fetchone()

    def delete(self, condition_str, params):
        sql = "DELETE FROM " + self.table_name() + " WHERE " + condition_str
        cur = self.dbconn.conn.cursor()
        cur.execute(sql, params)
        self.dbconn.conn.commit()
        return

    def update(self, col_names, vals, condition_str, cond_params):
        set_str = ", ".join([f"{col} = %s" for col in col_names])
        sql = "UPDATE " + self.table_name() + " SET " + set_str + " WHERE " + condition_str
        cur = self.dbconn.conn.cursor()
        cur.execute(sql, vals + cond_params)
        self.dbconn.conn.commit()
        return

    def all(self):
        sql = "SELECT * FROM " + self.table_name()
        sql += " ORDER BY " + ", ".join(self.primary_key())
        cur = self.dbconn.conn.cursor()
        cur.execute(sql)
        return cur.fetchall()
