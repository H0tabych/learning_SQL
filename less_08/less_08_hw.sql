/*
 Курс: SQL
 Урок: 8
 Тема: Сложные запросы
 */

USE vk;

/*
1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека,
   который больше всех общался с выбранным пользователем (написал ему сообщений).
*/

SET @`user` = 1; -- Задаём переменную с id пользователя

SELECT 
	u.id,
	u.firstname,
	u.lastname,
	m_from.cnt AS cnt_messages_from,
	m_to.cnt AS cnt_messages_to,
	IFNULL(m_from.cnt, 0) + IFNULL(m_to.cnt, 0) AS cnt_messages_all
FROM (
	SELECT 
		id, 
		firstname,
       		lastname
       	FROM users
		JOIN friend_requests AS fr
	       	ON (users.id = fr.initiator_user_id AND fr.target_user_id = @`user` OR users.id = fr.target_user_id AND fr.initiator_user_id = @`user`) 
			AND fr.status = 'approved'
	) AS u
	LEFT JOIN (
		SELECT from_user_id, COUNT(from_user_id) AS cnt
	       	FROM messages
	       	WHERE to_user_id = @`user`
	       	GROUP BY from_user_id
	) AS m_from
	ON u.id = m_from.from_user_id
	LEFT JOIN (
		SELECT to_user_id, COUNT(to_user_id) AS cnt
	       	FROM messages
	       	WHERE from_user_id = @`user`
	       	GROUP BY to_user_id
	 ) AS m_to
	ON u.id = m_to.to_user_id
ORDER BY cnt_messages_all DESC
LIMIT 1
;

/*
2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.
*/

SELECT 
        COUNT(l.id) AS summ_likes_under_11_yo
FROM likes AS l
	LEFT JOIN media AS m
	ON l.media_id = m.id
	JOIN profiles AS p
	ON m.user_id = p.user_id AND TIMESTAMPDIFF(YEAR, p.birthday, NOW()) < 11
;

/*
 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
 */

SELECT
	p.gender,
        COUNT(p.gender) AS summ_likes
FROM likes AS l
	LEFT JOIN profiles AS p
	ON l.user_id = p.user_id	
GROUP BY p.gender
ORDER BY summ_likes DESC
LIMIT 1;
