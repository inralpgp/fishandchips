-- # Copyright {2017} INRA (Institut National de Recherche Agronomique - FRANCE) 
-- #
-- # Licensed under the Apache License, Version 2.0 (the "License");
-- # you may not use this file except in compliance with the License.
-- # You may obtain a copy of the License at
-- #
-- #      http://www.apache.org/licenses/LICENSE-2.0
-- #
-- # Unless required by applicable law or agreed to in writing, software
-- # distributed under the License is distributed on an "AS IS" BASIS,
-- # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- # See the License for the specific language governing permissions and
-- # limitations under the License.




-- MySQL dump 10.13  Distrib 5.7.17, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: fishAndchips
-- ------------------------------------------------------
-- Server version	5.7.17-0ubuntu0.16.04.1

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
-- Table structure for table `Annotation_all_sequences`
--

DROP TABLE IF EXISTS `Annotation_all_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Annotation_all_sequences` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `contig_id` varchar(20) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `first_blast_id` varchar(100) DEFAULT NULL,
  `first_blast_identity` decimal(5,2) DEFAULT NULL,
  `first_blast_e-value` varchar(15) DEFAULT NULL,
  `reciprocal_blast_id` varchar(100) DEFAULT NULL,
  `reciprocal_blast_identity` decimal(5,2) DEFAULT NULL,
  `reciprocal_blast_e-value` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Annotation_contigs_assembled`
--

DROP TABLE IF EXISTS `Annotation_contigs_assembled`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Annotation_contigs_assembled` (
  `number` int(20) NOT NULL AUTO_INCREMENT,
  `species` varchar(50) NOT NULL,
  `contig_id` varchar(15) NOT NULL,
  `assembling` varchar(10) NOT NULL,
  `seq_length` int(15) NOT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `first_blast_id` varchar(30) DEFAULT NULL,
  `first_blast_identity` decimal(5,2) DEFAULT NULL,
  `first_blast_e-value` varchar(15) DEFAULT NULL,
  `reciprocal_blast_id` varchar(30) DEFAULT NULL,
  `reciprocal_blast_identity` decimal(5,2) DEFAULT NULL,
  `reciprocal_blast_e-value` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Details_EST_assembling`
--

DROP TABLE IF EXISTS `Details_EST_assembling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Details_EST_assembling` (
  `number` int(20) NOT NULL AUTO_INCREMENT,
  `contig_id` varchar(15) NOT NULL,
  `assembling` varchar(10) NOT NULL,
  `EST_id` varchar(12) NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Details_unigene_contigs`
--

DROP TABLE IF EXISTS `Details_unigene_contigs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Details_unigene_contigs` (
  `contig_id` varchar(20) NOT NULL,
  `title` varchar(200) NOT NULL,
  `gene_name` varchar(100) DEFAULT NULL,
  `gene_id` int(10) DEFAULT NULL,
  `unigene_expression` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`contig_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Details_unigene_without_contig`
--

DROP TABLE IF EXISTS `Details_unigene_without_contig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Details_unigene_without_contig` (
  `seq_id` varchar(20) NOT NULL,
  `gene_name` varchar(200) NOT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Final_annotation`
--

DROP TABLE IF EXISTS `Final_annotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Final_annotation` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(100) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(20) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(50) DEFAULT NULL,
  `Annotation_gene_name` varchar(250) DEFAULT NULL,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Danio_rerio`
--

DROP TABLE IF EXISTS `annotations_Danio_rerio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Danio_rerio` (
  `seq_id` varchar(100) NOT NULL,
  `contig_id` varchar(100) NOT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Dicentrarchus_labrax`
--

DROP TABLE IF EXISTS `annotations_Dicentrarchus_labrax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Dicentrarchus_labrax` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(50) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(100) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_name` text,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Gadus_morhua`
--

DROP TABLE IF EXISTS `annotations_Gadus_morhua`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Gadus_morhua` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(50) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(100) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_name` text,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Gillichthys_mirabilis`
--

DROP TABLE IF EXISTS `annotations_Gillichthys_mirabilis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Gillichthys_mirabilis` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(50) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(100) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_name` text,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Oncorhynchus_mykiss`
--

DROP TABLE IF EXISTS `annotations_Oncorhynchus_mykiss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Oncorhynchus_mykiss` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(50) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(100) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_name` text,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Salmo_salar`
--

DROP TABLE IF EXISTS `annotations_Salmo_salar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Salmo_salar` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(50) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(100) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_name` text,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `annotations_Sparus_aurata`
--

DROP TABLE IF EXISTS `annotations_Sparus_aurata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations_Sparus_aurata` (
  `seq_id` varchar(100) NOT NULL,
  `seq_length` int(7) NOT NULL,
  `species` varchar(50) NOT NULL,
  `type` varchar(6) NOT NULL,
  `clone_id` varchar(100) DEFAULT NULL,
  `end` int(1) DEFAULT NULL,
  `contig_id` varchar(100) DEFAULT NULL,
  `annotation_by` varchar(10) DEFAULT NULL,
  `blast_type` varchar(25) DEFAULT NULL,
  `blast_query_id` varchar(100) DEFAULT NULL,
  `blast_result_id` varchar(100) DEFAULT NULL,
  `blast_identity` decimal(5,2) DEFAULT NULL,
  `blast_e-value` varchar(20) DEFAULT NULL,
  `Annotation_gene_id` varchar(100) DEFAULT NULL,
  `Annotation_gene_symbol` varchar(100) DEFAULT NULL,
  `Annotation_gene_name` text,
  `Annotation_species` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `array_design`
--

DROP TABLE IF EXISTS `array_design`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `array_design` (
  `array_id` varchar(12) NOT NULL,
  `gene_id` varchar(50) NOT NULL,
  `oligo_id` varchar(100) DEFAULT NULL,
  `clone_id` varchar(100) DEFAULT NULL,
  `gb_acc` varchar(100) DEFAULT NULL,
  `species` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`array_id`,`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `array_gene`
--

DROP TABLE IF EXISTS `array_gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `array_gene` (
  `num` int(200) NOT NULL AUTO_INCREMENT,
  `array_id` varchar(12) NOT NULL,
  `gene_id` varchar(20) NOT NULL,
  `symbol` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cDNA`
--

DROP TABLE IF EXISTS `cDNA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cDNA` (
  `transcript_id` varchar(100) NOT NULL,
  `species` varchar(100) NOT NULL,
  `gene_id` varchar(100) NOT NULL,
  `gene_name` varchar(100) NOT NULL,
  `gene_details` varchar(250) NOT NULL,
  `source` varchar(100) NOT NULL,
  `acc_num` varchar(100) NOT NULL,
  PRIMARY KEY (`transcript_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cluster`
--

DROP TABLE IF EXISTS `cluster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cluster` (
  `id` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  `GO_ID` int(11) NOT NULL DEFAULT '0',
  `GO_term` text,
  `number_puce` int(11) DEFAULT NULL,
  `number_cluster` int(11) DEFAULT NULL,
  `p_value` varchar(20) DEFAULT NULL,
  `R` varchar(20) DEFAULT NULL,
  `free_term` text,
  PRIMARY KEY (`id`,`cluster_id`,`GO_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cluster_gene`
--

DROP TABLE IF EXISTS `cluster_gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cluster_gene` (
  `num` int(200) NOT NULL AUTO_INCREMENT,
  `id` int(10) NOT NULL,
  `cluster_id` int(20) NOT NULL,
  `gene_id` varchar(20) NOT NULL,
  `symbol` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5996 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cluster_sample`
--

DROP TABLE IF EXISTS `cluster_sample`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cluster_sample` (
  `id` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL,
  `term` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `datasets`
--

DROP TABLE IF EXISTS `datasets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `datasets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `directory` varchar(255) NOT NULL,
  `GSE` varchar(255) DEFAULT NULL,
  `GPL` varchar(255) DEFAULT NULL,
  `title_GPL` varchar(255) DEFAULT NULL,
  `technology_GPL` varchar(255) DEFAULT NULL,
  `species_GPL` varchar(255) DEFAULT NULL,
  `row_count` int(11) DEFAULT NULL,
  `channel_count` int(11) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `GDS` int(11) DEFAULT NULL,
  `source` varchar(255) NOT NULL,
  `quality_estimate` int(11) DEFAULT NULL,
  `pubmed_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `summary` text,
  `design` text,
  `sample_number` int(11) DEFAULT NULL,
  `sample_species` varchar(255) DEFAULT NULL,
  `quality_auto` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `directory` (`directory`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `datasets_RNAseq`
--

DROP TABLE IF EXISTS `datasets_RNAseq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `datasets_RNAseq` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `directory` varchar(255) NOT NULL,
  `experiment` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `summary` mediumtext,
  `design` mediumtext,
  `specie` varchar(255) DEFAULT NULL,
  `pubmed_id` int(11) DEFAULT NULL,
  `quality_auto` double(12,11) DEFAULT NULL,
  `quality_estimate` double(12,11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `directory_UNIQUE` (`directory`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene_selection`
--

DROP TABLE IF EXISTS `gene_selection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_selection` (
  `idStudy` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  `gene` varchar(100) NOT NULL,
  `gb_acc` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idStudy`,`cluster_id`,`gene`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene_selection_correct`
--

DROP TABLE IF EXISTS `gene_selection_correct`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_selection_correct` (
  `id` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  `gene` varchar(100) NOT NULL,
  `gb_acc` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`,`cluster_id`,`gene`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `liste_cluster_correct`
--

DROP TABLE IF EXISTS `liste_cluster_correct`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `liste_cluster_correct` (
  `id` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`cluster_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orthologies_tab`
--

DROP TABLE IF EXISTS `orthologies_tab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orthologies_tab` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `gene_id` varchar(18) NOT NULL,
  `orthologs` varchar(18) NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quality_cluster_new`
--

DROP TABLE IF EXISTS `quality_cluster_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quality_cluster_new` (
  `id` int(11) NOT NULL,
  `cluster_id` int(11) NOT NULL DEFAULT '0',
  `quality` double(12,11) DEFAULT NULL,
  PRIMARY KEY (`id`,`cluster_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `refseq`
--

DROP TABLE IF EXISTS `refseq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `refseq` (
  `seq_id` varchar(100) NOT NULL,
  `species` varchar(100) NOT NULL,
  `gene_name` varchar(100) NOT NULL,
  `gene_details` varchar(255) NOT NULL,
  `ensembl_transcript` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`seq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-04-27 10:08:38
