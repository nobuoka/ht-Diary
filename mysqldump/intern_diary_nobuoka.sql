-- MySQL dump 10.13  Distrib 5.1.61, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: intern_diary_nobuoka
-- ------------------------------------------------------
-- Server version	5.1.61-0ubuntu0.10.04.1

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
-- Table structure for table `article`
--

DROP TABLE IF EXISTS `article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `title` varchar(512) NOT NULL,
  `body` longtext NOT NULL,
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article`
--

LOCK TABLES `article` WRITE;
/*!40000 ALTER TABLE `article` DISABLE KEYS */;
INSERT INTO `article` VALUES (1,1,'æ›´æ–°ã—ã¾ã™','æ›´æ–°ã—ã¾ã—ãŸã€‚','2012-03-24 11:33:50','2012-03-25 02:13:39'),(2,1,'2 è¨˜äº‹ç›®','2 ç•ªç›®ã®è¨˜äº‹ã§ã™ã€‚','2012-03-24 11:55:19','2012-03-24 12:44:19'),(3,1,'3 è¨˜äº‹ç›®','æ”¹è¡Œã‚‚ã§ãã¾ã™ã€‚\n\nã¦ã™ã¨ã€‚','2012-03-24 11:56:57','2012-03-25 02:14:45'),(4,1,'ã‚‚ã£ã¨æ›¸ãã¾ã™','ãƒ†ã‚¹ãƒˆã€‚\nãƒ†ã‚¹ãƒˆã€‚\nãƒ†ã‚¹ãƒˆã€‚','2012-03-24 11:58:07','2012-03-25 02:13:50'),(5,1,'æ›¸ãã¾ã™ã€‚','ãƒ†ã‚¹ãƒˆã€‚','2012-03-24 11:58:22','2012-03-24 12:44:28'),(6,1,'a','aa','2012-03-24 11:59:23','2012-03-24 11:59:23'),(7,1,'b','bb','2012-03-24 11:59:27','2012-03-24 11:59:27'),(8,1,'c','cc','2012-03-24 11:59:31','2012-03-24 17:53:54'),(9,1,'d','dd','2012-03-24 11:59:39','2012-03-24 16:23:03'),(10,1,'e','ee','2012-03-24 11:59:42','2012-03-24 16:16:32'),(11,1,'f','ff','2012-03-24 11:59:46','2012-03-24 16:15:02'),(12,1,'g','gg','2012-03-24 11:59:57','2012-03-24 11:59:57'),(13,1,'h','hh','2012-03-24 12:00:00','2012-03-24 14:07:14'),(14,1,'i','ii','2012-03-24 12:00:04','2012-03-24 12:00:04'),(15,1,'j','jj','2012-03-24 12:00:07','2012-03-24 16:08:18'),(16,1,'k','kk','2012-03-24 12:00:33','2012-03-25 02:17:24'),(17,1,'l','ll','2012-03-24 12:00:37','2012-03-24 12:00:37'),(18,1,'m','mm','2012-03-24 12:00:41','2012-03-24 16:09:19'),(19,1,'n','nn\n\nç·¨é›†ã—ã¾ã—ãŸã€‚','2012-03-24 12:00:55','2012-03-24 16:22:47'),(20,1,'o','oo\n\nå¤‰æ›´','2012-03-24 12:00:59','2012-03-24 14:08:22'),(21,1,'p','pp','2012-03-24 12:01:14','2012-03-24 12:01:14'),(22,1,'q','qq','2012-03-24 12:01:19','2012-03-25 02:26:51'),(23,2,'è¨˜äº‹ä½œæˆ','è¨˜äº‹ã‚’æ›¸ãã¾ã™ï¼','2012-03-25 02:29:04','2012-03-25 02:29:12'),(24,2,'2 è¨˜äº‹ç›®','IE ã§ã‚‚ã¡ã‚ƒã‚“ã¨å‹•ãã¾ã™ã­ã€‚\n\næ›´æ–°ã‚‚ã§ãã‚‹ã€‚','2012-03-25 02:29:30','2012-03-25 02:29:39');
/*!40000 ALTER TABLE `article` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'nobuoka'),(2,'vividcode');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_hatena`
--

DROP TABLE IF EXISTS `user_hatena`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_hatena` (
  `name` varchar(64) NOT NULL,
  `assoc_user_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_hatena`
--

LOCK TABLES `user_hatena` WRITE;
/*!40000 ALTER TABLE `user_hatena` DISABLE KEYS */;
INSERT INTO `user_hatena` VALUES ('nobuoka',1),('vividcode',2);
/*!40000 ALTER TABLE `user_hatena` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-03-25 11:39:44
