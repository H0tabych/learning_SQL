/*
 Курс: SQL
 Урок: 11
 Тема: Оптимизация запросов
 */

USE shop;

/*
1. Создайте таблицу logs типа Archive. 
   Пусть при каждом создании записи в таблицах users, 
   catalogs и products в таблицу logs помещается время и дата создания записи, 
   название таблицы, идентификатор первичного ключа и содержимое поля name.
*/

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	table_name VARCHAR(255),
	external_id BIGINT UNSIGNED,
	name VARCHAR(255),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = archive;

DELIMITER //
DROP TRIGGER IF EXISTS log_insert_to_users//
CREATE TRIGGER log_insert_to_users
AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs(table_name, external_id, name)
	VALUES('users', NEW.id, NEW.name);
END//

DROP TRIGGER IF EXISTS log_insert_to_catalogs//
CREATE TRIGGER log_insert_to_catalogs
AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs(table_name, external_id, name)
	VALUES('catalogs', NEW.id, NEW.name);
END//

DROP TRIGGER IF EXISTS log_insert_to_products//
CREATE TRIGGER log_insert_to_products
AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs(table_name, external_id, name)
	VALUES('products', NEW.id, NEW.name);
END//

DELIMITER ;

INSERT INTO users(name, birthday_at)
VALUES
	('Sam', '1981-12-03'),
	('Max', '2009-03-30');

INSERT INTO products(name)
VALUES
	('ASUS ROG 1234'),
	('MSI 9876');

INSERT INTO catalogs(name)
VALUES
	('Блок питвния'),
	('Система охлаждения');

/*
2. Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/

-- Вариант 1
INSERT INTO users(name, birthday_at)
SELECT
	fst.name,
	fst.birthday_at
FROM
	users AS fst,
	users AS snd,
	users AS thd,
	users AS fth,
	users AS fif,
	users AS sth
LIMIT 1000000;

-- Вариант 2 работает долго
DELIMITER //
DROP PROCEDURE IF EXISTS insert_to_users//
CREATE PROCEDURE insert_to_users(i INT UNSIGNED)
BEGIN
	DECLARE min_date TIMESTAMP DEFAULT TIMESTAMP('1977-01-01');
	DECLARE max_date TIMESTAMP DEFAULT TIMESTAMP('2020-01-01');	
	START TRANSACTION;
		WHILE i > 0 DO
			INSERT INTO users(name, birthday_at)
			VALUES (CONCAT('name_', i), TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, min_date, max_date)), min_date));
			SET i = i - 1;
		END WHILE;
	COMMIT;
END//
DELIMITER ;

CALL insert_to_users(1000000);
