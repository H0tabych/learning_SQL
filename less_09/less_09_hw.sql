/*
 Курс: SQL
 Урок: 9
 */

USE shop;

/*
Тема: Транзакции, переменные, представления
*/

/*
1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
   Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
*/

CREATE DATABASE IF NOT EXISTS sample;

DROP TABLE IF EXISTS sample.users;
CREATE TABLE sample.users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	birthday_at DATE,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

START TRANSACTION;
	INSERT INTO sample.users(name, birthday_at) 
	SELECT name, birthday_at FROM shop.users WHERE id = 1;
COMMIT;

/*
2. Создайте представление, которое выводит название name товарной позиции из таблицы products
   и соответствующее название каталога name из таблицы catalogs.
*/

CREATE OR REPLACE VIEW view_products(id, product, catlog) AS
	SELECT
		p.id,
       		p.name,
       		c.name
	FROM products AS p
	LEFT JOIN catalogs AS c
		ON p.catalog_id = c.id;

/*
3. Пусть имеется таблица с календарным полем created_at.
   В ней размещены разреженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17.
   Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1,
   если дата присутствует в исходном таблице и 0, если она отсутствует.
*/

-- Создадим временную таблицу 
DROP TABLE IF EXISTS date_created;
CREATE TEMPORARY TABLE date_created (
	id SERIAL PRIMARY KEY,
	created_at DATE
);

--  Добавим разреженные данные
INSERT INTO date_created(created_at)
VALUES
	('2018-08-01'),
	(NULL),
	('2018-08-04'),
	('2018-08-16'),
	(NULL),
	('2018-08-17'),
	(NULL)
;

-- Вариант 1. Через процедуры.
-- Не очень нравится потому что создаётся процедура на разок.
DELIMITER //
DROP PROCEDURE IF EXISTS dates_in_august;
CREATE PROCEDURE dates_in_august()
BEGIN
	-- Временная таблица для всех дней месяца
	DECLARE d INT DEFAULT 1;
	DROP TABLE IF EXISTS august;
	CREATE TEMPORARY TABLE august (
		id SERIAL PRIMARY KEY,
		dates DATE
	);
	-- Наполнение таблицы данными. Через транзакцию, потому что вставка по одному.
	START TRANSACTION;
		WHILE d < 32 DO
			INSERT INTO august(dates)
			VALUES (DATE(CONCAT('2018-08-', d)));
			SET d = d + 1;
		END WHILE;
	COMMIT;
	-- Запрос
	SELECT 
		a.id,
	       	a.dates,
	       	IF(d_c.created_at IS NOT NULL, 1, 0) AS date_in_created_at
	FROM august AS a
	LEFT JOIN date_created AS d_c
		ON a.dates = d_c.created_at;	-- Использую ON потому что LEFT JOIN
END//
DELIMITER ;

CALL dates_in_august();
DROP PROCEDURE IF EXISTS dates_in_august;

-- Вариант 2. По старинке, но с "диким" костылём.
SET @d = 0;

SELECT 
	d_a.`date`,
	IF(d_c.created_at IS NOT NULL, 1, 0) AS date_in_created_at
FROM
	(
		SELECT DATE(CONCAT('2018-08-', @d := @d+1)) AS `date`
		FROM vk.users							-- Берём любую таблицу с заведомо большим количеством записей, чем количество дней в августе. Не очень нравится это решение т.к. привязвыаюсь к какой-то таблице, которая может измениться. Хочется как-то на лету в запросах создавать такие временные таблицы.
		WHERE @d < DATEDIFF('2018-09-01', '2018-08-01') 
	) AS d_a
LEFT JOIN date_created AS d_c
ON d_a.`date` = d_c.created_at
;

/*
4. Пусть имеется любая таблица с календарным полем created_at.
   Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
*/

-- Таблица с полем created_at
DROP TABLE IF EXISTS some_table;
CREATE TEMPORARY TABLE some_table (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP DEFAULT NOW()
);

-- Наполняем таблицу случайными датами
DELIMITER //
	DROP PROCEDURE IF EXISTS insert_rand_date//
	CREATE PROCEDURE insert_rand_date ()
		BEGIN
			DECLARE min_date TIMESTAMP DEFAULT TIMESTAMP('2003-01-01');
			DECLARE max_date TIMESTAMP DEFAULT TIMESTAMP('2033-01-01');
			DECLARE i INT DEFAULT 30;
			START TRANSACTION;
				WHILE i > 0 DO
					INSERT INTO some_table(created_at)
					VALUES (TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, min_date, max_date)), min_date));
					SET i = i - 1;
				END WHILE;
			COMMIT;
		END
	//
