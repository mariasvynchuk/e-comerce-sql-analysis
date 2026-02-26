--знаходження метрик для акаунтів: основні з групуванням і обчислення кількості створених акантуів (account_cnt)
WITH
  account_metrics AS(
  SELECT
    s.date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    COUNT(acs.account_id) AS account_cnt,
  FROM
    `DA.account` a
  JOIN
    `DA.account_session` acs
  ON
    a.id=acs.account_id
  JOIN
    `DA.session` s
  ON
    acs.ga_session_id=s.ga_session_id
  JOIN
    `DA.session_params` sp
  ON
    s.ga_session_id=sp.ga_session_id
  GROUP BY
    1,
    2,
    3,
    4,
    5),

--знаходження основних метрик для емейлів: кількість відправлених, відкритих і клікнутих
email_metrics AS(
SELECT
  DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
  sp.country,
  a.send_interval,
  a.is_verified,
  a.is_unsubscribed,
  COUNT(DISTINCT es.id_message) AS sent_msg,
  COUNT(DISTINCT eo.id_message) AS open_msg,
  COUNT(DISTINCT ev.id_message) AS visit_msg
FROM
  `DA.email_sent` es
LEFT JOIN
  `DA.email_open` eo
ON
  es.id_message=eo.id_message
LEFT JOIN
  `DA.email_visit` ev
ON
  es.id_message=ev.id_message
JOIN
  `DA.account_session` acs
ON
  es.id_account=acs.account_id
JOIN
  `DA.session` s
ON
  acs.ga_session_id=s.ga_session_id
JOIN
  `DA.account` a
ON
  acs.account_id=a.id
JOIN
  `DA.session_params` sp
ON
  acs.ga_session_id = sp.ga_session_id
GROUP BY
  1,
  2,
  3,
  4,
  5),

--обєднання даних по аканутах і емейлах з union
union_metrics AS(
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM
    account_metrics
  UNION ALL
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    0 AS account_cnt,
    sent_msg,
    open_msg,
    visit_msg
  FROM
    email_metrics),

--агрегація результатів обєднання
all_main_metrics AS(
SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  SUM(account_cnt) AS account_cnt,
  SUM(sent_msg) AS sent_msg,
  SUM(open_msg) AS open_msg,
  SUM(visit_msg) AS visit_msg
FROM
  union_metrics
GROUP BY
  1,
  2,
  3,
  4,
  5),

--обчислення додаткових метрик: кількість відправлених листів і створених акаунтів по країнах з windows функціями
total_country_cnt AS(
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt,
  FROM
    all_main_metrics),

--ранжування даних по країнах
ranking AS (
SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  account_cnt,
  sent_msg,
  open_msg,
  visit_msg,
  total_country_account_cnt,
  total_country_sent_cnt,
  DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
  DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
FROM
  total_country_cnt) 
  
--фільтрування даних, видалення рядків де обидва ранги більше 10
SELECT
  *
FROM
  ranking
WHERE
  rank_total_country_account_cnt<=10
  OR rank_total_country_sent_cnt<=10


