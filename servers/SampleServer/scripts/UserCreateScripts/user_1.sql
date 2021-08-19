USE [master]
GO
CREATE LOGIN [user_1] WITH PASSWORD="<PASSWORD!>", DEFAULT_DATABASE=[AdventureWorksDW2019], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [AdventureWorksDW2019]
GO
CREATE USER [user_1] FOR LOGIN [user_1]
GO
USE [AdventureWorksDW2019]
GO
ALTER ROLE [db_datareader] ADD MEMBER [user_1]
GO