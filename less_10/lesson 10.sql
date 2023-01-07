
/* 
- Хранимые процедуры
- Пользовательские функции
- Транзакции
- Представления 
- Триггеры
*/

-- обновим данные в базе, чтобы появились пользователи из одного города
UPDATE profiles
SET hometown = 'Adriannaport'
WHERE birthday < '1990-01-01';
 
-- вызываем процедуру
CALL sp_user_add('New', 'User', 'new_user1@mail.com', 9110001122, 'Moscow', 1, @tran_result); 

-- смотрим результат
SELECT @tran_result;

-- вызов функции
SELECT truncate(friendship_direction(1), 2) AS `user popularity`;

-- Транзакция по удалению пользователя
START TRANSACTION;
	SELECT @last_user_id := 111;
	
	DELETE FROM users
	WHERE id = @last_user_id;

	DELETE FROM profiles 
	WHERE user_id = @last_user_id;
	
COMMIT;	

-- Проблемный момент
SET foreign_key_checks = 0;
	DELETE FROM users
	WHERE id = 10;
SET foreign_key_checks = 1;	

SELECT * FROM users;

-- Посмотреть значение переменной forieng_key_checks 
SELECT @@GLOBAL.foreign_key_checks, @@SESSION.foreign_key_checks;


-- Каскадное удаление
DELETE FROM users
	WHERE id = 104;

SELECT * FROM users u
LEFT JOIN profiles p ON u.id=p.user_id 
ORDER BY u.id DESC;

-- Получение списка друзей (Представление)
-- создание
CREATE OR REPLACE VIEW v_friends
as
SELECT * 
FROM users u 
	JOIN friend_requests fr ON u.id = fr.target_user_id 
WHERE 
fr.status = 'approved'
UNION
SELECT * 
FROM users u 
	JOIN friend_requests fr ON u.id = fr.initiator_user_id  
WHERE 
fr.status = 'approved';

-- исполнение
SELECT * from v_friends;

SELECT id, email from v_friends
WHERE id<10;

-- удаление 
DROP VIEW v_friends;

--проверка работы триггеров
SELECT * FROM users u
INNER JOIN profiles p ON u.id=p.user_id;


INSERT INTO users (firstname, lastname, email, phone) 
			VALUES('New_T', 'User_T', 'new_userT@mail',  9110001122);
INSERT INTO profiles (user_id, gender, birthday, photo_id, hometown) 
VALUES(last_insert_id(), 'm', '2030.01.01', 1, 'Moscow');


UPDATE profiles 
SET birthday = '2020.01.01'
WHERE user_id =1;

SELECT * FROM users u
INNER JOIN profiles p ON u.id=p.user_id 
WHERE u.id=1;



