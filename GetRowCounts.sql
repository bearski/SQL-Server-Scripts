SELECT 
    SCHEMA_NAME(schema_id) [schema_name],
    cast([Tables].name as varchar(128)) table_name ,
	SUM([Partitions].[rows]) AS [TotalRowCount]
FROM sys.tables (nolock) AS [Tables]
        JOIN sys.partitions (nolock) AS [Partitions]
            ON  [Tables].[object_id] = [Partitions].[object_id]
            AND [Partitions].index_id IN ( 0, 1 )
GROUP BY 
	SCHEMA_NAME(schema_id), 
	[Tables].name
order by 1, 2 desc


