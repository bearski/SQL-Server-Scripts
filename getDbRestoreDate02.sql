

WITH LastRestores AS
(
	SELECT
		DatabaseName = [d].[name] ,
		[d].[create_date] ,
		[d].[compatibility_level] ,
		[d].[collation_name] ,
		[d].state_desc,
		r.restore_date,
		RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
	FROM master.sys.databases d
	LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
	WHERE d.database_id > 4
)
SELECT 
	DatabaseName, 
	restore_date, 
	state_desc, 
	iif(cast(isnull(restore_date, '1900-01-01') as date) <> cast(getdate() as date), 'WTF', 'OK') restore_status
FROM [LastRestores]
WHERE [RowNum] = 1
--and  DatabaseName like 'Intermediary_%'
order by 2 desc
