# Постановка задачи

IT Resume - платформа с задачами и тестами по программированию  
Монетизация платформы строится на внутренней валюте codecoins. Её начисляют за успехи пользователя, либо её приобретают. Тратится она на открытие новых задач и тестов.
На платформе обучаются обычные пользователи, также она работает с корпоративными клиентами.
Как обычно взаимодействуют корпоративные клиенты с ITResume: им предоставляется система автоматической проверки задач. То есть, у них уже есть некоторый свой курс, и они хотели бы автоматизировать проверку задач в нем.

Часто корпоративные клиенты обращаются к платформе и просят выгрузить им то одну, то другую аналитику по своим студентам. Какие задачи решают, сколько попыток, сколько времени, какой прогресс и так далее. С разбивкой по указанным периодам.

Задача - поставить себя на место преподавателя корпоративного клиента, который очень переживает за процесс обучения своих студентов. Ему очень важно знать, какие сложности испытывают студенты, что у них получается, в каком месте нужно допилить обучающую программу и так далее. А еще поставьте себя на место финансового директора - возможно, ему будет интересно, а за что именно они нам платят деньги. А может быть еще что-то будет интересно посмотреть генеральному директору? А маркетологу? А методистам?
Затем подготовить разностороннее исследование, чтобы корпоративные клиенты платформы были довольны и все вопросы у них сразу отпали. В качестве подопытного берется клиент с id=1.
[link](что-хочет-знать-сотрудник)
Для каждого заинтересованного лица приведу интересные для него метрики и рассчитаю их

# Что хочет знать сотрудник?

## Преподаватель 
Преподаватель хочет знать успехи каждого пользователя, чтобы точечно помогать, и в каких местах обычно возникают сложности. Помимо этого он хочет знать общие показатели пользователей, чтобы планировать нагрузку:
* Активность пользователей по дням недели и часам дня - позволит оценить нагрузку на преподавателя, например в субботу может быть много пользователей, возможно тогда преподавателю имеет смысл работать в субботу, но взять выходной в другой день.
* Средняя длительность сессии в общем и по пользователю. Если у какого-то пользователя низкая длительность сессии относительно средней, то, возможно, ему нужна помощь. 
* Какие задачи самые популярные - можно предлагать эти задачи, чтобы заинтересовать студентов
* Процент успешных попыток по задаче  - позволяет оценить сложность задачи 
* Сколько у студента ушло попыток на решение задачи - тоже может помочь оценить на сложность задачи.
* К каким задачам приступал студент и какие он решил - покажет успех студента по задачам
* Процент успешных попыток пользователя по задаче и в общем - можно оценить уровень пользователя 
* На каких задачах возникают трудности - можно узнать, с какими задачами возникают проблемы, и объяснить их подробнее
* Какое количество пользователей решает задачи разной сложности и разных языков - общий уровень студентов
* Сколько раз приступали к каждому тесту
* Сколько раз отдельный студент начинал тест
* Какие тесты решал каждый пользователь, сколько у него было правильных ответов
* Какие ответы давал пользователь в тесте 
* Статистика прохождений тестов

## Финансовый директор
В базе нет данных о затратах на доступ к платформе, поэтому буду считать, что для финансового директора важны количественные показатели платформы, т.е. сколько бонусов получает компания от взаимодействия с IT Resume.
Поэтому для него важно знать:
* Сколько всего проверок решений и сколько на пользователя - это можно назвать целевой метрикой для фин.директора, ведь чем больше проверок, тем более явно виден плюс автоматической проверки IT Resume, т.к. иначе каждую задачу приходилось бы проверять преподавателю  
#### Другие интересующие показатели:
* Количество задач и тестов - если их слишком мало, то и налаживать какую-то автоматическую проверку не обязательно
* Количество пришедших пользователей по месяцам - поможет оценить эффективность маркетинга.
* MAU (month active users) и WAU - может быть корпопативные пользователи почти не заходят на платформу, а если и заходят, то ничего не делают
* Удержание (retention) и отток (churn rate)к - может корпоративные студенты резко "отпадают" спустя какой-то срок (Т.к. платформа образовательная, не обязательно, чтобы пользователи заходили каждый день, поэтому буду считать rolling retention и rolling chorn rate, чтобы оценить общую вовлеченность пользователей)
Отдельно можно посмотреть на распределение codecoins, если компания напрямую закупает их для своих студентов, чтобы они эффективнее взаимодействовали с платформой. Если это так, то фин.директору также интересно:
* Общее распределение codecoins по списаниям и пополнениям
* Распределение баланса пользователей

## Генеральный директор
Его интересуют количественные показатели платформы по пользователям и контенту:
* Количество пользователей, пришедших в разные месяца
* Количество активных пользователей (по месяцам, MAU, WAU, DAU)
* Общее количество входов на платформу
* Средняя длительность сессии
* Количество заходов без активности
* Удержание и отток (Т.к. платформа образовательная, не обязательно, чтобы пользователи заходили каждый день, поэтому буду считать rolling retention и rolling chorn rate, чтобы оценить общую вовлеченность пользователей)
* Lifetime пользователя
* Сколько всего задач и тестов
* Топ 20 популярных задач
* Сколько задач было решено всего или с разбивкой по сложности или по языкам


