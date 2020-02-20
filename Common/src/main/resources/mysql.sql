SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `{prefix}data`;
CREATE TABLE `{prefix}data` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `{prefix}name_UNIQUE` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}channels`;
CREATE TABLE `{prefix}channels` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prefix` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `format` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '&6[&r{server}&r&6] [&3{world}&6] &b{prefix} {displayname} {suffix} &7>>&r {message}',
  `cooldown` bigint(8) unsigned NOT NULL DEFAULT 0,
  `distance` bigint(8) NOT NULL DEFAULT -2,
  PRIMARY KEY (`id`),
  UNIQUE KEY `{prefix}name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `{prefix}channels` (`id`, `name`) VALUES (1, 'global');

DROP TABLE IF EXISTS `{prefix}servers`;
CREATE TABLE `{prefix}servers` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `{prefix}uuid_UNIQUE` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}worlds`;
CREATE TABLE `{prefix}worlds` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `{prefix}name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}players`;
CREATE TABLE `{prefix}players` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `{prefix}uuid_UNIQUE` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}chat`;
CREATE TABLE `{prefix}chat` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` bigint(8) unsigned NOT NULL,
  `player_id` bigint(8) unsigned NOT NULL,
  `channel` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `world_id` bigint(8) unsigned NOT NULL,
  `location_x` double NOT NULL,
  `location_y` double NOT NULL,
  `location_z` double NOT NULL,
  `message` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `{prefix}fk_chat_server_id_idx` (`server_id`),
  KEY `{prefix}fk_chat_player_id_idx` (`player_id`),
  KEY `{prefix}fk_chat_channel_idx` (`channel`),
  KEY `{prefix}fk_chat_world_id_idx` (`world_id`),
  CONSTRAINT `{prefix}fk_chat_server_id` FOREIGN KEY (`server_id`) REFERENCES `{prefix}servers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `{prefix}fk_chat_player_id` FOREIGN KEY (`player_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `{prefix}fk_chat_world_id` FOREIGN KEY (`world_id`) REFERENCES `{prefix}worlds` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `{prefix}fk_chat_channel` FOREIGN KEY (`channel`) REFERENCES `{prefix}channels` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}pms`;
CREATE TABLE `{prefix}pms` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` bigint(8) unsigned NOT NULL,
  `player1_id` bigint(8) unsigned NOT NULL,
  `player2_id` bigint(8) unsigned NOT NULL,
  `message` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `{prefix}fk_pms_server_id_idx` (`server_id`),
  KEY `{prefix}fk_pms_player1_id_idx` (`player1_id`),
  KEY `{prefix}fk_pms_player2_id_idx` (`player2_id`),
  CONSTRAINT `{prefix}fk_pms_server_id` FOREIGN KEY (`server_id`) REFERENCES `{prefix}servers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `{prefix}fk_pms_player1_id` FOREIGN KEY (`player1_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `{prefix}fk_pms_player2_id` FOREIGN KEY (`player2_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}ignore`;
CREATE TABLE `{prefix}ignore` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` bigint(8) unsigned NOT NULL,
  `ignoree_id` bigint(8) unsigned NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `{prefix}fk_ignore_player_id_idx` (`player_id`),
  KEY `{prefix}fk_ignore_ignoree_id_idx` (`ignoree_id`),
  CONSTRAINT `{prefix}fk_ignore_player_id` FOREIGN KEY (`player_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `{prefix}fk_ignore_ignoree_id` FOREIGN KEY (`ignoree_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `{prefix}mute`;
CREATE TABLE `{prefix}mute` (
  `id` bigint(8) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` bigint(8) unsigned NOT NULL,
  `staff_id` bigint(8) unsigned NOT NULL,
  `channel` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `{prefix}fk_mute_player_id_idx` (`player_id`),
  KEY `{prefix}fk_mute_staff_id_idx` (`staff_id`),
  CONSTRAINT `{prefix}fk_mute_player_id` FOREIGN KEY (`player_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `{prefix}fk_mute_staff_id` FOREIGN KEY (`staff_id`) REFERENCES `{prefix}players` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
    `l`.`name` AS `channel_name`,
    `w`.`id` AS `world_id`,
    `w`.`name` AS `world_name`,
    `c`.`location_x`,
    `c`.`location_y`,
    `c`.`location_z`,
    `c`.`message`,
    `c`.`date`
  FROM `{prefix}posted_chat` `c`
  JOIN `{prefix}servers` `s` ON `s`.`id` = `c`.`server_id`
  JOIN `{prefix}players` `p` ON `p`.`id` = `c`.`player_id`
  JOIN `{prefix}channels` `l` ON `l`.`id` = `c`.`channel`
  JOIN `{prefix}worlds` `w` ON `w`.`id` = `c`.`world_id`
  WHERE `server_id` <> `c`.`server_id` AND `c`.`id` > `after`;
END ;;
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;