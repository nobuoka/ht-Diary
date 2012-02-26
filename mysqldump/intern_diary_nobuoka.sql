-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: intern_diary_nobuoka
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `entry`
--

DROP TABLE IF EXISTS `entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entry` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `title` varchar(512) NOT NULL,
  `body` longtext NOT NULL,
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entry`
--

LOCK TABLES `entry` WRITE;
/*!40000 ALTER TABLE `entry` DISABLE KEYS */;
INSERT INTO `entry` VALUES (1,1,'ç·¨é›†ã—ã¾ã—ãŸ','åˆã‚ã¾ã—ã¦ã€‚ åˆã‚ã¦ã®æ—¥è¨˜ã§ã™ã€‚\nã‚ã„ã†ãˆãŠã€‚\n\nç·¨é›†ã—ã¦ã¿ã¾ã™ã€‚\naa\nbb\ncccc\ntest\nã¡ã‚ƒã‚“ã¨ç·¨é›†ã•ã‚Œã¦ã‚‹?\nç·¨é›†ã¦ã™ã¨\n','2012-02-26 11:47:23','2012-02-26 13:23:34'),(2,1,'ã•ã‚‰ã«è¿½åŠ ','ã•ã‚‰ã«è¨˜äº‹ã‚’è¿½åŠ ã€‚\n\næ”¹è¡Œã¨ã‹ã€‚\n','2012-02-26 11:48:01','2012-02-26 11:48:01'),(6,1,'è¨˜äº‹å‰Šé™¤å¾Œã®è¿½åŠ ','test\n','2012-02-26 11:50:13','2012-02-26 11:50:13'),(4,1,'åŒã˜ã‚¿ã‚¤ãƒˆãƒ«','åŒã˜ã‚¿ã‚¤ãƒˆãƒ«ã®æ—¥è¨˜ã‚’è¤‡æ•°\n','2012-02-26 11:49:09','2012-02-26 11:49:09'),(5,1,'åŒã˜ã‚¿ã‚¤ãƒˆãƒ«','åŒã˜ã‚¿ã‚¤ãƒˆãƒ«ã§æ›¸ã„ã¦ã¿ã‚‹\n','2012-02-26 11:49:20','2012-02-26 11:49:20'),(7,1,'test','test\n','2012-02-26 11:58:49','2012-02-26 11:58:49'),(8,1,'test','aaa\n','2012-02-26 12:00:11','2012-02-26 12:00:11');
/*!40000 ALTER TABLE `entry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `editor_cmd` varchar(1024) NOT NULL,
  `encoding` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'nobuoka','vim','UTF-8');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-02-26 22:30:17
