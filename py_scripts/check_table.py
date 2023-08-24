import logging as log


def check_table(connect, check_tables) -> bool:
    check = True
    with connect:
        cursor = connect.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        tables = [t[0] for t in tables]

        for i in check_tables:
            if i in tables:
                log.info(f'Check table {i}. Ok!')
            else:
                log.info(f'Table {i} not found! Run "init_ddl_dml.py"')
                check = False
    return check
