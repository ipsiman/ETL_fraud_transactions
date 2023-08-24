import os
import re

import sqlite3

from py_scripts import check_table, stg_load, dwh_update, dm_fraud_update

connect = sqlite3.connect('db_final.db')

check_tables = (
    'rep_fraud', 'dwh_fact_transactions', 'dwh_dim_terminals',
    'dwh_fact_passport_blacklist', 'dwh_dim_clients',
    'dwh_dim_accounts', 'dwh_dim_cards'
)

if __name__ == '__main__':
    file_filter = ['passport_blacklist', 'terminals', 'transactions']
    folder_path = './'
    files = os.listdir(folder_path)
    filtered_files = [f for f in files if any(word in f for word in file_filter)]

    dates = set(re.findall(r'\d{8}', str(filtered_files)))
    sorted_dates = sorted(dates, key=lambda x: (x[4:8], x[2:4], x[0:2]))

    if not check_table(connect, check_tables):
        print(f'Table not found! Run "init_ddl_dml.py"')
    else:
        if sorted_dates:
            for date in sorted_dates:
                stg_load.stg_load_passport_blacklist(connect, date)
                stg_load.stg_load_terminals(connect, date)
                stg_load.stg_load_transactions(connect, date)

                dwh_update.dwh_update_passport_blacklist(connect)
                dwh_update.dwh_update_terminals(connect)
                dwh_update.dwh_update_transactions(connect)

                dm_fraud_update(connect, date)
        else:
            print('Файлы для загрузки не найдены.')
