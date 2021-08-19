
# Setup environment variables to store sa username/password and backup path
& .\setupEnvironment.ps1

<#
.SYNOPSIS
Write out a restore script based on the database name and some template text

.DESCRIPTION
Long description

.PARAMETER databaseName
Parameter description

.PARAMETER templateString
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function generateRestoreScript
{
    param (
        $databaseName, 
        $templateString
    )

    $tempString = $templateString.Replace('<DATABASENAME>', $databaseName)

    Set-Content -Path "RestoreScripts\$databaseName-Restore.sql" -Value $tempString
}

$server = [System.Environment]::GetEnvironmentVariable("SQL_INSTANCE_NAME")
$password = [System.Environment]::GetEnvironmentVariable("SQL_SA_PASSWORD")

$fullRecoveryDatabasesFileName = "fullRecoveryModeDatabases.txt"
$simpleRecoveryDatabasesFileName = "simpleRecoveryModeDatabases.txt"

# recovery_model 1 is full recovery mode and recovery_mode 3 is simple
SQLCMD.EXE -S $server -U sa -P $password -Q "select Name from sys.databases where recovery_model = 1" -o $fullRecoveryDatabasesFileName
SQLCMD.EXE -S $server -U sa -P $password -Q "select Name from sys.databases where recovery_model = 3" -o $simpleRecoveryDatabasesFileName

$backupFilesPath = [System.Environment]::GetEnvironmentVariable("SQL_BACKUP_PATH")
$fullBackupScriptText = @"
use master
go
ALTER DATABASE <DATABASENAME> SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
exec dbo.sp_DatabaseRestore 
	@Database = '<DATABASENAME>',
	@BackupPathFull = N'$backupFilesPath<DATABASENAME>\FULL\',
	@BackupPathDiff = N'$backupFilesPath<DATABASENAME>\DIFF\',
	@BackupPathLog = N'$backupFilesPath<DATABASENAME>\LOG\',
	@RunRecovery = 1
GO
ALTER DATABASE <DATABASENAME> SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO
"@

$simpleBackupScriptText = @"
use master
go
ALTER DATABASE <DATABASENAME> SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
exec dbo.sp_DatabaseRestore 
	@Database = '<DATABASENAME>',
	@BackupPathFull = N'$backupFilesPath<DATABASENAME>\FULL\',
	@RunRecovery = 1
GO
ALTER DATABASE <DATABASENAME> SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO
"@

$fullDatabases = Get-Content $fullRecoveryDatabasesFileName

# Create a directory (if it doesn't exist to store the recovery script)
mkdir RestoreScripts -Force

# In case the folder already exists, let's clean out that directory
Remove-Item -Path RestoreScripts\* -Recurse -Force

for($i = 2; $i -le $fullDatabases.Length; $i++ )
{
    $db = $fullDatabases[$i].Trim()

    if($db -eq "")
    {
        break;
    }

    generateRestoreScript -databaseName $db -templateString $fullBackupScriptText
}

$simpleDatabases = Get-Content $simpleRecoveryDatabasesFileName

for($i = 2; $i -le $simpleDatabases.Length; $i++)
{
    $db = $simpleDatabases[$i].Trim()

    if($db -eq "")
    {
        break;
    }

    generateRestoreScript -databaseName $db -templateString $simpleBackupScriptText
}

Remove-Item -Path $fullRecoveryDatabasesFileName
Remove-Item -Path $simpleRecoveryDatabasesFileName