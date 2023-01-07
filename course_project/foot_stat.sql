/*
Курсовой проект.
*/

DROP DATABASE IF EXISTS foot_stat;
CREATE DATABASE foot_stat;

USE foot_stat;

DROP TABLE IF EXISTS catalog;
CREATE TABLE catalog (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE
) COMMENT = 'Каталог справочников';

DROP TABLE IF EXISTS catalog_data; 
CREATE TABLE catalog_data (
	id SERIAL PRIMARY KEY,
	value VARCHAR(100) NOT NULL,
	`sequence` BIGINT UNSIGNED COMMENT 'Порядковый номер элементов справочников',
	id_catalog BIGINT UNSIGNED NOT NULL,
	id_catalog_data BIGINT UNSIGNED,

	FOREIGN KEY (id_catalog) REFERENCES catalog(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (id_catalog_data) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = 'Данные справочников. Далее в наименовании полей, являющихся внешними ключами обозначается как "cd"';

DROP TABLE IF EXISTS tournament;
CREATE TABLE tournament (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	id_cd_country BIGINT UNSIGNED,
	id_cd_type_tournament BIGINT UNSIGNED,

	FOREIGN KEY (id_cd_country) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (id_cd_type_tournament) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS club;
CREATE TABLE club (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	id_cd_country BIGINT UNSIGNED,

	FOREIGN KEY (id_cd_country) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS calendar;
CREATE TABLE calendar (
	id SERIAL PRIMARY KEY,
	match_day DATE NOT NULL COMMENT 'Дата матча', -- Переделать в DATETIME, когда будут данные времени
	id_tournament BIGINT UNSIGNED COMMENT 'id турнира',
	id_home_club BIGINT UNSIGNED COMMENT 'id команды - хозяйки',
	id_away_club BIGINT UNSIGNED COMMENT 'id команды - гостя',
	id_cd_status BIGINT UNSIGNED COMMENT 'id статуса матча(не сыгран/перенесён/отменён/завершён)',

	FOREIGN KEY (id_tournament) REFERENCES tournament(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (id_home_club) REFERENCES club(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (id_away_club) REFERENCES club(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (id_cd_status) REFERENCES catalog_data(id) ON UPDATE CASCADE ON DELETE SET NULL

) COMMENT = 'Расписание матчей';

DROP TABLE IF EXISTS `result`;
CREATE TABLE result (
	id_calendar SERIAL PRIMARY KEY,
	goals_home TINYINT UNSIGNED NOT NULL,
	goals_away TINYINT UNSIGNED NOT NULL,
	goals_ht_home TINYINT UNSIGNED NOT NULL,
	goals_ht_away TINYINT UNSIGNED NOT NULL,
	scheme_home VARCHAR(50) NOT NULL,
	scheme_away VARCHAR(50) NOT NULL,
	possesion_home FLOAT(4, 3) UNSIGNED NOT NULL,
	possesion_away FLOAT(4, 3) UNSIGNED NOT NULL,
	shots_home TINYINT UNSIGNED NOT NULL,
	shots_away TINYINT UNSIGNED NOT NULL,
	shots_target_home TINYINT UNSIGNED NOT NULL,
	shots_target_away TINYINT UNSIGNED NOT NULL,
	corners_home TINYINT UNSIGNED NOT NULL,
	corners_away TINYINT UNSIGNED NOT NULL,
	fouls_home TINYINT UNSIGNED NOT NULL,
	fouls_away TINYINT UNSIGNED NOT NULL,
	yelow_cards_home TINYINT UNSIGNED NOT NULL,
	yelow_cards_away TINYINT UNSIGNED NOT NULL,
	red_cards_home TINYINT UNSIGNED NOT NULL,
	red_cards_away TINYINT UNSIGNED NOT NULL,

	FOREIGN KEY (id_calendar) REFERENCES calendar(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Результаты матчей';

DROP TABLE IF EXISTS club_statistics_before_match;
CREATE TABLE club_statistics_before_match (
	id_calendar SERIAL PRIMARY KEY,
--	Владение
	avg_poss_home FLOAT UNSIGNED COMMENT 'Среднее владение хозяев в домашних матчах',
	avg_poss_home_opp FLOAT UNSIGNED COMMENT 'Среднее владение всех противников хозяев в домашних матчах хозяев',
	avg_poss_away FLOAT UNSIGNED COMMENT 'Среднее владение гостей в гостевых матчах',
	avg_poss_away_opp FLOAT UNSIGNED COMMENT 'Среднее владение всех противников гостей в гостевых матчах гостей',
	avg_poss_tourn_home FLOAT UNSIGNED CHECK (avg_poss_tourn_home != 0) COMMENT 'Среднее владение домашних команд в турнире',
	avg_poss_tourn_away FLOAT UNSIGNED CHECK (avg_poss_tourn_away != 0) COMMENT 'Среднее владение гостевых команд в турнире',
	pwr_poss_home FLOAT UNSIGNED AS (avg_poss_home / avg_poss_tourn_home) COMMENT 'Показатель силы владения хозяев относительно среднего в турнире',
	pwr_poss_home_opp FLOAT UNSIGNED AS (avg_poss_home_opp / avg_poss_tourn_away) COMMENT 'Показатель силы противодействия владению гостей для хозяев',
	pwr_poss_away FLOAT UNSIGNED AS (avg_poss_away / avg_poss_tourn_away) COMMENT 'Показатель силы владения гостей относительно среднего в турнире',
	pwr_poss_away_opp FLOAT UNSIGNED AS (avg_poss_away_opp / avg_poss_tourn_home) COMMENT 'Показатель силы противодействия владению хозяев для гостей',
	pred_poss_home FLOAT UNSIGNED AS (pwr_poss_home * pwr_poss_away_opp * avg_poss_tourn_home) COMMENT 'Предсказанное значение владения хозяев',
	pred_poss_away FLOAT UNSIGNED AS (pwr_poss_away * pwr_poss_home_opp * avg_poss_tourn_away) COMMENT 'Предсказанное значение владения гостей',
--	Удары
	avg_shots_home FLOAT UNSIGNED COMMENT 'Средние удары хозяев в домашних матчах',
	avg_shots_home_opp FLOAT UNSIGNED COMMENT 'Средние удары всех противников хозяев в домашних матчах хозяев',
	avg_shots_away FLOAT UNSIGNED COMMENT 'Средние удары гостей в гостевых матчах',
	avg_shots_away_opp FLOAT UNSIGNED COMMENT 'Средние удары всех противников гостей в гостевых матчах',
	avg_shots_tourn_home FLOAT UNSIGNED CHECK (avg_shots_tourn_home != 0) COMMENT 'Средние удары домашних команд в турнире',
	avg_shots_tourn_away FLOAT UNSIGNED CHECK (avg_shots_tourn_away != 0) COMMENT 'Средние удары гостевых команд в турнире',
	pwr_shots_home FLOAT UNSIGNED AS (avg_shots_home / avg_shots_tourn_home) COMMENT 'Показатель силы ударов хозяев относительно среднего в турнире',
	pwr_shots_home_opp FLOAT UNSIGNED AS (avg_shots_home_opp / avg_shots_tourn_away) COMMENT 'Показатель силы противодействия ударам гостей для хозяев',
	pwr_shots_away FLOAT UNSIGNED AS (avg_shots_away / avg_shots_tourn_away) COMMENT 'Показатель силы ударов гостей относительно среднего в турнире',
	pwr_shots_away_opp FLOAT UNSIGNED AS (avg_shots_away_opp / avg_shots_tourn_home) COMMENT 'Показатель силы противодействия ударам хозяев для гостей',
	pred_shots_home FLOAT UNSIGNED AS (pwr_shots_home * pwr_shots_away_opp * avg_shots_tourn_home) COMMENT 'Предсказанное значение ударов хозяев',
	pred_shots_away FLOAT UNSIGNED AS (pwr_shots_away * pwr_shots_home_opp * avg_shots_tourn_away) COMMENT 'Предсказанное значение ударов гостей',
--	Угловые
	avg_corners_home FLOAT UNSIGNED COMMENT 'Средние угловые хозяев в домашних матчах',
	avg_corners_home_opp FLOAT UNSIGNED COMMENT 'Средние угловые всех противников хозяев в домашних матчах хозяев',
	avg_corners_away FLOAT UNSIGNED COMMENT 'Средние угловые вгостей в гостевых матчах',
	avg_corners_away_opp FLOAT UNSIGNED COMMENT 'Средние угловые всех противников гостей в гостевых матчах',
	avg_corners_tourn_home FLOAT UNSIGNED CHECK (avg_corners_tourn_home != 0) COMMENT 'Средние угловые домашних команд в турнире',
	avg_corners_tourn_away FLOAT UNSIGNED CHECK (avg_corners_tourn_away != 0) COMMENT 'Средние угловые гостевых команд в турнире',
	pwr_corners_home FLOAT UNSIGNED AS (avg_corners_home / avg_corners_tourn_home) COMMENT 'Показатель силы угловых хозяев относительно среднего в турнире',
	pwr_corners_home_opp FLOAT UNSIGNED AS (avg_corners_home_opp / avg_corners_tourn_away) COMMENT 'Показатель силы противодействия угловым гостей для хозяев',
	pwr_corners_away FLOAT UNSIGNED AS (avg_corners_away / avg_corners_tourn_away) COMMENT 'Показатель силы угловых гостей относительно среднего в турнире',
	pwr_corners_away_opp FLOAT UNSIGNED AS (avg_corners_away_opp / avg_corners_tourn_home) COMMENT 'Показатель силы противодействия угловым хозяев для гостей',
	pred_corners_home FLOAT UNSIGNED AS (pwr_corners_home * pwr_corners_away_opp * avg_corners_tourn_home) COMMENT 'Предсказанное значение угловых хозяев',
	pred_corners_away FLOAT UNSIGNED AS (pwr_corners_away * pwr_corners_home_opp * avg_corners_tourn_away) COMMENT 'Предсказанное значение угловых гостей',
--	Фолы
	avg_fouls_home FLOAT UNSIGNED COMMENT 'Средние фолы хозяев в домашних матчах',
	avg_fouls_home_opp FLOAT UNSIGNED COMMENT 'Средние фолы всех противников хозяев в домашних матчах хозяев',
	avg_fouls_away FLOAT UNSIGNED COMMENT 'Средние фолы вгостей в гостевых матчах',
	avg_fouls_away_opp FLOAT UNSIGNED COMMENT 'Средние фолы всех противников гостей в гостевых матчах',
	avg_fouls_tourn_home FLOAT UNSIGNED CHECK (avg_fouls_tourn_home != 0) COMMENT 'Средние фолы домашних команд в турнире',
	avg_fouls_tourn_away FLOAT UNSIGNED CHECK (avg_fouls_tourn_away != 0) COMMENT 'Средние фолы гостевых команд в турнире',
	pwr_fouls_home FLOAT UNSIGNED AS (avg_fouls_home / avg_fouls_tourn_home) COMMENT 'Показатель силы фолов хозяев относительно среднего в турнире',
	pwr_fouls_home_opp FLOAT UNSIGNED AS (avg_fouls_home_opp / avg_fouls_tourn_away) COMMENT 'Показатель силы противодействия фолам гостей для хозяев',
	pwr_fouls_away FLOAT UNSIGNED AS (avg_fouls_away / avg_fouls_tourn_away) COMMENT 'Показатель силы фолов гостей относительно среднего в турнире',
	pwr_fouls_away_opp FLOAT UNSIGNED AS (avg_fouls_away_opp / avg_fouls_tourn_home) COMMENT 'Показатель силы противодействия фолам хозяев для гостей',
	pred_fouls_home FLOAT UNSIGNED AS (pwr_fouls_home * pwr_fouls_away_opp * avg_fouls_tourn_home) COMMENT 'Предсказанное значение фолов хозяев',
	pred_fouls_away FLOAT UNSIGNED AS (pwr_fouls_away * pwr_fouls_home_opp * avg_fouls_tourn_away) COMMENT 'Предсказанное значение фолов гостей',
	

	FOREIGN KEY (id_calendar) REFERENCES calendar(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Статистики команд перед матчами';


/*------------------------------  TRIGGER  -----------------------------------------------------------*/

DELIMITER //
-- Заполнение порядковых номеров (sequence) в подсправочниках
DROP TRIGGER IF EXISTS sequence_catalog_data//
CREATE TRIGGER sequence_catalog_data
BEFORE INSERT ON catalog_data
FOR EACH ROW
BEGIN
	DECLARE n BIGINT;
	SELECT `sequence`
	INTO n
	FROM catalog_data 
	WHERE id_catalog = NEW.id_catalog
	ORDER BY `sequence` DESC
	LIMIT 1;
	IF (n IS NULL) THEN
		SET n = 0;
	END IF;
	SET NEW.`sequence` = n + 1;
END//

DROP TRIGGER IF EXISTS insert_club_statistics//
CREATE TRIGGER insert_club_statistics
AFTER INSERT ON calendar
FOR EACH ROW
BEGIN
	INSERT INTO club_statistics_before_match(id_calendar)
	VALUES(NEW.id);
END//

DROP TRIGGER IF EXISTS club_statistics//
CREATE TRIGGER club_statistics
AFTER INSERT ON result
FOR EACH ROW
BEGIN
	DECLARE id_home BIGINT UNSIGNED;
	DECLARE id_away BIGINT UNSIGNED;
	DECLARE md DATE DEFAULT (SELECT match_day FROM calendar WHERE id = NEW.id_calendar);
       	SELECT id_away_club INTO id_away FROM calendar WHERE id = NEW.id_calendar;
	SELECT id_home_club INTO id_home FROM calendar WHERE id = NEW.id_calendar;

	CALL calc_club_statistics(md, id_home, id_away);
END//

DELIMITER ;

/*------------------------------ FUNCTIONS AND PROCEDURES  -------------------------------------------*/

-- Процедура рассчёта статистик клубов и предсказаний результатов последующих матчей
DELIMITER //
DROP PROCEDURE IF EXISTS calc_club_statistics//
CREATE PROCEDURE calc_club_statistics(md DATE, id_home BIGINT UNSIGNED, id_away BIGINT UNSIGNED)
BEGIN
	WITH
       		home_stat AS (
			SELECT 
				AVG(r.possesion_home) AS avg_poss_home,
				AVG(r.possesion_away) AS avg_poss_home_opp,
				AVG(r.shots_home) AS avg_shots_home,
				AVG(r.shots_away) AS avg_shots_home_opp,
				AVG(r.corners_home) AS avg_corners_home,
				AVG(r.corners_away) AS avg_corners_home_opp,
				AVG(r.fouls_home) AS avg_fouls_home,
				AVG(r.fouls_away) AS avg_fouls_home_opp
			FROM calendar AS c
			INNER JOIN result AS r
				ON c.id = r.id_calendar
			WHERE c.id_home_club = id_home
			GROUP BY c.id_home_club
		)

	UPDATE club_statistics_before_match
		SET 
			avg_poss_home = (SELECT avg_poss_home FROM home_stat),
			avg_poss_home_opp = (SELECT avg_poss_home_opp FROM home_stat),
			avg_shots_home = (SELECT avg_shots_home FROM home_stat),
			avg_shots_home_opp = (SELECT avg_shots_home_opp FROM home_stat),
			avg_corners_home = (SELECT avg_corners_home FROM home_stat),
			avg_corners_home_opp = (SELECT avg_corners_home_opp FROM home_stat),
			avg_fouls_home = (SELECT avg_fouls_home FROM home_stat),
			avg_fouls_home_opp = (SELECT avg_fouls_home_opp FROM home_stat)
	WHERE id_calendar IN (
		SELECT id
		FROM calendar
		WHERE match_day > md AND id_home_club = id_home
	);

	WITH
		away_stat AS (
			SELECT
				AVG(r.possesion_away) AS avg_poss_away,
				AVG(r.possesion_home) AS avg_poss_away_opp,
				AVG(r.shots_away) AS avg_shots_away,
				AVG(r.shots_home) AS avg_shots_away_opp,
				AVG(r.corners_away) AS avg_corners_away,
				AVG(r.corners_home) AS avg_corners_away_opp,
				AVG(r.fouls_away) AS avg_fouls_away,
				AVG(r.fouls_home) AS avg_fouls_away_opp
			FROM calendar AS c
			INNER JOIN result AS r
				ON c.id = r.id_calendar
			WHERE id_away_club = id_away
			GROUP BY c.id_away_club
		)

        UPDATE club_statistics_before_match
                SET
                        avg_poss_away = (SELECT avg_poss_away FROM away_stat),
                        avg_poss_away_opp = (SELECT avg_poss_away_opp FROM away_stat),
			avg_shots_away = (SELECT avg_shots_away FROM away_stat),
			avg_shots_away_opp = (SELECT avg_shots_away_opp FROM away_stat),
			avg_corners_away = (SELECT avg_corners_away FROM away_stat),
			avg_corners_away_opp = (SELECT avg_corners_away_opp FROM away_stat),
			avg_fouls_away = (SELECT avg_fouls_away FROM away_stat),
			avg_fouls_away_opp = (SELECT avg_fouls_away_opp FROM away_stat)
        WHERE id_calendar IN (
                SELECT id
                FROM calendar
                WHERE match_day > md AND id_away_club = id_away
        );

	WITH
		tourn_stat AS (
			SELECT
				AVG(r.possesion_home) AS avg_poss_tourn_home,
				AVG(r.possesion_away) AS avg_poss_tourn_away,
				AVG(r.shots_home) AS avg_shots_tourn_home,
				AVG(r.shots_away) AS avg_shots_tourn_away,
				AVG(r.corners_home) AS avg_corners_tourn_home,
				AVG(r.corners_away) AS avg_corners_tourn_away,
				AVG(r.fouls_home) AS avg_fouls_tourn_home,
				AVG(r.fouls_away) AS avg_fouls_tourn_away
			FROM calendar AS c
			INNER JOIN result AS r
				ON c.id = r.id_calendar
		)
	UPDATE club_statistics_before_match
		SET
			avg_poss_tourn_home = (SELECT avg_poss_tourn_home FROM tourn_stat),
			avg_poss_tourn_away = (SELECT avg_poss_tourn_away FROM tourn_stat),
			avg_shots_tourn_home = (SELECT avg_shots_tourn_home FROM tourn_stat),
			avg_shots_tourn_away = (SELECT avg_shots_tourn_away FROM tourn_stat),
			avg_corners_tourn_home = (SELECT avg_corners_tourn_home FROM tourn_stat),
			avg_corners_tourn_away = (SELECT avg_corners_tourn_away FROM tourn_stat),
			avg_fouls_tourn_home = (SELECT avg_fouls_tourn_home FROM tourn_stat),
			avg_fouls_tourn_away = (SELECT avg_fouls_tourn_away FROM tourn_stat)
	WHERE id_calendar IN (
		SELECT id
		FROM calendar
		WHERE match_day > md
	);
END//

DELIMITER ;

/*------------------------------  VIEW   -------------------------------------------------------------*/

-- Представление турнирных таблиц турниров
CREATE OR REPLACE VIEW tourn_table AS (
	SELECT
		c.id,
		t.name AS tournament,
		c.name,
		-- обшая статистика игр
		(rh.home_played + ra.away_played) AS played,
		(rh.home_wins + ra.away_wins) AS wins,
		(rh.home_drow + ra.away_drow) AS drows,
		(rh.home_played - rh.home_wins - rh.home_drow + ra.away_played - ra.away_wins - ra.away_drow) AS loss,
		(rh.goals_for_home + ra.goals_for_away) AS goals_for,
		(rh.goals_against_home + ra.goals_against_away) AS goals_against,
		(rh.goals_for_home - rh.goals_against_home + ra.goals_for_away - ra.goals_against_away) AS goals_difference,
		(rh.home_wins * 3 + rh.home_drow + ra.away_wins * 3 + ra.away_drow) AS points,
		-- статистики домашних игр
		rh.home_played,
		rh.home_wins,
		rh.home_drow,
		(rh.home_played - rh.home_wins - rh.home_drow) AS home_loss,
		rh.goals_for_home,
		rh.goals_against_home,
		(rh.goals_for_home - rh.goals_against_home) AS goals_difference_home,
		(rh.home_wins * 3 + rh.home_drow) AS home_points,
		-- статистики гостевых игр
		ra.away_played,
		ra.away_wins,
		ra.away_drow,
		(ra.away_played - ra.away_wins - ra.away_drow) AS away_loss,
		ra.goals_for_away,
		ra.goals_against_away,
		(ra.goals_for_away - ra.goals_against_away) AS goals_difference_away,
		(ra.away_wins * 3 + ra.away_drow) AS away_points
	FROM club AS c
	LEFT JOIN tournament AS t
		ON c.id_cd_country = t.id_cd_country 
			AND 
			t.id_cd_type_tournament  = (
				SELECT id FROM catalog_data WHERE value = 'Ligue'
			)
	LEFT JOIN (
		SELECT 
			cl.id_home_club,
			SUM(IF (rsl.goals_home > rsl.goals_away, 1, 0)) AS home_wins,
			SUM(IF (rsl.goals_home = rsl.goals_away, 1, 0)) AS home_drow,
			COUNT(cl.id_home_club) AS home_played,
			SUM(rsl.goals_home) AS goals_for_home,
			SUM(rsl.goals_away) AS goals_against_home			
		FROM calendar AS cl
		INNER JOIN `result` AS rsl
			ON cl.id = rsl.id_calendar
		WHERE cl.id_tournament IN (
			SELECT id 
			FROM tournament 
			WHERE id_cd_type_tournament = (
				SELECT id FROM catalog_data WHERE value = 'Ligue'))	
		GROUP BY cl.id_home_club
	) AS rh
		ON rh.id_home_club = c.id
	LEFT JOIN (
		SELECT 
			cl.id_away_club,
			SUM(IF (rsl.goals_home < rsl.goals_away, 1, 0)) AS away_wins,
			SUM(IF (rsl.goals_home = rsl.goals_away, 1, 0)) AS away_drow,
			COUNT(cl.id_away_club) AS away_played,
			SUM(rsl.goals_away) AS goals_for_away,
			SUM(rsl.goals_home) AS goals_against_away			
		FROM calendar AS cl
		INNER JOIN `result` AS rsl
			ON cl.id = rsl.id_calendar
		WHERE cl.id_tournament IN (
			SELECT id 
			FROM tournament 
			WHERE id_cd_type_tournament = (
				SELECT id FROM catalog_data WHERE value = 'Ligue'))	
		GROUP BY cl.id_away_club
	) AS ra
		ON ra.id_away_club = c.id
	ORDER BY points DESC
);

-- Представление статистик турниров
CREATE OR REPLACE VIEW tournament_statistics AS (
	SELECT
		t.id,
		t.name,
		r.played,
		r.wins_home,
		r.wins_away,
		(r.played - r.wins_home - r.wins_away) AS draws,
		(r.goals_home + r.goals_away) AS goals,
		r.goals_home,
		r.goals_away,
		((r.goals_home + r.goals_away) / r.played) AS avg_goals,
		(r.goals_home / r.played) AS avg_goals_home,
		(r.goals_away / r.played) AS avg_goals_away,
		r.avg_possesion_home,
		r.avg_possesion_away,
		(r.shots_home + shots_away) AS shots,
		r.shots_home,
		r.shots_away,
		((r.shots_home + r.shots_away) / r.played) AS avg_shots,
		(r.shots_home / r.played) AS avg_shots_home,
		(r.shots_away / r.played) AS avg_shots_away,
		(r.shots_target_home + r.shots_target_away) AS shots_target,
		r.shots_target_home,
		r.shots_target_away,
		((r.shots_target_home + r.shots_target_away) / r.played) AS avg_shots_target,
		(r.shots_target_home / r.played) AS avg_shots_target_home,
		(r.shots_target_away / r.played) AS avg_shots_target_away,
		(r.corners_home + r.corners_away) AS corners,
		r.corners_home,
		r.corners_away,
		((r.corners_home + r.corners_away) / r.played) AS avg_corners,
		(r.corners_home / r.played) AS avg_corners_home,
		(r.corners_away / r.played) AS avg_corners_away,
		(r.fouls_home + r.fouls_away) AS fouls,
		r.fouls_home,
		r.fouls_away,
		((r.fouls_home + r.fouls_away) / r.played) AS avg_fouls,
		(r.fouls_home / r.played) AS avg_fouls_home,
		(r.fouls_away / r.played) AS avg_fouls_away,
		(r.yelow_cards_home + r.yelow_cards_away) AS yelow_cards,
		r.yelow_cards_home,
		r.yelow_cards_away,
		((r.yelow_cards_home + r.yelow_cards_away) / r.played) AS avg_yelow_cards,
		(r.yelow_cards_home / r.played) AS avg_yelow_cards_home,
		(r.yelow_cards_away / r.played) AS avg_yelow_cards_away,
		(r.red_cards_home + r.red_cards_away) AS red_cards,
		r.red_cards_home,
		r.red_cards_away,
		((r.red_cards_home + r.red_cards_away) / r.played) AS avg_red_cards,
		(r.red_cards_home / r.played) AS avg_red_cards_home,
		(r.red_cards_away / r.played) AS avg_red_cards_away
	FROM tournament AS t
	LEFT JOIN (
		SELECT
			c.id_tournament,
			COUNT(c.id) AS played,
			SUM(IF(r.goals_home > r.goals_away, 1, 0)) AS wins_home,
			SUM(IF(r.goals_home < r.goals_away, 1, 0)) AS wins_away,
			SUM(r.goals_home) AS goals_home,
			SUM(r.goals_away) AS goals_away,
			AVG(possesion_home) AS avg_possesion_home,
			AVG(possesion_away) AS avg_possesion_away,
			SUM(r.shots_home) AS shots_home,
			SUM(r.shots_away) AS shots_away,
			SUM(r.shots_target_home) AS shots_target_home,
			SUM(r.shots_target_away) AS shots_target_away,
			SUM(r.corners_home) AS corners_home,
			SUM(r.corners_away) AS corners_away,
			SUM(r.fouls_home) AS fouls_home,
			SUM(r.fouls_away) AS fouls_away,
			SUM(r.yelow_cards_home) AS yelow_cards_home,
			SUM(r.yelow_cards_away) AS yelow_cards_away,
			SUM(r.red_cards_home) AS red_cards_home,
			SUM(r.red_cards_away) AS red_cards_away
		FROM calendar AS c
		RIGHT JOIN result AS r
			ON c.id = r.id_calendar
		GROUP BY c.id_tournament
	) AS r
		ON t.id = r.id_tournament
);

-- Представление среднеквадратичных ошибок предсказанных значений
CREATE OR REPLACE VIEW err_pred_club AS (
	SELECT
		t.name AS tournament,
		c.name,
		rh.err_poss AS err_poss_home,
		ra.err_poss AS err_poss_away,
		rh.err_shots AS err_shots_home,
		ra.err_shots AS err_shots_away,
		rh.err_corners AS err_corners_home,
		ra.err_corners AS err_corners_away,
		rh.err_fouls AS err_fouls_home,
		ra.err_fouls AS err_fouls_away
	FROM club AS c
	LEFT JOIN tournament AS t
		ON 
			c.id_cd_country = t.id_cd_country 
			AND 
			t.id_cd_type_tournament = (SELECT id FROM catalog_data WHERE value = 'Ligue')
	LEFT JOIN (
		SELECT
			c.id_home_club,
			SQRT(AVG(POW(r.possesion_home - stat.pred_poss_home, 2))) AS err_poss,
			SQRT(AVG(POW(r.shots_home - stat.pred_shots_home, 2))) AS err_shots,
			SQRT(AVG(POW(r.corners_home - stat.pred_corners_home, 2))) AS err_corners,
			SQRT(AVG(POW(r.fouls_home - stat.pred_fouls_home, 2))) AS err_fouls
		FROM calendar AS c
		INNER JOIN result AS r
			ON c.id = r.id_calendar
		INNER JOIN club_statistics_before_match AS stat
			ON c.id = stat.id_calendar
		GROUP BY c.id_home_club
	) AS rh
		ON c.id = rh.id_home_club
	LEFT JOIN (
		SELECT
			c.id_away_club,
			SQRT(AVG(POW(r.possesion_away - stat.pred_poss_away, 2))) AS err_poss,
			SQRT(AVG(POW(r.shots_away - stat.pred_shots_away, 2))) AS err_shots,
			SQRT(AVG(POW(r.corners_away - stat.pred_corners_away, 2))) AS err_corners,
			SQRT(AVG(POW(r.fouls_away - stat.pred_fouls_away, 2))) AS err_fouls
		FROM calendar AS c
		INNER JOIN result AS r
			ON c.id = r.id_calendar
		INNER JOIN club_statistics_before_match AS stat
			ON c.id = stat.id_calendar
		GROUP BY c.id_away_club
	) AS ra
		ON c.id = ra.id_away_club
		
);

/*------------------------------  INSERT  ------------------------------------------------------------*/


INSERT INTO catalog(name)
VALUES
        ('country'),
        ('type_turnament'),
	('status'),
	('season');

INSERT INTO catalog_data(value, id_catalog, id_catalog_data)
VALUES
        ('England', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('Germany', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('Russia', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('Spain', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('Italy', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('France', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('International', (SELECT id FROM catalog WHERE name = 'country'), NULL),
        ('Ligue', (SELECT id FROM catalog WHERE name = 'type_turnament'), NULL),
        ('Cup', (SELECT id FROM catalog WHERE name = 'type_turnament'), NULL),
       	('Not played', (SELECT id FROM catalog WHERE name = 'status'), NULL),
       	('Completed', (SELECT id FROM catalog WHERE name = 'status'), NULL),
       	('Canceled', (SELECT id FROM catalog WHERE name = 'status'), NULL),
	('Moved', (SELECT id FROM catalog WHERE name = 'status'), NULL),
	('2021-2022', (SELECT id FROM catalog WHERE name = 'season'), NULL);
       
DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp (
	id SERIAL PRIMARY KEY,
	name_1 varchar(255),
	name_2 varchar(255), 
	name_3 varchar(255)
) COMMENT = 'Временная таблица для загрузки данных из CSV файла';


LOAD DATA LOCAL INFILE '/home/georgiy/Документы/my_projects/foot_stat/Tournaments.csv'
INTO TABLE tmp
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(name_1, name_2, name_3);

INSERT INTO tournament(name, id_cd_country, id_cd_type_tournament)
select 
	tmp.name_1, cd_1.id, cd_2.id
from tmp
join catalog_data cd_1
join catalog_data cd_2
WHERE cd_1.value = tmp.name_2 and cd_2.value = tmp.name_3;

DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp (
	id SERIAL PRIMARY KEY,
	name_1 varchar(255),
	name_2 varchar(255)
) COMMENT = 'Временная таблица для загрузки данных из CSV файла';


LOAD DATA LOCAL INFILE '/home/georgiy//Документы/my_projects/foot_stat/Clubs.csv'
INTO TABLE tmp
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(name_1, name_2);

INSERT INTO club(name, id_cd_country)
SELECT 
	tmp.name_2, cd.id
FROM tmp
JOIN catalog_data cd
WHERE cd.value = tmp.name_1;

DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp (
	id SERIAL PRIMARY KEY,
	col_1 VARCHAR(255),
	col_2 DATE,
	col_3 VARCHAR(255),
	col_4 VARCHAR(255)
) COMMENT = 'Временная таблица для загрузки данных из CSV файла';


LOAD DATA LOCAL INFILE '/home/georgiy//Документы/my_projects/foot_stat/Calendar.csv'
INTO TABLE tmp
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(col_1, col_2, col_3, col_4);

INSERT INTO calendar(match_day, id_tournament, id_home_club, id_away_club)
SELECT
	tmp.col_2, t.id, h.id, a.id
FROM tmp
JOIN tournament  AS t
JOIN club AS h
JOIN club AS a
WHERE t.name = tmp.col_1 AND h.name = tmp.col_3 AND a.name = tmp.col_4
ORDER BY tmp.col_2;

DROP TABLE IF EXISTS tmp;
CREATE TEMPORARY TABLE tmp (
	col_1 DATE,
	col_2 VARCHAR(255),
	col_3 TINYINT UNSIGNED,
	col_4 TINYINT UNSIGNED,
	col_5 VARCHAR(255),
	col_6 TINYINT UNSIGNED,
	col_7 TINYINT UNSIGNED,
	col_8 VARCHAR(255),
	col_9 VARCHAR(255),
	col_10 FLOAT(4, 3),
	col_11 FLOAT(4, 3),
	col_12 TINYINT UNSIGNED,
	col_13 TINYINT UNSIGNED,
	col_14 TINYINT UNSIGNED,
	col_15 TINYINT UNSIGNED,
	col_16 TINYINT UNSIGNED,
	col_17 TINYINT UNSIGNED,
	col_18 TINYINT UNSIGNED,
	col_19 TINYINT UNSIGNED,
	col_20 TINYINT UNSIGNED,
	col_21 TINYINT UNSIGNED,
	col_22 TINYINT UNSIGNED,
	col_23 TINYINT UNSIGNED
) COMMENT = 'Временная таблица для загрузки данных из CSV файла';


LOAD DATA LOCAL INFILE '/home/georgiy//Документы/my_projects/foot_stat/Results.csv'
INTO TABLE tmp
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

INSERT INTO `result`
SELECT
	c.id, t.col_3, t.col_4, t.col_6, t.col_7, t.col_8, t.col_9, t.col_10, 
	t.col_11, t.col_12, t.col_13, t.col_14, t.col_15, t.col_16, t.col_17, 
	t.col_18, t.col_19, t.col_20, t.col_21, t.col_22, t.col_23
FROM calendar AS c
JOIN (
	SELECT tmp.*, cl_1.id AS home, cl_2.id AS away	-- Использовал звёздочку в выборке, каюсь, знаю что не правильно, но описывать 26 столбцов - лень.
	FROM tmp
	JOIN club AS cl_1
	JOIN club AS cl_2
	WHERE tmp.col_2 = cl_1.name AND tmp.col_5 = cl_2.name) AS t
WHERE t.col_1 = c.match_day AND t.home = c.id_home_club AND t.away = c.id_away_club 
;

