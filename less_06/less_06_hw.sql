/*
 Курс: SQL
 Урок: 6
 Тема: Операторы, фильтрация, сортировка и ограничение. Агрегация данных
 */

USE vk;

/*
 1. Пусть задан некоторый пользователь. 
    Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
 */

SET @`user` = 1; -- Задаём id пользователя

SELECT 
	id,
	firstname,
	lastname,
	messages_from,
	messages_to,
	messages_from + messages_to AS messages_all
FROM (
	-- Новая таблица для того, что бы подсчитать общее кол-во сообщений в обе стороны
	SELECT 
		id,
		firstname,
		lastname,
		IFNULL((SELECT COUNT(from_user_id) FROM messages WHERE from_user_id = users.id AND to_user_id = @`user` GROUP BY from_user_id),
			0) AS messages_from,
		IFNULL((SELECT COUNT(to_user_id) FROM messages WHERE to_user_id = users.id AND from_user_id = @`user` GROUP BY to_user_id),
			0) AS messages_to
	FROM users
	WHERE 
		id IN (SELECT initiator_user_id FROM friend_requests WHERE target_user_id = @`user` AND status = 'approved'  
			  UNION 
			  SELECT target_user_id FROM friend_requests WHERE initiator_user_id = @`user` AND status = 'approved')
) AS new_table
ORDER BY messages_all DESC
LIMIT 1;

/*
2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.
*/

SELECT 
	COUNT(id) AS summ_likes_under_11_yo
FROM likes
WHERE
	(SELECT user_id FROM media WHERE id = likes.media_id) IN 
		(SELECT user_id FROM profiles WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11);

/*
 3. Определить кто больше поставил лайков (всего): мужчины или женщины. 
 */

SELECT 
	(SELECT gender FROM profiles WHERE user_id = likes.user_id) AS gender,
	COUNT(user_id) AS summ_likes
FROM likes
GROUP BY gender
ORDER BY summ_likes DESC
LIMIT 1;
