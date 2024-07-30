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
	select  to_char(entry_at, 'YYYY-MM') as month, count(*) as entry_cnt,
	count(distinct user_id) as user_cnt,
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
	select round(avg(entry_cnt)) as month_avg_entries,
	percentile_disc(0.5) within group (order by entry_cnt) as month_median_entries,
	round(avg(user_cnt)) as month_avg_users,
	percentile_disc(0.5) within group (order by user_cnt) as month_median_users
	from months_userentry
	where entry_cnt > 5 -- уберем месяца со слишком малым числом входов
),
--
/* Среднее за последние три месяца*/
last_3_month_entries as (
	select round(avg(entry_cnt)) as avg_last_3_month_entries,
	round(avg(user_cnt)) as avg_last_3_month_users
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
activ_users_on_month as (
	select to_char(activ_date, 'YYYY-MM') as month, count(distinct user_id) as users_cnt
	from days_users_activity ua
	group by month
	order by month
),
--
/* Ищем процент активных пользователей, среднее MAU*/
mau_research as (
	select m.month as month, users_cnt, coalesce (cnt_joined, 0) as cnt_joined, 
	sum(cnt_joined) over (order by coalesce(m.month, u.month)) as all_users,
	coalesce(round(users_cnt*100.0/sum(cnt_joined) over (order by coalesce(m.month, u.month)), 2),0) as "activ_users (%)",
	round(avg(users_cnt)  over ()) as MAU
	from activ_users_on_month m
	full join users_joined_on_month u
	on m.month = u.month
	where users_cnt > 3 -- убрали месяца со слишком малыми значениями
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
activ_users_on_week as (
	select week, count(distinct user_id) as users_cnt
	from days_users_activity ua
	full join gen_weeks g
	on to_char(activ_date, 'YYYY-WW') = g.week 
	group by  week
	order by week
),
/* Ищем процент активных пользователей, среднее WAU*/
wau_research as (
	select coalesce(w.week, uw.week) as week, coalesce (users_cnt, 0) as users_cnt,
	coalesce (cnt_joined, 0) as cnt_joined,
	sum(cnt_joined) over (order by coalesce(w.week, uw.week)) as all_users,
	coalesce(round(users_cnt*100.0/sum(cnt_joined) over (order by coalesce(w.week, uw.week)), 2),0) as "activ_users (%)",
	round(avg(users_cnt)  over ()) as WAU
	from activ_users_on_week w
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
activ_users_on_day as (
	select day_date, count(distinct user_id) as users_cnt
	from days_users_activity ua
	full join gen_days g
	on date(activ_date) = g.day_date
	group by day_date
	order by day_date
),
/* DAU и среднее DAU */
DAU as (
	select *, round(avg(users_cnt) over ()) as dau
	from activ_users_on_day
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
/* Посчитаем LT*/
users_entries_different as (
	select user_id, date(entry_at) as entry, 
	date(lead(entry_at) over w) as next_entry,
	extract(days from lead(entry_at) over w - entry_at) as diff
	from userentry u
	join my_users m
	on u.user_id = m.id
	where to_char(date_joined, 'YYYY-MM') not in ('2021-07', '2021-08') 
	window w as (partition by user_id order by entry_at)
),
lifes_markers as (
	select *, case 
		when diff < 30 then 0
		else 1
	end as new_user_life
	from users_entries_different
	where next_entry is not null
),
lifes_id as (
	select *, sum(new_user_life) over (partition by user_id 
	rows between unbounded preceding and current row) as user_life_id
	from lifes_markers
),
users_life_duration as (
	select user_id, user_life_id, sum(case when new_user_life = 1 then 0 else diff end) as duration
	from lifes_id
	group by user_id, user_life_id
	order by user_id
),
LT as (
	select round(avg(duration)) as duration
	from users_life_duration
),
--
--
/* Посчитаю rolling churn rate */
rolling_churn_rate as (
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
),
duration_percentile as (
	select perc, percentile_cont(perc) within group (order by avg_minute) as duration 
	from user_session_info, pg_catalog.generate_series(0.1, 1, 0.1) perc
	group by perc
),
--
--
--
/* Кол-во заданий и тестов */
problems_and_tests_cnt as (
	select 'problems' as type, count(id) as cnt
	from problem
	union 
	select 'tests', count(id)
	from test
),
--
--
/* Количество задач на язык и всего*/
language_problems_count as (	
	select  l.name, count(*) as problem_cnt,
	sum(count(*)) over () as all_problems
	from languagetoproblem lp
	join language l
	on l.id = lp.lang_id
	group by l.name
),
/* Количество задач на сложность*/
complexity_problems_count as (
	select complexity, count(*)
	from problem
	group by complexity
),
--
--
--
/* В разрезе сложности*/
perc_right_with_compl as (
	select complexity, 
	round(count(case when is_false = 0 then 1 end)*100.0/count(*), 2) as perc_right,
	count(*) as submit_cnt,
	count(case when is_false = 0 then 1 end) as right_submit_cnt,
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
	count(case when is_false = 0 then 1 end) as right_submit_cnt,
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
	select p.id as problem_id, 
	complexity, 
	p.name, 
	lg.name as lang,
	count(distinct user_id) as users_cnt,
	round(count(case when is_false = 0 then 1 end)*100.0/count(*),2) as perc_right,
	rank() over (order by count(distinct user_id) desc) as rank_in_users
	from codesubmit c 
	join my_users mu
	on c.user_id = mu.id
	right join problem p 
	on p.id = c.problem_id
	join languagetoproblem l  
	on l.pr_id = p.id
	join language lg
	on lg.id = l.lang_id
	where is_visible is true  -- чтобы пользователи видели эти задачи
	group by p.id, complexity, p.name, lg.name
	order by users_cnt desc
),
--
--
--
/* Все взаимодействия с задачей */
problem_starts as (
	select user_id, problem_id 
	from coderun cr
	join my_users mu
	on mu.id = cr.user_id
	union all
	select user_id, problem_id
	from codesubmit cs
	join my_users mu
	on mu.id = cs.user_id
),
--
/* Кол-во активности и её ранг по задаче */
starts_count as (
	select problem_id, 
	complexity, 
	p.name, 
	lg.name as lang,
	count(problem_id) as starts_cnt,
	rank() over (order by count(problem_id) desc) as starts_rank
	from problem_starts ps
	right join problem p
	on p.id = ps.problem_id
	join languagetoproblem l  
	on l.pr_id = p.id
	join language lg
	on lg.id = l.lang_id
	group by problem_id, complexity, p.name, lg.name
),
problems_rank as (
	select sc.problem_id, 
	sc.name,
	sc.complexity,
	sc.lang, 
	rank_in_users, starts_rank
	from starts_count  sc
	join problems_info p
	on sc.problem_id = p.problem_id
	where sc.lang = 'Python'
	order by rank_in_users, starts_rank
	limit 20
),
--
--
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
/* Статистика, какие задачи человек пытался решить и получилось ли у него это сделать,
 * а также сколько задач он пытался решить, сколько решил всего и процент успеха*/
user_problems_info as (
	select *,
	count(problem_id) over w as cnt_problems,
	count(case when done is true then 1 end) over w as cnt_right,
	round(count(case when done is true then 1 end) over w *100.0/count(problem_id) over w) as "right (%)"
	from user_problems
	window w as (partition by user_id)
),
users_info as (
	select distinct user_id, cnt_right, cnt_problems, "right (%)" from user_problems_info
),
avg_cnt_solved_problems as (
	select round(avg(cnt_right)) as cnt_right, 
	round(avg(cnt_problems)) as cnt_problems,
	round(avg("right (%)"),2) as avg_right
	from users_info
),
--
/* Среднее и медиана процента успешно решенных задач */
avg_solved_problems_per_user as (
	select user_id, max(cnt_right)*100.0/max(cnt_problems) as perc_right
	from user_problems_info 
	group by user_id
),
--
avg_solved_problems as (
	select round(avg(perc_right), 2) as avg_solved, 
	percentile_cont(0.5) within group (order by perc_right) as median_solved
	from avg_solved_problems_per_user
),
--
--
/* А если взять те задачи, которые студент только начинал решать  
 (запускал тест своего кода, но не отправлял его на проверку) */
users_coderun_problems as (
	select distinct ps.user_id, ps.problem_id,
	coalesce((
		select bool_or(done) from user_problems up 
		where ps.user_id =up.user_id and up.problem_id = ps.problem_id
	), false) as done
	from problem_starts ps
),
users_perc_right_per_coderun_problems as (
	select user_id, count(case when done is true then 1 end)*100.0/count(*) as perc_solved
	from users_coderun_problems
	group by user_id
),
avg_solved_coderun_problems as (
	select round(avg(perc_solved), 2) as avg_solved,
	percentile_cont(0.5) within group (order by perc_solved)  as median_solved
	from users_perc_right_per_coderun_problems
),
--
--
--
/* Посчитаю, сколько всего задач было решено*/ 
solved_problems_cnt as (
	select count(*) as cnt
	from user_problems
	where done is true
),
--
/* В разрезе сложности */
solved_problems_by_complexity_cnt as (
	select complexity, count(*) as cnt
	from user_problems up
	join problem p
	on p.id = up.problem_id
	where done is true
	group by complexity
),
solved_problems_cnt_by_lang as (
	select l.name, count(*) as cnt
	from user_problems up
	join languagetoproblem lp
	on up.problem_id = lp.pr_id
	join language l
	on l.id = lp.lang_id
	where done is true
	group by l.name
),
--
--
--
--
/* Поищем кол-во попыток на решение задачи */
rank_codesubmit as (
	select user_id, 
	problem_id, 
	created_at,
	is_false,
	row_number() over (partition by user_id, problem_id order by created_at) as row_num
	from codesubmit c 
	join my_users mu
	on c.user_id = mu.id
	order by user_id, created_at 
),
--
/* Номер самой первой успешной попытки */
min_user_attempts as (
	select user_id, problem_id,
	min(row_num) as right_attempt
	from rank_codesubmit
	where is_false = 0
	group by user_id, problem_id
),
--
/* Среднее кол-во попыток на задачу */
avg_attempts_for_problem as (
	select problem_id, round(avg(right_attempt), 2) as avg_attempt
	from min_user_attempts
	group by problem_id
),
--
/* Добавим problems_info */
problems_attempts_info as (
	select atp.*, pi.perc_right, users_cnt,
	pi.name, pi.complexity, pi.lang
	from avg_attempts_for_problem atp
	JOIN problems_info pi
	ON pi.problem_id = atp.problem_id
),
--
/* Сколько в среднем попыток на задачу определенной сложности,
 если задача была выполнена */
attempts_at_complexity as (
	select complexity, round(avg(avg_attempt), 2) as avg_attempt
	from problems_attempts_info
	group by complexity
),
--
/* Сколько в среднем попыток на задачу по языку, если задача была выполнена */
attempts_at_language as (
	select lang, round(avg(avg_attempt), 2) as avg_attempt
	from problems_attempts_info
	group by lang
),
--
--
/* Есть ли задачи, которые вообще не трогали */
not_trying_problems as (
	select *  
	from problem
	where id not in (select problem_id from problem_starts) and is_visible is True
),
--
--
--
--
/*  Процент успешных попыток пользователя по задаче */
user_attempts_to_problem as (
	select user_id, problem_id,
	count(case when is_false = 0 then 1 end) as right_attempt_cnt,
	count(*) as attempt_cnt,
	round(count(case when is_false = 0 then 1 end)*100.0/count(*), 2) as "right (%)"
	from codesubmit c
	join my_users mu
	on c.user_id = mu.id
	group by user_id, problem_id
),
--
/*  Процент успешных попыток пользователя в общем */
user_avg_right_attempt as (
	select user_id, 
	round(avg("right (%)"), 2) as "right (%)"
	from user_attempts_to_problem
	group by user_id
),
--
--
--
--
/* Тесты */
--
/* Количество тестов, которые решали студенты*/
users_test as (
	select mu.id as user_id, count(distinct test_id) as test_cnt
	from teststart ts
	right join my_users mu
	on ts.user_id = mu.id
	group by mu.id
	order by test_cnt desc
),
/* Сколько раз пользователи приступали к какому-либо тесту */
teststart_count as (
	select test_id, t.name, count(*) as start_cnt
	from teststart ts
	join my_users mu
	on mu.id = ts.user_id
	join test t
	on t.id = ts.test_id
	group by test_id, t.name
	order by start_cnt desc
),
--
testing_users as (
	select round(count(case when test_cnt > 0 then 1 end)*100.0/count(*), 2) as perc_testing_users,
	round(avg(test_cnt), 2) as avg_test_cnt
	from users_test
),
users_test_info as (
	select * 
	from users_test ut
	cross join testing_users teu
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
	on te.id = t3.test_id
	where coalesce(answer_id, t.id) = t.id -- оставляет ответы, которые совпадают с одним из вариантов ответа, и null-ы
	group by user_id, t.question_id, t2.value, t2.test_id, answer_id, t3.created_at, te.name -- сделано для того, чтобы убрать множественный null
	order by user_id, test_id, rank_order, question_id
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
	select test_id, t.name, count(*) as running_cnt,
	max(all_quest) as all_quest,
	round(avg(right_answer), 2) as avg_right_answer,
	round(avg("right (%)"), 2) as "avg_right (%)"
	from users_tests_info uti
	join test t
	on t.id = uti.test_id
	group by test_id, t.name
),
--
--
not_starting_test as (
	select * from test
	where id not in (
		select distinct test_id 
		from teststart t
		join my_users mu
		on mu.id = t.user_id
	)
),
--
--
--
/* Кол-во проверок решений по задачам и ответам в тестах */
all_checks as (
	select user_id
	from codesubmit c
	join my_users mu
	on mu.id = c.user_id
	union all
	select user_id
	from testresult t
	join my_users mu
	on mu.id = t.user_id
),
all_user_checks as( 
	select user_id, count(user_id) as cnt_check
	from all_checks
	group by user_id
),
checks_info as (
	select sum(cnt_check) as cnt_check,
	round(avg(cnt_check)) as avg_check_for_user,
	percentile_disc(0.5) within group (order by cnt_check) as median_check
	from all_user_checks
),
--
--
--
--
--
/* Заходы */
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
	coalesce(sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value end), 0) as write_off,
	coalesce(sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then value end),0) as accruals,
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
percentile_balance as (
	select perc, percentile_cont(perc) within group (order by balance) as balance
	from users_transactions, generate_series(0.1, 1, 0.1) as perc
	group by perc
),
--
--
/*Общий объем транзакций CodeCoins по типам. */
transaction_type_sum as (
	select type_id, description,
	sum(t.value) as summ,
	count(t.value) as cnt_actions
	from transaction t
	join transactiontype ty 
	on ty.type = t.type_id
	join my_users mu
	on mu.id = t.user_id
	where t.value <= 500
	group by type_id, description
	order by type_id
),
all_transactions_info as (
	select sum(summ) as all_transactions_value,
	sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then cnt_actions end) as write_off_cnt,
	sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then summ end) as write_off_value,
	sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then cnt_actions end) as accurals_cnt,
	sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then summ end) as accurals_value
	from transaction_type_sum
)