## Маркетолог
Маркетолог хочет знать информацию, с помощью которой он может прорекламировать продукт компании другим пользователям
* Сколько всего задач с разбивкой по языкам и сложности - можно завлечь большим количеством задач
* Сколько домашних задач
* Сколько тестов
* Топ 20 популярных задач - даст возможность прорекламировать задачи, интересные пользователям
* Количество пользователей на платформе - можно показать масштаб


## Методист
Методиста, в отличии от преподавателя, интересуют усредненные успехи пользователей, чтобы он мог планировать дальнейший план обучения.
* Популярные задачи (можно смотреть на кол-во попыток решений и на количество юзеров, которые решали эту задачу)
* Количество и процент успешно решенных/нерешенных в итоге задач
* Сколько в среднем попыток на задачу определенной сложности или ЯП, если задача была выполнена
* Сколько в среднем попыток уходит на конкретную задачу, выделить с самым большим количеством
* У каких задач низкий процент решений
* Есть ли задачи, которые вообще не трогали  
* Сколько задач в среднем решает пользователь
* Какое количество пользователей решает задачи разной сложности, процент от общего кол-ва
* Какие тесты и сколько решали
* Какие тесты не решали или решали очень мало
* Средний процент правильных ответов в тесте

Подключение к базе данных (например в DBeaver):
```  
Хост: 95.163.241.236
Порт: 5432
База данных: simulative
Юзер: student
Пароль: qweasd963
```

Описание данных, которые хранят таблицы:
https://docs.google.com/document/d/1qKDKq_d8Mhud5p3mADxWWxlIrPx-EfHzvuE0j02dKtA/edit?usp=sharing

  


# Содержательная часть с описанием запросов
Просто посмотреть код SQL запросов можно в файле code в этой же папке.  
По порядку буду делать запросы по каждому интересующему вопросу и расписывать свои действия:  
Для начала я сделаю несколько CTE, к которым буду обращаться в дальнейшем. В dbeaver мои запросы записаны друг за другом, поэтому начало CTE with будет записан только в первом.  
Т.к. для примера я буду работать с компанией с id = 1, для начала я выберу только пользователей из этой компании:
``` 
with my_users as (
	select * 
	from users
	where company_id = 1
), 
```
Результат запроса:  
![таблица](images/My_users.png)  

Также возьму активность пользователей по дням - если пользователь в какой-то день делал выгрузку запроса, проверку задания или начинал тест, то будет показана дата дня и id пользователя. Для этого через union буду извлекать id пользователя и дату действия. Т.к. union убирает дубли, каждая пара id и даты будет уникальна. При этом делаю join каждой таблицы с my_users, чтобы взять только интересующих меня пользователей
```
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
```
Результат запроса:  
![таблица](images/days_users_activity.png) 

И найду вообще всю активность пользователей с временем активности. Алгоритм похож на предыдущий, только теперь использую union all и оставляю формат даты-времени.
```
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
``` 
Результат:  
![таблица](images/all_users_activity.png) 

# Преподаватель

### Активность пользователей по дням недели:
Для начала я хочу получить просто дату, день недели, количество действий, которое выполнялось в конкретный день, и количество пользователей, которые что-то делали на платформе в этот день. При этом я не хочу потерять те дни, в которых активности и пользователей вообще не было - иначе это повлияет на средние значения.
Поэтому я генерирую интервал дней, чтобы затем присоединить его join-ом и не потерять дни без активности.
Использую функцию generate_series, беря интервал от самой первой до самой последней активности вообще, и из полученного интервала с помощью функции date извлекаю дату.
```
gen_days as (
	select date(generate_series(
	(select min(activ_date) from days_users_activity), 
	(select max(activ_date) from days_users_activity),
	'1 day'::interval)) as day_date
),
```
Этот запрос я буду использовать и в дальнейшем.  
Далее могу получить активность каждого дня. Для этого right join-ом присоединяю к таблице all_users_activity сгенерированный интервал. Группирую по дате и дню недели, и извлекаю дату, день недели, количество действий пользователей с помощью агрегатной функции count и кол-во самих пользователей, использую внутри count distinct, чтобы убрать повторы.
```
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
```
Результат запроса:  
![таблица](images/dayweek_activ.png)  

