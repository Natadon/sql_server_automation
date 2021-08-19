-- Select the database to modify
USE [<DATABASE_NAME>]
GO
-- Create database user (Not the SQL Server login!)
CREATE USER [<USER_NAME>] FOR LOGIN [<EXISTING_LOGIN>]
GO
USE [<DATABASE_NAME>]
GO
-- add them to the write access role
ALTER ROLE [db_datawriter] ADD MEMBER [<USER_NAME>]
GO
