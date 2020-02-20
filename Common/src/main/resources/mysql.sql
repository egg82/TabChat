USE `tab_chat`;

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

DROP TABLE IF EXISTS `{prefix}worlds`;
CREATE TABLE `{prefix}worlds` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
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

DROP TABLE IF EXISTS `{prefix}channels`;
CREATE TABLE `{prefix}channels` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `prefix` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default` boolean NOT NULL DEFAULT true,
  `format` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '&6[&r{server}&r&6] [&3{world}&6] &b{prefix} {displayname} {suffix} &7>>&r {message}',
  `cooldown` bigint(8) unsigned NOT NULL DEFAULT 0,
  `distance` bigint(8) NOT NULL DEFAULT -2,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `{prefix}channels` (`id`, `name`, `prefix`) VALUES (1, 'global', '#');

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
  `location_x` double NOT NULL,
  `location_y` double NOT NULL,
  `location_z` double NOT NULL,
  `message` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}ignore`;
CREATE TABLE `{prefix}ignore` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}players` (`id`),
  `ignoree_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}players` (`id`),
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}mute`;
CREATE TABLE `{prefix}mute` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}players` (`id`),
  `staff_id` bigint(8) unsigned NOT NULL REFERENCES `{prefix}players` (`id`),
  `channel_id` bigint(8) unsigned NOT NULL DEFAULT 0 REFERENCES `{prefix}channels` (`id`),
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    `c`.`channel`,
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

SET FOREIGN_KEY_CHECKS = 1;