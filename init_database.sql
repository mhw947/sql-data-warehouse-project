/* =================================
Create Database and Schemas 
==================================== 
Purpose: 
    Create a new database named 'DataWarehouse' after checking if it already exists.
    If it exists, it will be dropped and recreated. 

    Additionally, the script sets up three schemas within the database: 'bronze', 
    'silver', and 'gold. 

*/
USE master; 
GO 

-- Drop and recreate database 'DataWarehouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO 

USE DataWarehouse;
GO 

-- Create Schemas 
CREATE SCHEMA bronze;
GO 

CREATE SCHEMA silver; 
GO 

CREATE SCHEMA gold; 
GO 