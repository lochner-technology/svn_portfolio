-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Oct 30, 2014 at 10:50 PM
-- Server version: 5.5.40-0ubuntu0.14.04.1
-- PHP Version: 5.5.9-1ubuntu4.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `Portfolio`
--

-- --------------------------------------------------------

--
-- Table structure for table `Assignment0`
--

CREATE TABLE IF NOT EXISTS `Assignment0` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment1.0`
--

CREATE TABLE IF NOT EXISTS `Assignment1.0` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment1.1`
--

CREATE TABLE IF NOT EXISTS `Assignment1.1` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment1.2`
--

CREATE TABLE IF NOT EXISTS `Assignment1.2` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment1.3`
--

CREATE TABLE IF NOT EXISTS `Assignment1.3` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment2.0`
--

CREATE TABLE IF NOT EXISTS `Assignment2.0` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment2.1`
--

CREATE TABLE IF NOT EXISTS `Assignment2.1` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment2.2`
--

CREATE TABLE IF NOT EXISTS `Assignment2.2` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment3.0`
--

CREATE TABLE IF NOT EXISTS `Assignment3.0` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Assignment3.1`
--

CREATE TABLE IF NOT EXISTS `Assignment3.1` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `BadWords`
--

CREATE TABLE IF NOT EXISTS `BadWords` (
  `Word` text NOT NULL,
  `Substitution` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `GoodWords`
--

CREATE TABLE IF NOT EXISTS `GoodWords` (
  `Word` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `TestComments`
--

CREATE TABLE IF NOT EXISTS `TestComments` (
  `Date` date NOT NULL,
  `Name` text NOT NULL,
  `Comment` text NOT NULL,
  `Comment_ID` int(11) NOT NULL,
  `Parent_ID` int(11) NOT NULL,
  `Depth` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
