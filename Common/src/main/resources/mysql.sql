SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `{prefix}data`;
CREATE TABLE `{prefix}data` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `value` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}servers`;
CREATE TABLE `{prefix}servers` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `name` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}players`;
CREATE TABLE `{prefix}players` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `name` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `display_name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}worlds`;
CREATE TABLE `{prefix}worlds` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}channels`;
CREATE TABLE `{prefix}channels` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}global_channels`;
CREATE TABLE `{prefix}global_channels` (
  `id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}channels` (`id`),
  `prefix` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default` boolean NOT NULL DEFAULT true,
  `format` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '&6[&r{server}&r&6] [&3{world}&6] &b{prefix} {displayname} {suffix} &7>>&r {message}',
  `cooldown` bigint(8) unsigned NOT NULL DEFAULT 0,
  `radius` bigint(8) NOT NULL DEFAULT -2,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `{prefix}channels` (`id`, `name`) VALUES (1, 'global');
INSERT INTO `{prefix}global_channels` (`id`, `prefix`) VALUES (1, '#');

DROP TABLE IF EXISTS `{prefix}custom_channels`;
CREATE TABLE `{prefix}custom_channels` (
  `id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}channels` (`id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}player_channels`;
CREATE TABLE `{prefix}player_channels` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}players` (`id`),
  `channel_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}channels` (`id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}chat`;
CREATE TABLE `{prefix}chat` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}servers` (`id`),
  `player_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}players` (`id`),
  `channel_id` bigint(8) unsigned NOT NULL DEFAULT 1 REFERENCES `{prefix}channels` (`id`),
  `world_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}worlds` (`id`),
  `location_x` double DEFAULT NULL,
  `location_y` double DEFAULT NULL,
  `location_z` double DEFAULT NULL,
  `message` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS `{prefix}get_queue_id`;
DELIMITER ;;
CREATE PROCEDURE `{prefix}get_queue_id`(`after` BIGINT UNSIGNED, `server_id` BIGINT)
BEGIN
  SELECT
    `c`.`id`,
    `s`.`uuid` AS `server_id`,
    `s`.`name` AS `server_name`,
    `p`.`uuid` AS `player_id`,
    `p`.`name` AS `player_name`,
    `p`.`display_name` AS `player_display_name`,
    `c`.`channel_id`,
    `b`.`name` AS `channel_name`,
    `w`.`id` AS `world_id`,
    `w`.`name` AS `world_name`,
    `c`.`location_x`,
    `c`.`location_y`,
    `c`.`location_z`,
    `c`.`message`,
    `c`.`date`
  FROM `{prefix}chat` `c`
  JOIN `{prefix}channels` `b` ON `b`.`id` = `c`.`channel`
  JOIN `{prefix}servers` `s` ON `s`.`id` = `c`.`server_id`
  JOIN `{prefix}players` `p` ON `p`.`id` = `c`.`player_id`
  JOIN `{prefix}worlds` `w` ON `w`.`id` = `c`.`world_id`
  WHERE `server_id` <> `c`.`server_id` AND `c`.`id` > `after`;
END ;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `{prefix}post`;
DELIMITER ;;
CREATE PROCEDURE `{prefix}post`(`channel_id` BIGINT UNSIGNED, `server_id` BIGINT UNSIGNED, `player_id` BIGINT UNSIGNED, `world_id` BIGINT UNSIGNED, `loc_x` DOUBLE, `loc_y` DOUBLE, `loc_z` DOUBLE, `message` MEDIUMTEXT)
BEGIN
  INSERT INTO `{prefix}chat`
    (`server_id`, `player_id`, `channel_id`, `world_id`, `location_x`, `location_y`, `location_z`, `message`)
  VALUES
    (`server_id`, `player_id`, `channel_id`, `world_id`, `loc_x`, `loc_y`, `loc_z`, `message`);
END ;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `{prefix}post_simple`;
DELIMITER ;;
CREATE PROCEDURE `{prefix}post_simple`(`channel_id` BIGINT UNSIGNED, `server_id` BIGINT UNSIGNED, `player_id` BIGINT UNSIGNED, `world_id` BIGINT UNSIGNED, `message` MEDIUMTEXT)
BEGIN
  INSERT INTO `{prefix}chat`
    (`server_id`, `player_id`, `channel_id`, `world_id`, `message`)
  VALUES
    (`server_id`, `player_id`, `channel_id`, `world_id`, `message`);
END ;;
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;