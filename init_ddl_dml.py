import sqlite3

connect = sqlite3.connect('db_final.db')

if __name__ == '__main__':
    with open('./sql_scripts/init_ddl_dml.sql', encoding='UTF-8') as f:
        sql = f.read()
        with connect:
            cur = connect.cursor()
            cur.executescript(sql)
