
& .\setupEnvironment.ps1

$files = Get-ChildItem .\RestoreScripts\

foreach ($file in $files) {
    $name = ".\RestoreScripts\$file"
    $server = [System.Environment]::GetEnvironmentVariable("SQL_INSTANCE_NAME")
    $password = [System.Environment]::GetEnvironmentVariable("SQL_SA_PASSWORD")

    #Write-Output $name
    #SQLCMD.exe -S %SQL_INSTANCE_NAME% -U sa -P %SQL_SA_PASSWORD% -i 10_MaintenanceSolution.sql
    SQLCMD.exe -S $server -U sa -P $password -i $name
}