with my_users as (
	select * 
	from users
	where company_id = 1
),
/* Активность пользователя по дням*/
days_users_activity as (
	select user_id, date(created_at) as activ_date
	from coderun c
	join my_users u
	on u.id = c.user_id
	union
	select user_id, date(created_at) as activ_date
	from codesubmit c2 
	join my_users u
	on u.id = c2.user_id
	union
	select user_id, date(created_at) as activ_date
	from teststart t
	join my_users u
	on u.id = t.user_id
),
--
/* Сколько всего раз пользователи заходили в месяц (даже если заходил один и тот же человек) */
months_userentry as (
	select  to_char(entry_at, 'YYYY-MM') as month, count(*) as cnt,
	rank() over (order by to_char(entry_at, 'YYYY-MM') desc) -- ранг использую в дальнейшем
	from userentry u 
	join my_users mu
	on mu.id = u.user_id
	group by month
	order by month
),
--
/* Среднее количество и медиана заходов в месяц*/
avg_months_userentry as (
	select round(avg(cnt)) as month_avg_entries,
	percentile_disc(0.5) within group (order by cnt) as month_median_entries
	from months_userentry
	where cnt > 5 -- уберем месяца со слишком малым числом входов
),
--
/* Среднее за последние три месяца*/
last_3_month_entries as (
	select round(avg(cnt)) as last_3_month_avg_entries
	from months_userentry
	where rank in (1, 2, 3)
),
--
--
/* Количество пришедших пользователей по месяцам */
users_joined_on_month as (
	select to_char(date_joined, 'YYYY-MM') as month, count(distinct id) as cnt_joined
	from my_users
	group by month
),
/* Кол-во активных пользователей по месяцам */
MAU as (
	select to_char(activ_date, 'YYYY-MM') as month, count(distinct user_id) as mau
	from days_users_activity ua
	group by month
	order by month
),
/* Ищем процент активных пользователей, среднее MAU*/
mau_research as (
	select coalesce(m.month, u.month) as month, mau, coalesce (cnt_joined, 0) as cnt_joined, 
	sum(cnt_joined) over (order by coalesce(m.month, u.month)) as all_users,
	coalesce(round(mau*100.0/sum(cnt_joined) over (order by coalesce(m.month, u.month)), 2),0) as "% activ_users",
	round(avg(mau)  over ()) as avg_mau
	from MAU m
	full join users_joined_on_month u
	on m.month = u.month
	where mau > 3 -- убрали месяца со слишком малыми значениями
	order by month
),
--
--
/* Количество пришедших пользователей по неделям */
users_joined_on_week as (
	select to_char(date_joined, 'YYYY-WW') as week, count(distinct id) as cnt_joined
	from my_users
	group by week
),
/*Генерирую интервал недель, чтобы использовать join-ом и не потерять недели без активности*/
gen_weeks as (
	select to_char(generate_series(
	(select min(activ_date) from days_users_activity), 
	(select max(activ_date) from days_users_activity),
	'1 day'::interval), 'YYYY-WW') as week
	group by week
),
/* Кол-во активных пользователей по неделям */
wau as (
	select week, count(distinct user_id) as wau
	from days_users_activity ua
	full join gen_weeks g
	on to_char(activ_date, 'YYYY-WW') = g.week 
	group by  week
	order by week
),
/* Ищем процент активных пользователей, среднее WAU*/
wau_research as (
	select coalesce(w.week, uw.week) as week, wau,
	coalesce (cnt_joined, 0) as cnt_joined,
	sum(cnt_joined) over (order by coalesce(w.week, uw.week)) as all_users,
	coalesce(round(wau*100.0/sum(cnt_joined) over (order by coalesce(w.week, uw.week)), 2),0) as "activ_users (%)",
	round(avg(wau)  over ()) as avg_wau
	from wau w
	full join users_joined_on_week uw
	on w.week = uw.week
),
--
--
/*Генерирую интервал дней, чтобы использовать join-ом и не потерять дни без активности*/
gen_days as (
	select date(generate_series(
	(select min(activ_date) from days_users_activity), 
	(select max(activ_date) from days_users_activity),
	'1 day'::interval)) as day_date
),
/* Кол-во активных пользователей по дням */
DAU as (
	select day_date, count(distinct user_id) as dau
	from days_users_activity ua
	full join gen_days g
	on date(activ_date) = g.day_date
	group by day_date
	order by day_date
),
/* DAU и среднее DAU */
Average_DAU as (
	select *, round(avg(dau) over ()) as avg_dau
	from DAU
),
--
--
--
--
/* Посмотрим активность пользователей по дням недели и по часам*/
-- По дням недели
/* Делаю таблицу активностей с датой-временем c повторами, если есть */
all_users_activity as (
	select user_id, created_at as activ_date
	from coderun c 
	join my_users mu on
	c.user_id = mu.id
	union all
	select user_id, created_at as activ_date
	from codesubmit c2
	join my_users mu on
	c2.user_id = mu.id
	union all
	select user_id, created_at as activ_date
	from teststart t
	join my_users mu on
	t.user_id = mu.id
),
/*Использую сгенерированный интервал дней, написанный выше*/
dayweek_activ as (
	select gd.day_date as date, 
	to_char(date(gd.day_date), 'Day') as day_week, 
	count(user_id) as action_cnt, -- это количество действий пользователей
	count(distinct user_id) as users_cnt -- это количество самих пользователей
	from all_users_activity ua
	right join gen_days gd
	on date(activ_date) = gd.day_date
	group by date, day_week
	order by date
),
avg_dayweek_activ as (
	select day_week, sum(action_cnt) as action_cnt, 
	round(avg(action_cnt), 2) as avg_actions, 
	round(avg(users_cnt), 2) as avg_users,
	percentile_disc(0.5) within group (order by action_cnt) as median_actions
	from dayweek_activ
	group by day_week
	order by avg_actions desc
),
--
--
/* Активность по часам дня */
/*Генерирую интервал от 0 до 23, чтобы не пропустить часы без активности*/
gen_hours as (
	select date_trunc('hour', generate_series(
	(select min(activ_date) from all_users_activity),
	(select max(activ_date) from all_users_activity),
	'1 hour'::interval)) as hour
),
hour_activ as (
	select date(g.hour) as date, 
	extract(hour from g.hour) as hour,
	count(user_id) as actions_cnt, 
	count(distinct user_id) as users_cnt
	from all_users_activity aua
	right join gen_hours g
	on date(g.hour) = date(aua.activ_date) 
	and extract (hour from activ_date) = extract(hour from g.hour)
	group by date, g.hour
	order by date, g.hour
),
avg_hour_activ as (
	select hour, sum(actions_cnt) as actions_cnt, sum(users_cnt) as users_cnt,
	round(avg(actions_cnt), 2) as avg_actions,
	round(avg(users_cnt),2) as avg_users
	from hour_activ
	group by hour
	order by avg_actions desc
),
--
--
--
/* Посчитаем rolling retention*/
entry_info as (
	select u.user_id, date(date_joined) as joined, date(entry_at) as entry,  
	extract(days from entry_at - date_joined) as diff,
	to_char(date_joined, 'YYYY-MM') as cohort
	from userentry u
	join my_users m
	on u.user_id = m.id
	order by user_id, diff
),
rolling_retention as (
	select cohort, count(distinct user_id) as cohort_size,
	round(count(distinct case when diff >= 0 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "0 (%)",
	round(count(distinct case when diff >= 1 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "1 (%)",
	round(count(distinct case when diff >= 2 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "2 (%)",
	round(count(distinct case when diff >= 3 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "3 (%)",
	round(count(distinct case when diff >= 7 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "7 (%)",
	round(count(distinct case when diff >= 14 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "14 (%)",
	round(count(distinct case when diff >= 21 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "21 (%)",
	round(count(distinct case when diff >= 30 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "30 (%)",
	round(count(distinct case when diff >= 45 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "45 (%)",
	round(count(distinct case when diff >= 60 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "60 (%)",
	round(count(distinct case when diff >= 90 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "90 (%)",
	round(count(distinct case when diff >= 120 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "120 (%)" --интересно посмотреть за активными группами 2021-11 и 2021-12 месяцев
	from entry_info
	group by cohort
	having count(distinct user_id)>3 -- уберем слишком малые когорты
),
retention as (
	select cohort, count(distinct user_id) as cohort_size,
	round(count(distinct case when diff = 0 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "0 (%)",
	round(count(distinct case when diff = 1 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "1 (%)",
	round(count(distinct case when diff = 2 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "2 (%)",
	round(count(distinct case when diff = 3 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "3 (%)",
	round(count(distinct case when diff = 0 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "7 (%)",
	round(count(distinct case when diff = 14 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "14 (%)",
	round(count(distinct case when diff = 21 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "21 (%)",
	round(count(distinct case when diff = 30 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "30 (%)",
	round(count(distinct case when diff = 45 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "45 (%)",
	round(count(distinct case when diff = 60 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "60 (%)",
	round(count(distinct case when diff = 90 then user_id end)*100.0/
		count(distinct case when diff = 0 then user_id end), 2) as "90 (%)"
	from entry_info
	group by cohort
	having count(distinct user_id)>3 -- уберем слишком малые когорты
),
--
--
/* Посчитаем LT через суммирование ретеншен*/
all_days_retention as (
	select day, count(distinct case when diff = day then user_id end)*100.0/count(distinct case when diff = 0 then user_id end) as perc
	from entry_info
	cross join (select generate_series(0, 90, 1) as day) t
	group by day
),
LT as (
	select round(sum(perc)/100, 2) as lifetime
	from all_days_retention
),
--
--
/* Посчитаю rolling churn rate */
Rolling_churn_rate as (
	select cohort, 100 - "1 (%)" as "1 (%)",
	100 - "2 (%)" as "2 (%)",
	100 - "3 (%)" as "3 (%)",
	100 - "7 (%)" as "7 (%)",
	100 - "14 (%)" as "14 (%)",
	100 - "30 (%)" as "30 (%)",
	100 - "60 (%)" as "60 (%)"
	from rolling_retention
),
--
--
/* Посчитаем процент заходов без активности */
entries_without_activ as (
	select round(count(case when activ_date is null then 1 end)*100.0/count(*),2) as perc_without_activ
	from userentry u
	join my_users mu
	on u.user_id = mu.id
	left join days_users_activity ua
	on u.user_id = ua.user_id and date(u.entry_at) = ua.activ_date
),
--
--
--
/* Средняя длительность сессии */
/* Посчитаю разницу в минутах между активностями пользователя. 
 * Если она больше 60 - буду считать это новой сессией
 * Использую таблицу all_users_activity */
activity_timediff as (
	select *,
	lead(activ_date) over w as next_activ,
	extract(epoch from lead(activ_date) over w - activ_date)/60 as diff,
	case
		when extract(epoch from lead(activ_date) over w - activ_date)/60 <60 then 0
		else 1
	end as new_session
	from all_users_activity
	window w as (partition by user_id order by activ_date)
),
session_markers AS (
    SELECT *,
    SUM(new_session) OVER (PARTITION BY user_id 
    ORDER BY activ_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_id,
    case 
		when diff>60 then 0
		else diff
	end as new_diff
    FROM activity_timediff
),
session_duration as (
	select user_id, session_id, sum(new_diff) as duration
	from session_markers
	group by user_id, session_id
	order by user_id, session_id
),
avg_session_duration as (
	select round(avg(duration)) as avg_minute,
	round(percentile_disc(0.5) within group (order by duration)) as median_minute
	from session_duration
),
user_session_info as (
	select user_id, 
	count(session_id) as session_cnt,
	round(avg(duration)) as avg_minute,
	(select avg_minute from avg_session_duration) as avg_session_dur
	from session_duration
	group by user_id
)
select perc, percentile_disc(perc) within group (order by avg_minute) as duration 
from user_session_info, pg_catalog.generate_series(0.1, 1, 0.1) perc
group by perc


--
--
--
--
/* Количество задач на язык и всего*/
language_problems_count as (	
	select  lang_id, l.name, count(*) as problem_cnt,
	sum(count(*)) over () as all_problems
	from languagetoproblem lp
	join language l
	on l.id = lp.lang_id
	group by lang_id, l.name
),
--
--
/* Процент успешных решений задач */
perc_right as (
	select round(count(case when is_false = 0 then 1 end)*100.0/count(*), 2) as perc_right
	from codesubmit c
	join my_users mu
	on c.user_id = mu.id
),
--
/* В разрезе сложности*/
perc_right_with_compl as (
	select complexity, round(count(case when is_false = 0 then 1 end)*100.0/count(*), 2) as perc_right,
	count(*) as submit_cnt,
	count(distinct problem_id) as problem_cnt,
	count(distinct mu.id) as user_cnt
	from codesubmit c
	join my_users mu
	on c.user_id = mu.id
	join problem p
	on p.id = c.problem_id
	group by complexity
),
/* В разрезе языка*/
perc_right_with_lang as (
	select l.name, round(count(case when is_false = 0 then 1 end)*100.0/count(*), 2) as perc_right,
	count(*) as submit_cnt,
	count(distinct problem_id) as problem_cnt,
	count(distinct mu.id) as user_cnt
	from codesubmit c
	join my_users mu
	on c.user_id = mu.id
	join problem p
	on p.id = c.problem_id
	join languagetoproblem lp
	on lp.pr_id = p.id
	join language l
	on l.id = lp.lang_id
	group by l.name
),
--
--
/*Посмотрим, сколько человек пыталось решить каждую из задач и процент успешных проверок*/
problems_info as (
	select p.id as problem_id, complexity, name, count(distinct user_id) as users_cnt,
	round(count(case when is_false = 0 then 1 end)*100.0/count(*),2) as perc_right
	from codesubmit c 
	join my_users mu
	on c.user_id = mu.id
	right join problem p 
	on p.id = c.problem_id
	where is_visible is true  -- чтобы пользователи видели эти задачи
	group by p.id, complexity, name
	order by users_cnt desc
),
--
--
/* Сколько попыток в среднем решал задачу пользователь */
attempts_cnt as (
	select c.user_id, c.problem_id, p.complexity, count(*) as cnt,
	min(is_false) as not_done
	from my_users mu
	join codesubmit c
	on mu.id = c.user_id
	join problem p
	on p.id = c.problem_id
	group by c.user_id, c.problem_id, p.complexity
),
--
/*Сколько в среднем уходит на задачу попыток, и решил ли её кто-то в итоге*/
avg_attempts_problem as (
	select problem_id, avg(cnt) as avg_attempts, min(not_done) as not_done
	from attempts_cnt
	group by problem_id
	order by avg_attempts desc
),
--
/* Количество и процент успешно решенных/нерешенных в итоге задач */
problems_done as (
	select not_done, count(*),
	round(count(*)*100.0/sum(count(*)) over (), 2) as "%"
	from attempts_cnt
	group by not_done
),
/* Сколько в среднем попыток на задачу определенной сложности, если задача была выполнена */
attempts_by_complexity as (
	select complexity, avg(cnt),
	percentile_disc(0.5) within group (order by cnt) 
	from attempts_cnt
	where not_done = 0
	group by complexity
),
--
--
/* Статистика, какие задачи человек решал и получилось ли у него это сделать */
user_problems as (
	select user_id, username, problem_id,
	case when min(is_false) = 0 then true else false end as done
	from codesubmit c 
	join my_users mu
	on c.user_id = mu.id
	group by user_id, username, problem_id
	order by user_id, problem_id
),
/* Статистика, какие задачи человек решал и получилось ли у него это сделать, а также сколько задач он пытался решить, сколько решил всего и процент успеха*/
user_problems_info as (
	select *,
	count(problem_id) over w as cnt_problems,
	count(case when done is true then 1 end) over w as cnt_right,
	round(count(case when done is true then 1 end) over w *100.0/count(problem_id) over w) as "right (%)"
	from user_problems
	window w as (partition by user_id)
),
/* Среднее и медиана процента успешно решенных задач */
avg_right_problems as (
	select round(avg("right (%)"), 2) as avg_right,
	percentile_disc(0.5) within group (order by "right (%)") as median_right 
	from user_problems_info
),
--
--
--
/* Тесты */
--
/* Количество тестов, которые решал каждый студент*/
users_test as (
	select user_id, count(*) as test_cnt
	from teststart t
	join my_users mu
	on t.user_id = mu.id
	group by user_id
),
/* Сколько раз пользователи приступали к какому-либо тесту */
teststart_count as (
	select test_id, count(*) as start_cnt
	from teststart t
	join my_users mu
	on mu.id = t.user_id
	group by test_id
	order by start_cnt desc
),
--
/* Ответы пользователя в каждом тесте и сравнение с правильным*/
users_answers as (
	select user_id, 
	t.question_id, 
	t2.value, answer_id, 
	bool_and(case when answer_id is not null then is_correct else false end) as is_correct, 
	t3.created_at, 
	/* ранг для того, чтобы разгранить разные прохождения тестов друг от друга */
	rank() over (partition by user_id, t2.test_id, t.question_id order by created_at) as rank_order, 
	t2.test_id,
	te.name
	from testanswer t
	join testquestion t2 
	on t.question_id = t2.id
	right join testresult t3 
	on t3.test_id = t2.test_id and t3.question_id = t.question_id
	join my_users mu
	on mu.id = t3.user_id
	join test te
	on te.id = t2.test_id
	where coalesce(answer_id, t.id) = t.id -- оставляет ответы, которые совпадают с одним из вариантов ответа, и null-ы
	group by user_id, t.question_id, t2.value, t2.test_id, answer_id, t3.created_at, te.name -- сделано для того, чтобы убрать множественный null
	order by user_id, question_id, test_id
),
--
/* Статистика прохождения тестов по пользователю с процентом верных ответов*/
users_tests_info as (
	select user_id, test_id, date(created_at) as created_at, rank_order, count(*) as all_quest, 
	count(case when is_correct is true then 1 end) as right_answer,
	round(count(case when is_correct is true then 1 end)*100.0/count(*), 2) as  "right (%)"
	from users_answers
	group by user_id, test_id, rank_order, date(created_at)
),
--
/* Исследование проходимости тестов*/
testresult_research as (
	select test_id, count(*) as cnt,
	max(all_quest) as all_quest,
	round(avg(right_answer), 2) as avg_right_answer,
	round(avg("right (%)"), 2) as "avg_right (%)"
	from users_tests_info
	group by test_id
),
--
--
--
--
/* Какая разница в часах между заходами на платформу? */
entries_difference as (
	select user_id, entry_at, 
	lead(entry_at) over w as next_entry,
	round(extract(epoch from lead(entry_at) over w - entry_at)::numeric/3600, 2) as diff_hour 
	from userentry u 
	join my_users mu
	on mu.id = u.user_id
	window w as (partition by user_id order by entry_at)
),
avg_entries_diff as (
	select round(avg(diff_hour), 2) as avg,
	percentile_cont(0.5) within group (order by diff_hour) as median, 
	min(diff_hour), max(diff_hour),
	count(entry_at) as cnt_entries
	from entries_difference
),
--
--
/* Транзакции Codecoins */
--
/* Тип «списание» имеют записи с id: 1, 23-28
 * Тип «начисление» имеют записи с id: 2-22, 29
 * 
 * Когда будете работать с таблицей Транзакций, не берите в расчет транзакции больше 
 * или равные 500 монет - это начисления бета-тестерам, они будут сильно мешать.*/
--
/* Списания, пополнения и баланс пользователей */
users_transactions as (
	select user_id,
	sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value end) as write_off,
	sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then value end) as accruals,
	sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value else value end) as balance
	from transaction t
	join my_users mu
	on t.user_id = mu.id
	where value<=500
	group by user_id
),
avg_balance as (
	select round(avg(write_off), 2) as write_off, round(avg(accruals), 2) as accruals, 
	round(avg(balance), 2) as balance
	from users_transactions
),
--
--
/* Распределение баланса пользователей по перцентилям */
users_balance as (
	select user_id,
	sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value else value end) as balance
	from transaction t
	join my_users mu	
	on t.user_id = mu.id
	where value<=500
	group by user_id
),
percentile_balance as (
	select perc, percentile_disc(perc) within group (order by balance) as balance
	from users_balance, generate_series(0.1, 1, 0.1) as perc
	group by perc
),
--
--
/*Общий объем транзакций CodeCoins по типам. */
transaction_type_sum as (
	select type_id, description,
	sum(t.value) as summ
	from transaction t
	join transactiontype ty 
	on ty.type = t.type_id
	group by type_id, description
	order by type_id
),
all_transactions_info as (
	select sum(summ) as all_transactions_value,
	sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then summ end) as write_off,
	sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then summ end) as accurals
	from transaction_type_sum
)