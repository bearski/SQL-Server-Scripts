
--select * from master.sys.databases;

WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    r.*,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
        LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1;

SELECT 
   [rs].[destination_database_name], 
   [rs].[restore_date], 
   [bs].[backup_start_date], 
   [bs].[backup_finish_date], 
   [bs].[database_name] as [source_database_name], 
   [bmf].[physical_device_name] as [backup_file_used_for_restore]
FROM msdb..restorehistory rs
INNER JOIN msdb..backupset bs ON [rs].[backup_set_id] = [bs].[backup_set_id]
INNER JOIN msdb..backupmediafamily bmf ON [bs].[media_set_id] = [bmf].[media_set_id] 
ORDER BY [rs].[restore_date] DESC;
