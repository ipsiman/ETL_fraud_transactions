def dwh_update_passport_blacklist(conn):
    with conn:
        cur = conn.cursor()
        cur.execute('''
            INSERT INTO dwh_fact_passport_blacklist (date, passport)
            SELECT date,
                   passport
            FROM stg_passport_blacklist
            WHERE passport NOT IN(
              SELECT passport
              FROM dwh_fact_passport_blacklist);
        ''')


def dwh_update_terminals(conn):
    with conn:
        cur = conn.cursor()
        cur.execute('''
            INSERT INTO dwh_dim_terminals(
              terminal_id,
              terminal_type,
              terminal_city,
              terminal_address)
            SELECT terminal_id,
                   terminal_type,
                   terminal_city,
                   terminal_address
            FROM stg_terminals
            WHERE terminal_id NOT IN(
              SELECT terminal_id
              FROM dwh_dim_terminals);
        ''')


def dwh_update_transactions(conn):
    with conn:
        cur = conn.cursor()
        cur.execute('''
            INSERT INTO dwh_fact_transactions(
              transaction_id,
              transaction_date,
              amount,
              card_num,
              oper_type,
              oper_result,
              terminal)
            SELECT transaction_id,
                   transaction_date,
                   amount,
                   card_num,
                   oper_type,
                   oper_result,
                   terminal
            FROM stg_transactions
            WHERE transaction_id NOT IN(
              SELECT transaction_id
              FROM dwh_fact_transactions);
        ''')
