SELECT 
	CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
	msdb.dbo.backupset.database_name, 
	msdb.dbo.backupset.backup_start_date, 
	msdb.dbo.backupset.backup_finish_date, 
	msdb.dbo.backupset.expiration_date, 
	CASE msdb..backupset.type 
	WHEN 'D' THEN 'Database' 
	WHEN 'L' THEN 'Log' 
	END AS backup_type, 
	msdb.dbo.backupset.backup_size, 
    try_convert(decimal(18,3),(backup_size)/1024/1024/1024) backup_size_GB,
	msdb.dbo.backupmediafamily.logical_device_name, 
	msdb.dbo.backupmediafamily.physical_device_name, 
	msdb.dbo.backupset.name AS backupset_name, 
	msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
	INNER JOIN msdb.dbo.backupset 
		ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (TRY_CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= TRY_CAST(GETDATE() AS DATE)) 
and msdb..backupset.type = 'D'

--and try_cast(msdb.dbo.backupset.backup_start_date as date) = try_cast(getdate() as date)
ORDER BY 
	--msdb.dbo.backupset.database_name,
	msdb.dbo.backupset.backup_finish_date desc