Теперь можно посчитать общее количество действий через sum, а также усреднить полученные значения путем группировки по дням недели и узнать среднее количество активности функцией avg. Также возьму медиану кол-ва действий, так как она менее чувствительна к выбросам и её тоже полезно смотреть.
```
avg_dayweek_activ as (
	select day_week, sum(action_cnt) as action_cnt, 
	round(avg(action_cnt), 2) as avg_actions, 
	round(avg(users_cnt), 2) as avg_users,
	percentile_disc(0.5) within group (order by action_cnt) as median_actions
	from dayweek_activ
	group by day_week
	order by avg_actions desc
),
```
Результат:  
![таблица](images/avg_dayweek_activ.png)  

#### Выводы:
Наибольшая активность наблюдается в среду, а самые неактивные дни в пятницу и субботу. При этом, хоть средняя активность в пятницу выше, чем в субботу, её медиана у пятницы рекордно низкая. Скорее всего было много дней, где в этот была около нулевая активность, при этом также были дни, где в пятницу активность была высока, иначе и средняя была бы низкой.
Общие выводы, что к концу недели и началу выходных большинство людей уходит отдыхать и не столь активно занимается на платформе. В воскресень, вторник и среду наибольшая активность, поэтому в эти дни у преподавателя скорее всего будет наибольшая нагрузка.

### Активность пользователей по часам дня
Как и для прошлого запроса, сгенерирую интервал дат по часам от самой первой до самой последней активности, чтобы не потерять часы без активности. Обрезаю формат даты-времени до часа с помощью функции date_trunc
```
gen_hours as (
	select date_trunc('hour', generate_series(
	(select min(activ_date) from all_users_activity),
	(select max(activ_date) from all_users_activity),
	'1 hour'::interval)) as hour
),
```
После этого получу активность каждого часа в каждом дне. Действия почти аналогичны предыдущему пункту про дни недели
```
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
)
```
Результат запроса:  
![таблица](images/hour_activ.png)

Далее группирую по часам, считаю сумму и средне действий и среднее пользователей. Медиана здесь не показательна, т.к. слишком много нулей.
```
avg_hour_activ as (
	select hour, sum(actions_cnt) as actions_cnt, sum(users_cnt) as users_cnt,
	round(avg(actions_cnt), 2) as avg_actions,
	round(avg(users_cnt),2) as avg_users
	from hour_activ
	group by hour
	order by avg_actions desc
)
```
Результат запроса:  
![таблица](images/avg_hour_activ.png)

#### Выводы  
Самые активные периоды - 10.00-15.00 и 17.00-20.00. С большим отрывом лидирует время с 19.00 до 20.00. Самые неактивные часы, как и ожидалось, ночные - с 22.00 до 6.00. С этой информацией преподавателю будет легче планировать свою нагрузку.  

### Средняя длительность сессии
Сессией буду считать цепочку действий пользователя на платформе, между которыми проходит не более 60 минут. Если прошло больше - будем считать это новой сессией. Длину сессии буду считать в минутах. Пользоваться буду созданнной ранее таблицей all_users_activity. 
Для начала с помощью оконной функции lead найду время следующей активности пользователя и разницу между текущей и следующей активностью с помощью extract(epoch). Введу "флаг" new_session, равный 0 если разница между активностью меньше 60 и 1 в ином случае. 
```
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
```

Далее сделаю "маркеры" сессий, просуммировав флаги функцией sum(), используя её как оконную. Окно беру с начала до текущей строки. Это даст номер для каждой сессии пользователя. При этом, чтобы не портить разницу между активностью внутри сессии, обнуляю "переходную" активность - там, где разница между парой больше 60 минут, т.е. начинается новая сессия.  
```
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
```
Результат запроса:  
![таблица](images/session_markers.png)  

После считаю длительность каждой сессии, суммируя все разницы между активностями внутри одной сессии через sum, группируя по user_id и session_id.
```
session_duration as (
	select user_id, session_id, sum(new_diff) as duration
	from session_markers
	group by user_id, session_id
	order by user_id, session_id
)
```  
Теперь можно получить среднюю длительность сессии в общем через avg. Также можно взять медиану через percentile_disc.
```
avg_session_duration as (
	select round(avg(duration)) as avg_minute,
	round(percentile_disc(0.5) within group (order by duration)) as median_minute
	from session_duration
)
``` 
Результат запроса:  
![таблица](images/avg_session_duration.png)  

А теперь посчитаем количество сессий и их среднюю длительность для каждого пользователя с помощью группировки. Для удобства возьмем из предыдущей CTE среднюю длительность с помощью подзапроса.  
```
user_session_info as (
	select user_id, 
	count(session_id) as session_cnt,
	round(avg(duration)) as avg_minute,
	(select avg_minute from avg_session_duration) as avg_session_dur
	from session_duration
	group by user_id
)
```  
Результат запроса:  
![таблица](images/user_session_info.png)  

Помимо этого, можно посмотреть распределение длительностей сессий по перцентилям с шагом 0.1. Для этого использую generate_series(0.1, 1, 0.1), названный как perc, и команду percentile_cont.
```
duration_percentile as (
	select perc, percentile_cont(perc) within group (order by avg_minute) as duration 
	from user_session_info, pg_catalog.generate_series(0.1, 1, 0.1) perc
	group by perc
),
```  
Результат запроса:  
![таблица](images/duration_percentile.png)  