DELIMITER ;

CALL insert_rand_date();

-- Удаляем устаревшие записи
SET @m = (SELECT min(created_at) FROM (SELECT created_at FROM some_table ORDER BY created_at DESC LIMIT 5) AS t);
DELETE FROM some_table
WHERE created_at < @m;

/*
Тема: Хранимые процедуры и функции, триггеры
*/

/*
 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие,
    в зависимости от текущего времени суток.
    С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро",
    с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
    с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */

DELIMITER //
DROP FUNCTION IF EXISTS salute//
CREATE FUNCTION salute()
	RETURNS VARCHAR(50) DETERMINISTIC
	BEGIN
		IF HOUR(NOW()) < 12 AND HOUR(NOW()) >= 6 THEN
			RETURN 'Доброе утро';
		ELSEIF HOUR(NOW()) < 18 AND HOUR(NOW()) >= 12 THEN
			RETURN 'Добрый день';
		ELSEIF HOUR(NOW()) < 24 AND HOUR(NOW()) >= 18 THEN
			RETURN 'Доброй ночи';
		ELSE
			RETURN 'Иди спать!';
		END IF;
	END//
DELIMITER ;

SELECT salute();

/*
2. В таблице products есть два текстовых поля:
   name с названием товара и description с его описанием.
   Допустимо присутствие обоих полей или одно из них.
   Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
   Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
   При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/

DELIMITER //
DROP TRIGGER not_all_null//
CREATE TRIGGER not_all_null
BEFORE INSERT ON products
	FOR EACH ROW
	BEGIN
		IF COALESCE(NEW.name, NEW.description) IS NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Отмена операции. Отсутсвуют данные наименования и описания.';
		END IF;
	END//
DELIMITER ;

/*
3. Напишите хранимую функцию для вычисления произвольного числа Фибоначчи.
   Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел.
   Вызов функции FIBONACCI(10) должен возвращать число 55.
*/

DELIMITER //
DROP FUNCTION IF EXISTS fibonacci//
CREATE FUNCTION fibonacci(n INT UNSIGNED)
	RETURNS BIGINT UNSIGNED DETERMINISTIC
	BEGIN
		DECLARE `k-1` BIGINT UNSIGNED DEFAULT 0;
		DECLARE `k` BIGINT UNSIGNED DEFAULT 1;
		DECLARE `k+1` BIGINT UNSIGNED DEFAULT 1;
		DECLARE i INT DEFAULT 2;
		IF n = 0 THEN
			RETURN 0;
		ELSEIF n = 1 THEN
			RETURN 1;
		ELSE
			WHILE i <= n DO
				SET `k+1` = `k-1` + `k`;
				SET `k-1` = `k`;
				SET `k` = `k+1`;
				SET i = i + 1;
			END WHILE;
			RETURN `k+1`;
		END IF;
	END//
DELIMITER ;

SELECT fibonacci(10);

/*
Тема: Администрирование MySQL
*/

/*
1. Создайте двух пользователей которые имеют доступ к базе данных shop.
   Первому пользователю shop_read должны быть доступны только запросы на чтение данных,
   второму пользователю shop — любые операции в пределах базы данных shop.
*/

-- GRANT SELECT ON shop.* TO 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass'; -- Не сработало
DROP USER IF EXISTS 'shop'@'localhost';
CREATE USER 'shop'@'localhost' IDENTIFIED WITH sha256_password BY '123';
GRANT ALL ON shop.* TO 'shop'@'localhost';

DROP USER IF EXISTS 'shop_read'@'localhost';
CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY '321';
GRANT USAGE, SELECT ON shop.* TO 'shop_read'@'localhost';

/*
2. Пусть имеется таблица accounts содержащая три столбца:
   id, name, password, содержащие первичный ключ, имя пользователя и его пароль.
   Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
   Создайте пользователя user_read, который бы не имел доступа к таблице accounts,
   однако, мог бы извлекать записи из представления username.
*/

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	`password` VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO accounts(name, `password`)
VALUE
	('first', MD5('pass1')),
	('second', MD5('pass2'));

CREATE OR REPLACE VIEW username
AS (
	SELECT id, name
	FROM accounts
);

DROP USER IF EXISTS 'user_read'@'localhost';
CREATE USER 'user_read'@'localhost' IDENTIFIED WITH sha256_password BY '111';
GRANT USAGE, SELECT ON shop.username TO 'user_read'@'localhost';
