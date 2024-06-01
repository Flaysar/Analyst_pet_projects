-- Проект выполняется в интерактивном тренажере на платформе Simulative --

/* Задание 1. Задача посчитать:
сколько в среднем задач решает один пользователь (пусть даже неправильно, но хотя бы делает попытку)
сколько в среднем тестов начинает проходить один пользователь (пусть даже не заканчивает)
медианное значение решаемых задач
медианное значение проходимых тестов
Важный момент: Это все должно быть посчитано одним запросом.
Используются таблицы TestStart, CodeRun  и CodeSubmit
*/
with all_code as (
  select user_id, problem_id
from CodeSubmit
union all
SELECT user_id, problem_id
from coderun
),

problems_for_user as (
  SELECT user_id, count(DISTINCT problem_id) as problems_cnt
from all_code cd
GROUP by user_id
),

tests_for_user as (
  select user_id, count(DISTINCT test_id ) as test_cnt
from teststart
GROUP by user_id)

select round(avg(problems_cnt), 2) as problems_avg ,
round(avg(test_cnt), 2) as tests_avg,
PERCENTILE_disc(0.5) within GROUP (order by problems_cnt) as problems_median,
PERCENTILE_disc(0.5) within GROUP (order by test_cnt) as tests_median 
from problems_for_user pu
full join tests_for_user tu
on pu.user_id = tu.user_id

/* Задание 2.  Нужно посчитать:
Сколько монет в среднем пользователь списывает за весь срок жизни?
Сколько монет в среднем пользователю начисляется за весь срок жизни?
Какая в среднем разница между этими двумя числами?
Не учитываются транзакции с value >= 500 (это для тестеров)
Используется таблица TRANSACTION
*/
with agg as (select 
sum(case when (type_id BETWEEN 23 and 28) or type_id=1 then -value end) as write_off,
sum(case when (type_id not BETWEEN 23 and 28) and type_id!=1 then value end) as accurals,
sum(case when (type_id not BETWEEN 23 and 28) and type_id!=1 then value else -value end) as balance 
from TRANSACTION
where value<500
GROUP by user_id
)

select round(avg(write_off), 2) as write_off,
round(avg(accurals), 2) as accurals,
round(avg(balance), 2) as balance
from agg

/* Задание 3. Нужно посчитать:
баланс каждого пользователя и найти распределение баланса по перцентилям с шагом 0.1, не учитывая транзакции с value >= 500 (это для тестеров) и людей с id кампании = 1
*/
with agg as (
  select user_id,
  sum(case when (type_id not BETWEEN 23 and 28) and type_id!=1 then value else -value end) as balance 
from TRANSACTION
where value<500
GROUP by user_id
),

balance_for_user as (
  select balance
from agg 
join users u
on agg.user_id = u.id
where COALESCE(company_id, 0)!=1
)

select perc, PERCENTILE_DISC(perc) WITHIN GROUP (order by balance) as balance
from balance_for_user, generate_series(0.1, 1, 0.1) as perc
GROUP by perc

/* Задание 4. Надо посчитать % визитов, в которых человек зашел на платформу (есть запись в UserEntry за конкретный день), 
но не проявил активность (нет записей в CodeRun, CodeSubmit, TestStart за этот же день). */
with all_active as (
    select user_id,
        date(created_at) as dt
    from
        coderun c
    union
    select user_id,
        date(created_at) as dt
    from
        codesubmit c2
    union
    select user_id,
        date(created_at) as dt
    from
        teststart
)

select 100 - round(count(dt)*100.0/count(*), 2) as entries_without_activities
from userEntry ue
left join all_active ac
on ue.user_id = ac.user_id
and date(ue.entry_at) = dt

/* Задание 5. Написать запрос для расчета MAU на основании заходов пользователей на платформу (UserEntry). */
with month as (
  select to_char(entry_at, 'YYYY-MM') as month
from userEntry
GROUP by to_char(entry_at, 'YYYY-MM')
HAVING count(DISTINCT date(entry_at))>=25
),

users_for_month as (SELECT to_char(entry_at, 'YYYY-MM') as month, count(DISTINCT user_id) as cnt
from userEntry
where to_char(entry_at, 'YYYY-MM') in (select * from month)
GROUP by to_char(entry_at, 'YYYY-MM')
)

select round(avg(cnt)) as mau
from users_for_month

/* Задание 6. Расчет n-day retention по месяцам для 0, 1, 3, 7, 14, 30, 60, 90 дня */
with agg as (
  select to_char(date_joined, 'YYYY-MM') as cohort, 
  ue.user_id, date(date_joined) as date_join,
date(entry_at) as activ,
EXTRACT(days from entry_at-date_joined) as diff
from userEntry ue
join users u
on u.id = ue.user_id
where to_char(date_joined, 'YYYY') = '2022'
)

select cohort, 
count(distinct case when diff = 0 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end) as "0 (%)",
round(count(distinct case when diff = 1 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "1 (%)",
round(count(distinct case when diff = 3 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "3 (%)",
round(count(distinct case when diff = 7 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "7 (%)",
round(count(distinct case when diff = 14 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "14 (%)",
round(count(distinct case when diff = 30 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "30 (%)",
round(count(distinct case when diff = 60 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "60 (%)",
round(count(distinct case when diff = 90 then user_id end)*100.0/count(distinct case when diff = 0 then user_id end), 2) as "90 (%)"
from agg
GROUP by cohort

/* Задание 7. Расчет rolling n-day retention по месяцам для 0, 1, 3, 7, 14, 30, 60, 90 дня */
with agg as (
  select to_char(date_joined, 'YYYY-MM') as cohort, 
  ue.user_id, date(date_joined) as date_join,
date(entry_at) as activ,
EXTRACT(days from entry_at-date_joined) as diff
from userEntry ue
join users u
on u.id = ue.user_id
where to_char(date_joined, 'YYYY') = '2022'
)

select cohort, 
count(distinct case when diff >= 0 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end) as "0 (%)",
round(count(distinct case when diff >= 1 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "1 (%)",
round(count(distinct case when diff >= 3 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "3 (%)",
round(count(distinct case when diff >= 7 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "7 (%)",
round(count(distinct case when diff >= 14 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "14 (%)",
round(count(distinct case when diff >= 30 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "30 (%)",
round(count(distinct case when diff >= 60 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "60 (%)",
round(count(distinct case when diff >= 90 then user_id end)*100.0/count(distinct case when diff >= 0 then user_id end), 2) as "90 (%)"
from agg
GROUP by cohort
