/*
1. Установите СУБД MySQL. 
Создайте в домашней директории файл .my.cnf, 
задав в нем логин и пароль, который указывался при установке.
*/

/* mysql установил.
файл .my.cnf создал и разместил в домашней директории: /home/georgiy
вход без пароля работает.
*/

/*
2. Создайте базу данных example, разместите в ней таблицу users,
состоящую из двух столбцов, числового id и строкового name.
*/

CREATE DATABASE IF NOT EXISTS example;

USE example

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) COMMENT 'user name'
) COMMENT = 'first table in the course SQL';

/*
3. Создайте дамп базы данных example из предыдущего задания,
разверните содержимое дампа в новую базу данных sample.
*/

CREATE DATABASE IF NOT EXISTS sample;

/* команда командной строки для создания дампа:
mysqldump example > example.sql

команда для развёртывания дампа в новую базу данных:
mysql sample < example.sql

/*
4. Ознакомьтесь более подробно с документацией утилиты mysqldump.
Создайте дамп единственной таблицы help_keyword базы данных mysql.
Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.
*/

/* Команды командной строки:
mysqldump --where='true limit 100' mysql help_keyword > mysql_help_keyword.sql 
