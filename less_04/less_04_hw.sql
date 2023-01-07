/*
Курс: SQL
Урок: 4
Тема: Практическое задание по теме “CRUD - операции”
*/

-- 1. Заполнить все таблицы БД vk данными (по 10-100 записей в каждой таблице).
/*
Заполнил все таблицы как было показано на уроке, всё получилось. Сюда скрипт решил не прикреплять, очень большая там "простыня".
Если необходимо - добавлю.
*/

-- 2. Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке.
USE vk;

SELECT DISTINCT firstname
FROM
	users 
ORDER BY 
	firstname;

-- 3. Первые пять пользователей пометить как удаленные.

UPDATE users
SET
	is_deleted = 1
LIMIT 5;

-- 4. Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней).

DELETE 
FROM messages
WHERE
	created_at > NOW();

-- 5. Написать название темы курсового проекта.
/*
Предлагаю 2 варианта:
1. БД европейских национальных футбольных турниров.
Структура таблиц примерно следующая: страны, турниры(чемпионвты, кубки), расписание игр, статистики сыгранных матчей(счёт, аладение удары, угловые, ...).
Из этого всего расчитываются турнирная таблица и прочие статистики.
2. БД строительных проектов, для расчёта бюджета.
Структура таблиц: ведомости материалов, работ, спец. техники. Работы привязываются к материалам.
Из этого считается бюджет доходов и расходов, а так же календарный план график производства работ.
*/
