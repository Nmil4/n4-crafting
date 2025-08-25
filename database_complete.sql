-- N4 Crafting System Database Tables
-- Run this SQL file to create the required database tables

CREATE TABLE IF NOT EXISTS `benches` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `owner` varchar(50) NOT NULL,
    `x` float NOT NULL,
    `y` float NOT NULL,
    `z` float NOT NULL,
    `heading` float NOT NULL,
    `model` varchar(50) NOT NULL,
    `serial` varchar(50) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `serial` (`serial`),
    INDEX `owner_idx` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crafting_queue` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `bench_id` int(11) NOT NULL,
    `item` varchar(50) NOT NULL,
    `finish_time` bigint(20) NOT NULL,
    `start_time` bigint(20) DEFAULT NULL,
    `completed` tinyint(1) DEFAULT 0,
    `quantity` int(11) DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `bench_id` (`bench_id`),
    KEY `finish_time_idx` (`finish_time`),
    FOREIGN KEY (`bench_id`) REFERENCES `benches`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
