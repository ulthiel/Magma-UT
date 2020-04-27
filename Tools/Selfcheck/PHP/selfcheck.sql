CREATE TABLE `selfchecks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Date` datetime NOT NULL,
  `Package` text NOT NULL,
  `Test` text NOT NULL,
  `Result` tinyint(1) NOT NULL,
  `Time` float DEFAULT NULL,
  `Memory` int(11) DEFAULT NULL,
  `PackageVer` text,
  `MagmaVer` text,
  `Host` text NOT NULL,
  `OS` text,
  `CPU` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