#### Итоги
Теперь преподаватель может видеть заинтересованность каждого пользователя, смотря на его среднюю длительность сессии или на каждую сессию в отдельности. Также он может посмотреть, в какой "когорте" находится пользователь по длительности. Если с низкой длительносью - возможно у пользователя возникают какие-то трудности с использованием платформы или с самими заданиями и преподаватель может помочь это исправить.  

### Самые популярные задачи  
Популярность буду оценивать по двум критериям - количество пользователей, которые пытались решить эту задачу (таблица codesubmit) и сколько раз вообще пользователь взаимодействовал с задачей (запуск кода и проверка решения, таблицы coderun и codesubmit).
Для первого критерия объединю таблицы codesubmit и my_users обычным join-ом, таблицу problem right join-ом, чтобы не потерять те задачи, которые вообще не решали, и таблицы languagetoproblem и language. Извлеку из полученной таблицы problem_id, complexity (сложность), название задания, язык програмирования для задачи, количество пользователей, которые пытались решить эту задачу, процент верных попыток, который буду искать через case и ранг задачи по кол-ву пользователей. Отсортирую по количеству пользователей.
```
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
)
```  
Результат запроса:  
![таблица](images/problems_info.png)  

Второй критерий - количество взаимодействий пользователя с задачей. Этот показатель тоже покажет, какие задачи популярные - может быть их не выставляли на проверку, т.к. не получалось, но при этом много работали с ней, потому что она интересная и т.д.
В запросе для начала объединяю таблицы codesubmit и coderun через union all, записываю это в CTE problem_starts.  
Далее к этой таблице присоединяю right join-ом problem, а затем languagetoproblem и language. Извлекаю problem_id, сложность, название задачи, язык программирования, кол-во "активаций" задачи и ранг по активациям. Ранг получаю для того, чтобы потом объединить starts_count и problems_info и сравнить полученные результаты - задачи с наибольшим кол-вом пользователей также и самые "трогаемые", или нет.
```
problem_starts as (
	select problem_id 
	from coderun cr
	join my_users mu
	on mu.id = cr.user_id
	union all
	select problem_id
	from codesubmit cs
	join my_users mu
	on mu.id = cs.user_id
),
starts_count as (
	select problem_id, 
	complexity, 
	p.name, 
	lg.name,
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
)
```  
Результат запроса:  
![таблица](images/starts_count.png)   

Теперь можно объединить эти запросы и поискать самые популярные задачи по этим критериям. Я считаю, что кол-во пользователей, которые пытались решить задачу, важнее, поэтому сортирую по ней. Но с помощью второго критерия можно более правильно отранжировать задачи, например, если по кол-ву пользователей задачи мало отличаются, но у второй значительно больше активаций, то поставим её выше.
```
problems_rank as (
	select sc.problem_id, 
	sc.name,
	sc.complexity,
	sc.lang, 
	rank_in_users, starts_rank
	from starts_count  sc
	join problems_info p
	on sc.problem_id = p.problem_id
	order by rank_in_users, starts_rank
	limit 20
)
```  
Результат запроса:  
![таблица](images/problems_rank.png)  

Дополнительно можно фильтровать по сложности, языку или домашнему/не домашнему.  

#### Выводы
Cамые популярные задачи - по SQL первой сложности, в основном это дз. Если убрать дз - то ранг по пользователям сильно падает, и в таком случае самые популярные - тестовое задание в альфа-банк с SQL и некоторые задачи на python. Если смотреть в разрезе языка, то python менее популярен, самые популярные у него это также дз.  

### Процент успешных попыток по задаче
Процент успешных попыток по задаче по всем решениям я уже получал в CTE problems_info.  
![таблица](images/problems_info.png)  

### Сколько у студента ушло попыток на решение задачи
Т.е. какая по очередности попытка была первой правильной.  
Для начала я объединю таблицу codesubmit с my_users. Возьму id пользователя, задачи, параметр is_false и через оконную функцию номер строки, сортируя по дате (т.е. по очередности).
```
rank_codesubmit as (
	select user_id, 
	problem_id, 
	is_false,
	row_number() over (partition by user_id, problem_id order by created_at) as row_num
	from codesubmit c 
	join my_users mu
	on c.user_id = mu.id
	order by user_id, created_at 
),
```  
Далее из полученной таблицы возьму только те строки, где is_false = 0 (т.е успешные попытки), сгруппирую по id пользователя и задачи и возьму минимальный номер строки, тем самым получив номер первой успешной попытки.
```
min_user_attempts as (
	select user_id, problem_id,
	min(row_num) as right_attempt
	from rank_codesubmit
	where is_false = 0
	group by user_id, problem_id
),
```  
Результат запроса:  
![таблица](images/min_user_attempts.png)   
#### Итог
Преподаватель сможет посмотреть, насколько легко или тяжело у студента получилась та или иная задача.

