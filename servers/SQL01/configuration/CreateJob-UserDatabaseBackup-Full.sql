USE [msdb]
GO

/****** Object:  Job [DatabaseBackup - USER_DATABASES - FULL]    Script Date: 8/11/2021 10:31:12 PM ******/
EXEC msdb.dbo.sp_delete_job @job_id=N'85043e6b-456c-4643-bf12-a01ee0a68172', @delete_unused_schedule=1
GO

/****** Object:  Job [DatabaseBackup - USER_DATABASES - FULL]    Script Date: 8/11/2021 10:31:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 8/11/2021 10:31:12 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DatabaseBackup - USER_DATABASES - FULL]    Script Date: 8/11/2021 10:31:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseBackup]
@Databases = ''USER_DATABASES'',
@Directory = NULL,
@BackupType = ''FULL'',
@Verify = ''Y'',
@Compress=''Y'',
@CleanupTime = NULL,
@CleanupMode= ''AFTER_BACKUP'',
@CheckSum = ''Y'',
@LogToTable = ''Y''', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\$(ESCAPE_SQUOTE(JOBNAME))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


