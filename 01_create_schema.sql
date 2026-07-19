-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: toyota_car_sales_analysis
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `toyota_car_sales_analysis`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `toyota_car_sales_analysis` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `toyota_car_sales_analysis`;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_name` varchar(80) NOT NULL,
  `customer_type` varchar(20) NOT NULL,
  `region_id` int NOT NULL,
  `join_year` smallint NOT NULL,
  PRIMARY KEY (`customer_id`),
  KEY `region_id` (`region_id`),
  CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dealerships`
--

DROP TABLE IF EXISTS `dealerships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dealerships` (
  `dealership_id` int NOT NULL,
  `region_id` int NOT NULL,
  `dealership_name` varchar(80) NOT NULL,
  `city` varchar(50) NOT NULL,
  `opened_year` smallint NOT NULL,
  PRIMARY KEY (`dealership_id`),
  KEY `region_id` (`region_id`),
  CONSTRAINT `dealerships_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employee_id` int NOT NULL,
  `dealership_id` int NOT NULL,
  `employee_name` varchar(80) NOT NULL,
  `job_title` varchar(40) NOT NULL,
  `hire_year` smallint NOT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `dealership_id` (`dealership_id`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`dealership_id`) REFERENCES `dealerships` (`dealership_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `inventory_id` int NOT NULL,
  `dealership_id` int NOT NULL,
  `model_id` int NOT NULL,
  `received_date` date NOT NULL,
  `units_available` smallint unsigned NOT NULL,
  `inventory_status` varchar(15) NOT NULL,
  `cost_per_unit_usd` decimal(12,2) NOT NULL,
  PRIMARY KEY (`inventory_id`),
  KEY `dealership_id` (`dealership_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`dealership_id`) REFERENCES `dealerships` (`dealership_id`),
  CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `models`
--

DROP TABLE IF EXISTS `models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `models` (
  `model_id` int NOT NULL,
  `model_name` varchar(40) NOT NULL,
  `vehicle_type` varchar(30) NOT NULL,
  `fuel_type` varchar(20) NOT NULL,
  `base_price_usd` decimal(12,2) NOT NULL,
  PRIMARY KEY (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `regions` (
  `region_id` int NOT NULL,
  `region_name` varchar(40) NOT NULL,
  `currency_code` char(3) NOT NULL,
  PRIMARY KEY (`region_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales` (
  `sale_id` int NOT NULL,
  `sale_date` date NOT NULL,
  `customer_id` int NOT NULL,
  `model_id` int NOT NULL,
  `dealership_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `quantity` smallint unsigned NOT NULL,
  `unit_price_usd` decimal(12,2) NOT NULL,
  `discount_pct` decimal(5,2) NOT NULL,
  `payment_method` varchar(15) NOT NULL,
  PRIMARY KEY (`sale_id`),
  KEY `customer_id` (`customer_id`),
  KEY `model_id` (`model_id`),
  KEY `dealership_id` (`dealership_id`),
  KEY `employee_id` (`employee_id`),
  KEY `idx_sale_date` (`sale_date`),
  CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`model_id`),
  CONSTRAINT `sales_ibfk_3` FOREIGN KEY (`dealership_id`) REFERENCES `dealerships` (`dealership_id`),
  CONSTRAINT `sales_ibfk_4` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_records`
--

DROP TABLE IF EXISTS `service_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_records` (
  `service_id` int NOT NULL,
  `sale_id` int NOT NULL,
  `service_date` date NOT NULL,
  `service_type` varchar(30) NOT NULL,
  `service_cost_usd` decimal(10,2) NOT NULL,
  `satisfaction_score` tinyint NOT NULL,
  `service_status` varchar(15) NOT NULL,
  PRIMARY KEY (`service_id`),
  KEY `sale_id` (`sale_id`),
  CONSTRAINT `service_records_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`sale_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'toyota_car_sales_analysis'
--

--
-- Dumping routines for database 'toyota_car_sales_analysis'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-19 18:54:18