### К каким задачам приступал студент и какие он решил  
Объединим таблицу codesubmit и my_users. Сгруппирую по user_id, username, problem_id. Извеку id пользователя, его ник, id проблемы, и булево значение done, равное True, если задача хоть один раз была решена правильно.
```
user_problems as (
	select user_id, username, problem_id,
	case when min(is_false) = 0 then true else false end as done
	from codesubmit c 
	join my_users mu
	on c.user_id = mu.id
	group by user_id, username, problem_id
	order by user_id, problem_id
),
```  
Результат запроса:  
![таблица](images/user_problems.png)  

Дополнительно к этому запросу можно посчитать сколько всего задач он пытался решить и сколько в итоге решил.
Для этого использую функцию count как оконную, считая кол-во задач, кол-во решенных задач через case и нахожу процент от общего числа.
```
user_problems_info as (
	select *,
	count(problem_id) over w as cnt_problems,
	count(case when done is true then 1 end) over w as cnt_right,
	round(count(case when done is true then 1 end) over w *100.0/count(problem_id) over w) as "right (%)"
	from user_problems
	window w as (partition by user_id)
),
```
Результат запроса:  
![таблица](images/user_problems_info.png)  

#### Итог  
Теперь преподаватель сможет оценить успехи каждого студента в разрезе каждой задачи и в общем.  

### Процент успешных попыток пользователя по задаче и в общем  
Для нахождения процента успешных попыток для каждой задачи опять присоединяю к codesubmit таблицу my_users. Группирую по id пользователя и проблемы, извлекаю user_id, problem_id, кол-во верных попыток, кол-во всех попыток и отношение первого ко второму в процентах. Это позволит посмотреть, как хорошо пользователь решает задачи.
```
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
```  
Результат запроса:  
![таблица](images/user_attempts_to_problem.png)  

Теперь можно усреднить эти значения, сгруппировав по пользователю
```
user_avg_right_attempt as (
	select user_id, 
	round(avg("right (%)"), 2) as "right (%)"
	from user_attempts_to_problem
	group by user_id
),
```
Результат запроса:  
![таблица](images/user_avg_right_attempt.png)  

#### Итог
Теперь преподаватель может на успешность пользователя, и помогать, если видно, что возникают трудности. Например, топ 5 студентов с самым низким процентом успеха это 43, 1178, 589, 1217, 2643.

### На каких задачах возникают трудности
Посмотрим, на какие задачи уходит больше всего попыток и у каких задач низкий уровень правильных ответов  
Для изучения среднего кол-ва попыток для решения задачи обращусь к ранее созданной таблице min_user_attempts, сгруппирую по задаче и получу среднее через avg, округляя до целого.
```
avg_attempts_for_problem as (
	select problem_id, round(avg(right_attempt), 2) as avg_attempt
	from min_user_attempts
	group by problem_id
),
```   
Результат запроса:  
![таблица](images/avg_attempts_for_problem.png)  

Далее к этой таблице можно присоединить problems_info:  
```
problems_attempts_info as (
	select atp.*, pi.perc_right,
	pi.users_cnt, pi.name, 
	pi.complexity, pi.lang
	from avg_attempts_for_problem atp
	JOIN problems_info pi
	ON pi.problem_id = atp.problem_id
	),
```  
Убирая те задачи, на которых было меньше 3-х человек (чтобы иметь хоть какую-то статистику) и сортируя по кол-ву попыток для решения, получим:
![таблица](images/problems_attempts_info_sorted_by_attempts.png)  
Сортируя по проценту правильных решений:
![таблица](images/problems_attempts_info_sorted_by_perc_right.png)  
#### Вывод
Топ 8 задач в каждой сортировке занимают задачи на python. Возможно, методистам стоит изменить блок объяснения питона, а преподавателю быть готовым к большей работе с учениками по этому блоку.  

### Какое количество пользователей решает задачи разной сложности и разных языков
Для среза по сложности использую таблицы codesubmit, my_users и problem. Группирую по сложности и извлекаю сложность, процент успешных попыток через count(case...), кол-во всех попыток, кол-во решаемых задач этой сложности, и кол-во уникальных пользователей, которые решали задачи этой сложности  
```
perc_right_with_compl as (
	select complexity, 
	round(count(case when is_false = 0 then 1 end)*100.0/count(*), 2) as perc_right,
	count(*) as submit_cnt,
	count(distinct problem_id) as problem_cnt,
	count(distinct mu.id) as user_cnt
	from codesubmit c
	join my_users mu
	on c.user_id = mu.id
	join problem p
	on p.id = c.problem_id
	group by complexity
)
```  
Результат запроса:  
![таблица](images/avg_attempts_for_problem.png)  

