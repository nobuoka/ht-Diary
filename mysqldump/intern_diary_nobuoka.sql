-- MySQL dump 10.13  Distrib 5.1.61, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: intern_diary_nobuoka
-- ------------------------------------------------------
-- Server version	5.1.61-0ubuntu0.11.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES binary */;
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
  PRIMARY KEY (`id`),
  KEY `article_ui_co_index` (`user_id`,`created_on`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article`
--

LOCK TABLES `article` WRITE;
/*!40000 ALTER TABLE `article` DISABLE KEYS */;
INSERT INTO `article` VALUES (1,1,'はじめまして','記事を書きます。 テストです。\n\n改行も確認。','2012-03-12 02:53:21','2012-03-28 08:21:28'),(2,1,'記事を書きます','記事！！！','2012-03-14 07:19:00','2012-03-14 07:19:00'),(15,1,'tesfe','test','2012-03-28 03:41:44','2012-03-28 03:41:44'),(5,1,'てすと1','てすとですよ','2012-03-14 09:21:52','2012-03-14 09:21:52'),(6,1,'てすとおおお','てすてすてす','2012-03-14 09:22:04','2012-03-28 08:24:58'),(7,1,'どんどんつくります','はい','2012-03-14 09:22:11','2012-03-28 08:24:55'),(8,1,'今何記事目でしょうか','','2012-03-14 09:22:21','2012-03-14 09:22:21'),(9,1,'あと 2 記事！！','書きます','2012-03-14 09:22:40','2012-03-22 09:28:11'),(14,1,'さらにタイトル変更','本文も変更。','2012-03-22 08:50:44','2012-03-22 09:37:23'),(11,1,'別の記事の更新','別の記事もちゃんと更新されるか。\n\nはい','2012-03-14 09:23:01','2012-03-22 08:24:15'),(12,1,'読み込みてすと','のための記事','2012-03-14 09:27:19','2012-03-22 07:13:45'),(13,1,'タイトル更新テスト','タイトルもちゃんと更新されるか？','2012-03-15 06:00:58','2012-03-22 08:23:57'),(16,2,'てすと','てすとです。\n\n色々書きます。 改行コードは統一すべきか...。','2012-03-28 08:18:11','2012-03-28 08:22:43'),(17,2,'もっと','書きます。\n\n編集もします。','2012-03-28 08:18:19','2012-03-28 08:18:35'),(18,2,'もっと','書きます。 \r\n\r\n改行もします。','2012-03-28 08:23:52','2012-03-28 08:23:52');
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

-- Dump completed on 2012-03-28 17:25:07
