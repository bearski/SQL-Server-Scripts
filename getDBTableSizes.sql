SELECT 
    s.Name + '.' + t.NAME AS TableName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
	CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2))/1024.00 AS TotalSpaceGB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
--WHERE 
--    t.NAME NOT LIKE 'dt%' 
--    AND t.is_ms_shipped = 0
--    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 3 desc, 1

/*
SELECT DB_NAME() AS DbName, 
    name AS FileName, 
    type_desc,
    size/128.0 AS CurrentSizeMB,  
	(size/128.0)/1024 AS CurrentSizeGB,  
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE type IN (0,1);
*/




--SELECT DISTINCT DB_NAME(dovs.database_id) DBName,
--mf.physical_name PhysicalFileLocation,
--dovs.logical_volume_name AS LogicalName,
--dovs.volume_mount_point AS Drive,
--CONVERT(INT,dovs.available_bytes/1048576.0) AS FreeSpaceInMB
--FROM sys.master_files mf
--CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
--ORDER BY FreeSpaceInMB ASC
--GO

/*
SELECT object_name(sys.tables.object_id)
 FROM sys.indexes
INNER JOIN sys.tables
ON sys.indexes.object_ID=sys.tables.OBJECT_ID
WHERE sys.indexes.type=0
order by 1

SELECT object_schema_name(sys.tables.object_id)+'.'+object_name(sys.tables.object_id),
CASE WHEN sys.indexes.OBJECT_ID IS null THEN 'clustered' ELSE 'Heap' end
 FROM sys.tables
LEFT OUTER JOIN 
 sys.indexes
ON sys.indexes.object_ID=sys.tables.OBJECT_ID
and sys.indexes.type=0
where  object_schema_name(sys.tables.object_id) <>'sys'
order by 1
*/