Для среза по языкам алгоритм похожий, но дополнительно я присоединяю таблицы languagetoproblem и language. Группирую по языку и извлекаю ЯП вместо сложности.
```
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
)
```  
Результат запроса:  
![таблица](images/avg_attempts_for_problem.png)  

#### Вывод
Задачи 1 и 2 сложности решают почти одинаково кол-во людей, при этом задачи 3 сложности значительно менее популярны, до них дошло всего 15 студентов. При этом процент верных решений по сложности не сильно отличается и находится примерно на уровне 50% процентов.
На срезе по языку можно увидеть, что задачи на SQL значительно более популярны - их решает более чем в два раза больше студентов. При этом задаче по SQL в среднем легче (или более понятны )- процент успешных решений больше на 12 в сравнении с показателями питона. 

### Сколько раз приступали к каждому тесту
Использую таблицы teststart и my_users. Группирую по test_id, извлекаю id теста и кол-во раз, когда его начинали. Сортирую по убыванию кол-ва, дабы посмотреть на самые популярные тесты.
```
teststart_count as (
	select test_id, t.name, count(*) as start_cnt
	from teststart ts
	join my_users mu
	on mu.id = ts.user_id
	join test t
	on t.id = ts.test_id
	group by test_id, t.name
	order by start_cnt desc
)
```  
Результат запроса:  
![таблица](images/teststart_count.png)  

#### Итог
Тесты 19, 5, 23, 1 и 18 - самые популярные. С большим отрывом лидирует тест 19 по Numpy часть 2, после него 2 теста по sql и тестовое на бизнес аналитика. 

### Сколько раз отдельный студент начинал тест
К таблице teststart присоединяю my_users через right_join, чтобы не потерять тех, кто вообще не приступал к тестам. Группирую по mu.id, считаю кол-во уникальных тестов, которые решал пользователь. Сортирую по убыванию test_cnt, чтобы видеть тех, кто хоть что-то решал.
```
users_test as (
	select mu.id as user_id, count(distinct test_id) as test_cnt
	from teststart ts
	right join my_users mu
	on ts.user_id = mu.id
	group by mu.id
	order by test_cnt desc
)
```  
Результат запроса:  
![таблица](images/users_test.png)  

