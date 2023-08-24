-- Просрочен или заблокирован паспорт
INSERT INTO rep_fraud(
	event_dt,
	passport,
	fio,
	phone,
	event_type)
SELECT dt.transaction_date AS event_dt,
	   dcl.passport_num AS passport,
	   dcl.last_name || ' ' || dcl.first_name || ' ' || dcl.patronymic AS fio,
	   dcl.phone AS phone,
	   'Просрочен или заблокирован паспорт' AS event_type
FROM dwh_fact_transactions dt
LEFT JOIN dwh_dim_cards dc ON dt.card_num = dc.card_num
LEFT JOIN dwh_dim_accounts da ON dc.account = da.account
LEFT JOIN dwh_dim_clients dcl ON da.client = dcl.client_id
WHERE date(dt.transaction_date) = '2021-03-02'
  AND (dcl.passport_valid_to < dt.transaction_date
    OR dcl.passport_num IN (SELECT passport FROM dwh_fact_passport_blacklist));


-- Недействующий договор
INSERT INTO rep_fraud(
	event_dt,
	passport,
	fio,
	phone,
	event_type)
SELECT dt.transaction_date AS event_dt,
	   dcl.passport_num AS passport,
	   dcl.last_name || ' ' || dcl.first_name || ' ' || dcl.patronymic AS fio,
	   dcl.phone AS phone,
	   'Недействующий договор' AS event_type
FROM dwh_fact_transactions dt
LEFT JOIN dwh_dim_cards dc ON dt.card_num = dc.card_num
LEFT JOIN dwh_dim_accounts da ON dc.account = da.account
LEFT JOIN dwh_dim_clients dcl ON da.client = dcl.client_id
WHERE date(dt.transaction_date) = '2021-03-02'
  AND da.valid_to < dt.transaction_date;


-- Совершение операций в разных городах в течение одного часа
INSERT INTO rep_fraud(
	event_dt,
	passport,
	fio,
	phone,
	event_type)
WITH table_info AS(
	SELECT dt.transaction_id,
		   dt.transaction_date,
		   ter.terminal_city,
		   dcl.last_name,
		   dcl.first_name,
		   dcl.patronymic,
		   dcl.phone,
		   dcl.passport_num
	FROM dwh_fact_transactions dt
	LEFT JOIN dwh_dim_terminals ter ON dt.terminal = ter.terminal_id
	LEFT JOIN dwh_dim_cards dc ON dt.card_num = dc.card_num
	LEFT JOIN dwh_dim_accounts da ON dc.account = da.account
	LEFT JOIN dwh_dim_clients dcl ON da.client = dcl.client_id
	WHERE date(dt.transaction_date) = '2021-03-02')
SELECT DISTINCT t1.transaction_date AS event_dt,
	   t1.passport_num AS passport,
	   t1.last_name || ' ' || t1.first_name || ' ' || t1.patronymic AS fio,
	   t1.phone AS phone,
	   'Совершение операций в разных городах в течение одного часа' AS event_type
FROM table_info t1
JOIN table_info t2 ON t1.transaction_id <> t2.transaction_id
WHERE t1.transaction_date >= datetime(t2.transaction_date, '-1 hour')
  AND t1.transaction_date <= datetime(t2.transaction_date, '1 hour')
  AND t1.passport_num = t2.passport_num
  AND t1.terminal_city <> t2.terminal_city;


 -- Попытка подбора суммы
 INSERT INTO rep_fraud(
	event_dt,
	passport,
	fio,
	phone,
	event_type)
 WITH table_info AS(
	SELECT dt.transaction_id,
		   dt.transaction_date,
		   dt.amount,
		   dt.oper_result,
		   dcl.last_name,
		   dcl.first_name,
		   dcl.patronymic,
		   dcl.phone,
		   dcl.passport_num,
		   LAG(dt.transaction_date, 1, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) tlag_1,
		   LAG(dt.transaction_date, 2, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) tlag_2,
		   LAG(dt.transaction_date, 3, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) tlag_3,
		   LAG(dt.amount, 1, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) alag_1,
		   LAG(dt.amount, 2, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) alag_2,
		   LAG(dt.amount, 3, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) alag_3,
		   LAG(dt.oper_result, 1, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) reslag_1,
		   LAG(dt.oper_result, 2, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) reslag_2,
		   LAG(dt.oper_result, 3, NULL) OVER(PARTITION BY dcl.passport_num ORDER BY dt.transaction_date) reslag_3
	FROM dwh_fact_transactions dt
	LEFT JOIN dwh_dim_terminals ter ON dt.terminal = ter.terminal_id
	LEFT JOIN dwh_dim_cards dc ON dt.card_num = dc.card_num
	LEFT JOIN dwh_dim_accounts da ON dc.account = da.account
	LEFT JOIN dwh_dim_clients dcl ON da.client = dcl.client_id
	WHERE date(dt.transaction_date) = '2021-03-02')
SELECT transaction_date AS event_dt,
	   passport_num AS passport,
	   last_name || ' ' || first_name || ' ' || patronymic AS fio,
	   phone AS phone,
	   'Попытка подбора суммы' AS event_type
FROM table_info
WHERE (strftime('%s', transaction_date) - strftime('%s', tlag_3)) < 60 * 20
  AND amount < alag_1 AND alag_1 < alag_2 AND alag_2 < alag_3
  AND oper_result = 'SUCCESS' AND reslag_1 = 'REJECT' AND reslag_2 = 'REJECT' AND reslag_3 = 'REJECT';
