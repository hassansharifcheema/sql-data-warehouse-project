/* 
============================================
Create Database and Schemas 
============================================
Script purpose
	This script creates a new database 
	named data_warehouse after checking if ir already exissts .
	if databse exists it will be dropped and recreated. The script sets up three schemas in 
	the database 'bronze', 'silver' and 'gold' to organize the data.
WARNING 
	Running this script will result in the loss of any existing data in the database. 
	Ensure that you have backed up any important data before executing this script.
*/
use master 
GO 
-- drop and recreate the database if it exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'data_warehouse')
BEGIN
	ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE data_warehouse;
END
GO
CREATE DATABASE data_warehouse;
GO
USE data_warehouse;
GO
-- Create the three schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
