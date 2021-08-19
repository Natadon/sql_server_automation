@echo off
:: Make sure we have the SA Password as an environment var in the current session
call setupEnvironment.bat

ECHO Installing Ola Hallengren's maintenance solution
SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 10_MaintenanceSolution.sql
pause
ECHO Installing Brent Ozars First Responder Kit
SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 20_Install-All-Scripts.sql
pause
ECHO Installing database backup jobs
SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 30_CreateJob-SystemDatabaseBackup-Full.sql
pause
SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 40_CreateJob-UserDatabaseBackup-Diff.sql
pause
SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 50_CreateJob-UserDatabaseBackup-Full.sql
pause
SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 60_CreateJob-UserDatabaseBackup-Log.sql

ECHO Job complete!

pause