#### Вывод
По результатам запроса видно, что всего лишь 14 пользователей решали хоть один тест. Пользователь 43 - самый активный.   
После таких скудных результов мне стало интересно, а какой процент пользователей от общего кол-ва вообще приступали к тестам, и сколько тогда приходится тестов на человека.
Для этого из users_test кол-во тестирующихся юзеров, полученное с помощью count(case...), делю на общее кол-во пользователей, так я получаю процент тех, кто решал тесты, и также через avg(test_cnt) получаю среднее кол-во тестов на человека.
```
testing_users as (
	select round(count(case when test_cnt > 0 then 1 end)*100.0/count(*), 2) as perc_testing_users,
	round(avg(test_cnt), 2) as avg_test_cnt
	from users_test
),
```  
Эту таблицу можно присоединить к предыдущей, чтобы было более наглядно  
```
users_test_info as (
	select * 
	from users_test ut
	cross join testing_users teu
)
```  
Результат запроса (грустные, если смотреть на процент тестируемых :( ):  
![таблица](images/users_test_info.png)  

#### Вывод
Если компания хочет, чтобы её студенты проходили тесты, то ей определенно нужно поработать либо с привлечением студентов на тесты, либо, возможно, с качеством самих тестов.  

### Какие ответы давал пользователь в тесте 
Здесь будет большой запрос.  
Беру таблицу testanswer, join-ом присоединяю к ней testquestion, right join-ом testresult, чтобы не потерять "пустые" ответы, к этому присоединяю my_users и test. Добавляю условие, что ответ пользователя должен совпадать с одним из возможнных ответов в вопросе, или же быть null-ом. Группирую по user_id, question_id, вопросу, test_id, answer_id, датой создания и именем теста. Делаю это, чтобы убрать множественный повторяющийся null. Извлекаю отсюда user_id, question_id, сам вопрос, id ответа, корректен ли он (делаю это через агрегатную функцию bool_and (т.к. использую группировку) и case), дату создания, ранг через оконную функцию, чтобы можно было отличить разные прохождения теста, id и имя теста. Полученную махину сортирую.
```
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
)
```  
Результат запроса:  
![таблица](images/users_answers.png)  
#### Итог
С этой таблицей можно просмотреть ответы каждого отдельного пользователя. Посмотреть его прогресс, если он решал тест снова.

### Какие тесты решал каждый пользователь, сколько у него было правильных ответов
Буду использовать полученную прошлым запросом таблицу users_answers.  Сгруппирую по user_id, test_id, rank_order и date(created_at). Извлеку эти же параметры, дополнив также кол-вом вопросов в тесте, кол-вом правильных ответом и процентом правильных ответов.
```
users_tests_info as (
	select user_id, test_id, date(created_at) as created_at, rank_order, count(*) as all_quest, 
	count(case when is_correct is true then 1 end) as right_answer,
	round(count(case when is_correct is true then 1 end)*100.0/count(*), 2) as  "right (%)"
	from users_answers
	group by user_id, test_id, rank_order, date(created_at)
)
```  
Результат запроса:  
![таблица](images/users_tests_info.png)  
#### Итог
Это более приятная глазу таблица, чем предыщущая. Она может помочь преподавателю увидеть успехи студентов по курсам, и помочь им, если в этом возникнет необходимость. Интересным фактом является, что пользователь с id 43 15 раз решал 18 тест. Возможно, его что-то в нем заинтересовало.  

### Статистика прохождений тестов
В дополнение к предыдущей таблице посмотреть на общую статистику прохождения каждого теста  
Для этого делаю join таблицы test, группирую по id и названию теста и извлекаю id, название, кол-во запусков, кол-во вопросов через max(), среднее кол-во и средний процент правильных ответов
```
testresult_research as (
	select test_id, t.name, count(*) as running_cnt,
	max(all_quest) as all_quest,
	round(avg(right_answer), 2) as avg_right_answer,
	round(avg("right (%)"), 2) as "avg_right (%)"
	from users_tests_info uti
	join test t
	on t.id = uti.test_id
	group by test_id, t.name
)
```  
Результат запроса:  
![таблица](images/testresult_research.png)  
#### Вывод
Всего лишь 10 из 24 тестов хотя бы раз запускали. При этом запусков все равно небольшое кол-во, за исключением 19 теста, но большинство из них выполнил пользователь с id 43. Стоит заметить, что полученные данные расходятся с таблицей teststart_count, т.е. почему-то информация о начале теста есть, а информации о завершении - нет. Возможно, произошел какой-то сбой на сервере. Но, хоть здесь и мало информации, даже по ней преподаватель может оценить сложность теста.  


 # Финансовый директор

### Сколько всего проверок решений и сколько на пользователя 
Для начала через union all таблиц codesbmit и testresult получу id пользователей, работы которых нужно проверить (задача или тест)  
```
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
)
```  
Далее сгруппирую по id и получу кол-во проверок по пользователю  
```
all_user_checks as( 
	select user_id, count(user_id) as cnt_check
	from all_checks
	group by user_id
)
```  
Результат запроса:  
![таблица](images/all_user_checks.png)  

И затем просуммирую всё количество проверок, получив общее кол-во, получу среднее кол-во проверок на пользователя и медиана проверок.
```
checks_info as (
	select sum(cnt_check) as cnt_check,
	round(avg(cnt_check)) as avg_check_for_user,
	percentile_disc(0.5) within group (order by cnt_check) as median_check
	from all_user_checks
)
```  
Результат запроса:  
![таблица](images/checks_info.png)  
#### Вывод
С этой информацией финансовый директор может просчитать, насколько выгодно сотрудничество с IT Resume. Например, если для проверок нужен бы был специально нанятый для этого человек, которому платили бы за каждрую проверку, можно было бы посчитать выгоду от автоматизации проверки.  

### Количество задач и тестов
```
problems_and_tests_cnt as (
	select 'problems' as type, count(id) as cnt
	from problem
	union 
	select 'tests', count(id)
	from test
)
```  
Результат запроса:  
![таблица](images/problems_and_tests_cnt.png)   

### Количество пришедших пользователей по месяцам
Возьму таблицу my_users, извлеку с помощью to_char месяц регистрации, сгруппирую по нему и посчитаю кол-во пришедших уникальных пользователей.  
```
users_joined_on_month as (
	select to_char(date_joined, 'YYYY-MM') as month, count(distinct id) as cnt_joined
	from my_users
	group by month
)
```  
Результат запроса:  
![таблица](images/users_joined_on_month.png)   

### MAU и WAU
Для начала найду кол-во активных пользователей (т.е. тех, кто делал хоть что-то кроме захода) по месяцам.
```
MAU as (
	select to_char(activ_date, 'YYYY-MM') as month, count(distinct user_id) as mau
	from days_users_activity ua
	group by month
	order by month
)
```  
Результат запроса:  
![таблица](images/mau.png)   

Далее объединяю две последние полученные таблицы через full join по совпадению месяцев, убираю те, где месячная активность пользователей была меньше 4. Извлекаю месяц, месячную активность, количество пришедших в этом месяце, суммарное кол-во пришедших пользователей за этот и прошлые месяца, отношение кол-ва активных в этом месяце пользователей к общему числу пришедних, и среднее кол-во активности за все месяцы. 
```
mau_research as (
	select m.month as month, mau, coalesce (cnt_joined, 0) as cnt_joined, 
	sum(cnt_joined) over (order by coalesce(m.month, u.month)) as all_users,
	coalesce(round(mau*100.0/sum(cnt_joined) over (order by coalesce(m.month, u.month)), 2),0) as "activ_users (%)",
	round(avg(mau)  over ()) as avg_mau
	from MAU m
	full join users_joined_on_month u
	on m.month = u.month
	where mau > 3 -- убрали месяца со слишком малыми значениями
	order by month
)
```  
Результат запроса:  
![таблица](images/mau_research.png)   
#### Вывод
Наибольшая активность была 2022-04. Можно увидеть, что далеко не все пришедшие пользователи остаются на платформе на длительный срок. Возможно они получают то, за чем пришли, и уходят довольными, либо же наоборот, их что-то не устраивает на платформе, поэтому они перестают заходить.  

Проделаю то же самое и для недель:
```
users_joined_on_week as (
	select to_char(date_joined, 'YYYY-WW') as week, count(distinct id) as cnt_joined
	from my_users
	group by week
)
```  
Дополнительно генерирую интервал недель, чтобы использовать join-ом и не потерять недели без активности
```
gen_weeks as (
	select to_char(generate_series(
	(select min(activ_date) from days_users_activity), 
	(select max(activ_date) from days_users_activity),
	'1 day'::interval), 'YYYY-WW') as week
	group by week
)
```
Результат запроса:  
![таблица](images/gen_weeks.png)   
Можно видеть, что первая активная неделя была 2021-38.

Найду кол-во активных пользователей по неделям   
```
wau as (
	select week, count(distinct user_id) as wau
	from days_users_activity ua
	full join gen_weeks g
	on to_char(activ_date, 'YYYY-WW') = g.week 
	group by  week
	order by week
)
```
Ищу процент активных пользователей, среднее WAU
```
wau_research as (
	select coalesce(w.week, uw.week) as week, coalesce(wau,0) as wau,
	coalesce (cnt_joined, 0) as cnt_joined,
	sum(cnt_joined) over (order by coalesce(w.week, uw.week)) as all_users,
	coalesce(round(wau*100.0/sum(cnt_joined) over (order by coalesce(w.week, uw.week)), 2),0) as "activ_users (%)",
	round(avg(wau)  over ()) as avg_wau
	from wau w
	full join users_joined_on_week uw
	on w.week = uw.week
)
```
Результат запроса:  
![таблица](images/wau_research.png)  
#### Вывод
Усредненный wau составляет 9 человек. Это примерно 1/3 от mau - не самый хороший показатель, но не совсем ужасный. Без прихода новых пользователей недельная активность довольно быстро падает, это определенно плохой показатель - вряд ли пользователь получает необходимые ему знания всего за неделю. Стоит разобраться, почему пользователи уходят.
Возможно необходимо провести качественнное исследование, опросив студентов, почему они ушли или что их не устраивает  

### Удержание (retention) и отток (churn rate)
Буду считать не просто retention,а rolling retention, и обратный для него churn rate. Выбор использовать именно rolling retention обусловлен тем, что платформа IT Resume - образовательная, и для неё не сильно важно, чтобы пользователи заходили каждый день. Человек может отдыхать в выходные и заниматься обучением в будние дни, или наоборот, или как угодно иначе. Поэтому важно оценить не конкретные дни, а промежутки, например, какой процент людей заходил хотя бы раз после 6 дня захода на платформу.  
Считать буду по когортам - в какой месяц пользователь зарегистрировался, к такой когорте он и принадлежит.  
Для начала получу таблицу заходов пользователей. Для этого объединю таблицы userentry и my_users. Извлеку id пользователя, дату регистрации, дату захода, разницу между ними и когорту пользователя с помощью to_char.
```
entry_info as (
	select u.user_id, date(date_joined) as joined, date(entry_at) as entry,  
	extract(days from entry_at - date_joined) as diff,
	to_char(date_joined, 'YYYY-MM') as cohort
	from userentry u
	join my_users m
	on u.user_id = m.id
	order by user_id, diff
)
```  
Результат запроса:  
![таблица](images/entry_info.png)  

Далее через длинный запрос, в котором я считаю отношение кол-ва зашедших хотя бы раз в определенный день и все после него к кол-ву зашедших в 0-вой день (т.е. в день регистрации). Считаю это через distinct case user_id, у которых разница (diff) больше или равен указанному значению. Для отслеживания выберу 0, 1, 3, 7, 14, 21, 30, 45, 60, 90 и 120 дни - их достаточно, чтобы оценить заходы пользователь. Группирую по когортам, и дополнительно задаю условие, чтобы в когорте было больше 3 человек (иначе статистика будет совсем нерепрезентативна) 
```
rolling_retention as (
	select cohort, count(distinct user_id) as cohort_size,
	round(count(distinct case when diff >= 0 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "0 (%)",
	round(count(distinct case when diff >= 1 then user_id end)*100.0/
		count(distinct case when diff >= 0 then user_id end), 2) as "1 (%)",
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
)
```  
Результат запроса:  
![таблица](images/rolling_retention.png)  

#### Вывод



### Общее распределение codecoins по списаниям и пополнениям

### Распределение баланса пользователей

