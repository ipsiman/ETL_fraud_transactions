import os
import logging as log

import pandas as pd


def stg_load_passport_blacklist(conn, date):
    f_name = f'passport_blacklist_{date}.xlsx'
    if os.path.exists(f_name):
        df = pd.read_excel(f_name)
        df.to_csv(f'./archive/{f_name}.backup')
        df.to_sql(con=conn, name='stg_passport_blacklist', if_exists='replace')
        os.remove(f_name)
        log.info(f'Load "passport_blacklist_{date}.xlsx" success.')
    else:
        log.error(f'File "passport_blacklist_{date}.xlsx" not found! Check filename and date')


def stg_load_terminals(conn, date):
    f_name = f'terminals_{date}.xlsx'
    if os.path.exists(f_name):
        df = pd.read_excel(f_name)
        df.to_csv(f'./archive/{f_name}.backup')
        df.to_sql(con=conn, name='stg_terminals', if_exists='replace')
        os.remove(f_name)
        log.info(f'Load "terminals_{date}.xlsx" success.')
    else:
        log.error(f'File "terminals_{date}.xlsx" not found! Check filename and date')


def stg_load_transactions(conn, date):
    f_name = f'transactions_{date}.txt'
    if os.path.exists(f_name):
        df = pd.read_csv(f_name, sep=';')
        df.to_csv(f'./archive/{f_name}.backup')
        df.to_sql(con=conn, name='stg_transactions', if_exists='replace')
        os.remove(f_name)
        log.info(f'Load "transactions_{date}.txt" success.')
    else:
        log.error(f'File "transactions_{date}.txt" not found! Check filename and date')
