/*
SQL урок №3 ДЗ.

Заданные в ДЗ доплнительные таблицы в конце скрипта 
*/

DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(100) COMMENT 'name',
	lastname VARCHAR(100) COMMENT 'surname',
	email VARCHAR(120) UNIQUE,
	password_hash VARCHAR(100),
	phone BIGINT UNSIGNED,
	is_deleted BIT DEFAULT b'0',
	INDEX users_lastname_firstname_idx(lastname, firstname)
);

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id SERIAL PRIMARY KEY,
	gender CHAR(1),
	birthday DATE,
	photo_id BIGINT UNSIGNED,
	created_at DATETIME DEFAULT NOW(),
	hometown VARCHAR(100)
);

ALTER TABLE profiles ADD CONSTRAINT fk_user_id
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),

	FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initiator_user_id BIGINT UNSIGNED NOT NULL,
	target_user_id BIGINT UNSIGNED NOT NULL,
	status ENUM('requested', 'approved', 'declined', 'unfriended'),
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE NOW(),

	PRIMARY KEY (initiator_user_id, target_user_id),
	FOREIGN KEY (initiator_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (target_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities (
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED,

	INDEX communities_name_idx(name),
	FOREIGN KEY (admin_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL 
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities (
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (user_id,  community_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (community_id) REFERENCES communities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	media_type_id BIGINT UNSIGNED,
	user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	filename VARCHAR(255),
	size INT,
	metadata JSON,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),

	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS photo_albums;
CREATE TABLE photo_albums (
	id SERIAL,
	name varchar(255) DEFAULT NULL,
	user_id BIGINT UNSIGNED DEFAULT NULL,

	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
	PRIMARY KEY (id)
);

DROP TABLE IF EXISTS photos;
CREATE TABLE photos (
	id SERIAL PRIMARY KEY,
	album_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE profiles ADD CONSTRAINT fk_photo_id
	FOREIGN KEY (photo_id) REFERENCES photos(id)
	ON UPDATE CASCADE ON DELETE SET NULL;
    
/* 
Практическое задание по теме “Введение в проектирование БД”
Написать cкрипт, добавляющий в БД vk, которую создали на 3 вебинаре, 
3-4 новые таблицы (с перечнем полей, указанием индексов и внешних ключей).
(по желанию: организовать все связи 1-1, 1-М, М-М)
*/

/*
Попытался дополнить сервисом услуг такси, может не в тему, но говорят в вк такое было)
Пока делал посмотрел ваш ролик по проектированию в MSSQL, во многом попытался воссоздать ту структуру командами.
Вероятно где-то переборщил с каскадными обновлениями.
*/

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
) COMMENT = 'Каталог справочников';

DROP TABLE IF EXISTS catalog_data;
CREATE TABLE catalog_data (
	id SERIAL PRIMARY KEY,
	value VARCHAR(255) NOT NULL,
	sequence BIGINT UNSIGNED NOT NULL, -- Не понял как правильно сделать порядковый номер
	catalog_id BIGINT UNSIGNED NOT NULL,
	catalog_data_id BIGINT UNSIGNED,

	FOREIGN KEY (catalog_id) REFERENCES catalogs(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (catalog_data_id) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = 'Данные справочников и их зависимости друг от друга';

DROP TABLE IF EXISTS driver;
CREATE TABLE driver (
	user_id SERIAL PRIMARY KEY,
	num_driver_license INT UNSIGNED NOT NULL UNIQUE,
	is_active BIT DEFAULT b'0',
	photo_driver_license_id BIGINT UNSIGNED NOT NULL UNIQUE,

	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (photo_driver_license_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Пользователи предоставляющие услугу такси';

DROP TABLE IF EXISTS car;
CREATE TABLE car (
	id SERIAL PRIMARY KEY,
	brand_id BIGINT UNSIGNED,
	model_id BIGINT UNSIGNED,
	color_id BIGINT UNSIGNED,
	registration_number VARCHAR(100) NOT NULL,
	num_registration_certificate INT NOT NULL,
	photo_registration_certificate_id BIGINT UNSIGNED NOT NULL,
	number_insurance INT NOT NULL,
	photo_insurance_id BIGINT UNSIGNED NOT NULL,

	FOREIGN KEY (brand_id) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (model_id) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (color_id) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (photo_registration_certificate_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (photo_insurance_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Автомобили пользователей предоставляющих услугу такси';

DROP TABLE IF EXISTS car_driver;
CREATE TABLE car_driver (
	driver_id BIGINT UNSIGNED NOT NULL,
	car_id BIGINT UNSIGNED NOT NULL,

	PRIMARY KEY (driver_id, car_id),
	FOREIGN KEY (driver_id) REFERENCES driver(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (car_id) REFERENCES car(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Водители автомобилей';

DROP TABLE IF EXISTS taxi_ordering;
CREATE TABLE taxi_ordering (
	id SERIAL PRIMARY KEY,
	client_id BIGINT UNSIGNED NOT NULL,
	executor_id BIGINT UNSIGNED NOT NULL,
	status_id BIGINT UNSIGNED NOT NULL,
	route_start VARCHAR(255) NOT NULL,
	route_end VARCHAR(255) NOT NULL,
	price FLOAT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE NOW(),

	FOREIGN KEY (client_id) REFERENCES users(id) ON UPDATE CASCADE,
	FOREIGN KEY (executor_id) REFERENCES car_driver(driver_id) ON UPDATE CASCADE,
	FOREIGN KEY (status_id) REFERENCES catalog_data(id) ON UPDATE CASCADE
	
) COMMENT = 'Таблица заказов такси';
