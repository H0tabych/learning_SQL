/*
 Курс: SQL
 Урок: 7
 Тема: Сложные запросы
 */

USE shop;

/*
1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
*/

-- Решение через EXISTS
SELECT 
	id,
       	name
FROM users
WHERE EXISTS(SELECT id FROM orders WHERE user_id = users.id);

-- Решение через JOIN
SELECT
	u.id,
	u.name,
	COUNT(o.id) AS cnt
FROM users AS u
	JOIN orders AS o
	ON u.id = o.user_id
GROUP BY u.id
ORDER BY cnt DESC;

/*
2. Выведите список товаров products и разделов catalogs, который соответствует товару.
*/

SELECT 
	p.id,
	p.name,
	p.price,
	c.name
FROM products AS p
	LEFT JOIN catalogs AS c
	ON p.catalog_id = c.id;

/*
3. Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
   Поля from, to и label содержат английские названия городов, поле name — русское.
   Выведите список рейсов flights с русскими названиями городов.
*/

-- Создадим нужную базу с необходимыми таблицами
DROP DATABASE IF EXISTS air;
CREATE DATABASE air;

USE air;

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	id SERIAL PRIMARY KEY,
	label VARCHAR(255) NOT NULL,
	name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	from_city_id BIGINT UNSIGNED,  -- В задании конечно сказано что в этих полях хранятся названия, но пусть будут ключи этих названий.
	to_city_id BIGINT UNSIGNED,    -- С точки зрения запроса большой разницы не будет, но так сильно правильнее я думаю.

	FOREIGN KEY(from_city_id) REFERENCES cities(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY(to_city_id) REFERENCES cities(id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Заполним созданные таблицы данными
INSERT INTO cities(label, name)
VALUES
	('Moscow', 'Москва'),
	('New York', 'Нью Йорк'),
	('London', 'Лондон'),
	('Rome', 'Рим'),
	('Istanbul', 'Стамбул'),
	('Paris', 'Париж');

INSERT INTO flights(from_city_id, to_city_id)
VALUES
	(1, 3),
	(3, 5),
	(2, 1),
	(6, 4),
	(5, 2),
	(2, 1),
	(4, 6);

-- Сам запрос
SELECT 
	f.id,
	c_from.name AS `from`,
	c_to.name AS `to`
FROM flights AS f
	LEFT JOIN cities AS c_from
	ON f.from_city_id = c_from.id
	LEFT JOIN cities AS c_to
	ON f.to_city_id = c_to.id;

