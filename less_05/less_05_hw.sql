/*
Курс: SQL
Урок: 5
*/

USE shop;

-- Операторы, фильтрация, сортировка и ограничение

/*
1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
*/

UPDATE users
SET 
	created_at = NOW(), 
	updated_at = NOW();

/*
2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и 
в них долгое время помещались значения в формате 20.10.2017 8:10.
Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
*/

ALTER TABLE users
MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
MODIFY COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP; -- Возможно следовало использовать STR_TO_DATE(), но и это работает, но не уверен что будет работать во всех ситуациях.

/*
3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры:
	0, если товар закончился и выше нуля, если на складе имеются запасы.
Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value.
Однако нулевые запасы должны выводиться в конце, после всех записей.
*/

SELECT id, value
FROM storehouses_products
ORDER BY 
	value = 0,
       	value;

/*
4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
Месяцы заданы в виде списка английских названий (may, august)
*/

SELECT 
	id,
       	name,
       	DATE_FORMAT(birthday_at, '%Y %M %d') as 'birthday'
FROM users
WHERE MONTHNAME(birthday_at) IN ('may', 'august'); 

/*
5. Из таблицы catalogs извлекаются записи при помощи запроса. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
*/

SELECT id, name
FROM catalogs
WHERE id IN (5, 1, 2)
ORDER BY FIELD(id, 5, 1, 2);

-- Агрегация данных

/*
1. Подсчитайте средний возраст пользователей в таблице users.
*/

SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS mean_age
FROM users;

/*
2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
Следует учесть, что необходимы дни недели текущего года, а не года рождения.
*/

SELECT 
	DAYOFWEEK(DATE(CONCAT(YEAR(NOW()), DATE_FORMAT(birthday_at, '-%m-%d')))) AS day_of_week,
	COUNT(*)
FROM users
GROUP BY day_of_week;

/*
3. Подсчитайте произведение чисел в столбце таблицы.
*/

SELECT ROUND(EXP(SUM(LN(num)))) as products
FROM 
	(VALUES
		ROW(1),
		ROW(2),
		ROW(3),
		ROW(4),
		ROW(5)
	) AS t(num);

