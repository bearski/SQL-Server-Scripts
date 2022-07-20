
SELECT TOP 25
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN dm_mid.equality_columns IS NOT NULL
AND dm_mid.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY Avg_Estimated_Impact DESC
GO

/*
CREATE INDEX [IX_financial_transaction_cut_off_date] ON [Intermediary_Account].[dbo].[financial_transaction] ([cut_off_date]) INCLUDE ([business_event_id])
CREATE INDEX [IX_account_entry_gl_account] ON [Intermediary_Account].[dbo].[account_entry] ([gl_account]) INCLUDE ([amount_in_cents], [analysis_code], [gl_company], [financial_transaction_id])
CREATE INDEX [IX_payment_detail_status_payment_detail_type] ON [Intermediary_Account].[dbo].[payment_detail] ([status], [payment_detail_type]) INCLUDE ([intermediary_code], [business_transaction_id], [amount_in_cents], [admin_fee_in_cents])
CREATE INDEX [IX_payment_detail_status_payment_detail_type] ON [Intermediary_Account].[dbo].[payment_detail] ([status], [payment_detail_type]) INCLUDE ([intermediary_code], [payment_date])
*/

/*
	DatabaseID	Avg_Estimated_Impact	Last_User_Seek	TableName	Create_Statement
10	5	43.44	2020-06-12 10:48:22.727	account_entry	CREATE INDEX [IX_account_entry_amount_in_cents] ON [Intermediary_Account].[dbo].[account_entry] ([amount_in_cents]) INCLUDE ([financial_transaction_id], [account_id])
11	5	97.98	2020-06-12 11:22:48.583	account_entry	CREATE INDEX [IX_account_entry_gl_account] ON [Intermediary_Account].[dbo].[account_entry] ([gl_account]) INCLUDE ([amount_in_cents], [analysis_code], [gl_company], [financial_transaction_id])

	DatabaseID	Avg_Estimated_Impact	Last_User_Seek	TableName	Create_Statement
14	5	229.95	2020-06-12 10:48:22.727	financial_transaction	CREATE INDEX [IX_financial_transaction_cut_off_date] ON [Intermediary_Account].[dbo].[financial_transaction] ([cut_off_date]) INCLUDE ([business_event_id])

	DatabaseID	Avg_Estimated_Impact	Last_User_Seek	TableName	Create_Statement
15	5	275.79	2020-06-12 10:48:28.133	payment_detail	CREATE INDEX [IX_payment_detail_status_payment_detail_type] ON [Intermediary_Account].[dbo].[payment_detail] ([status], [payment_detail_type]) INCLUDE ([intermediary_code], [business_transaction_id], [amount_in_cents], [admin_fee_in_cents])
16	5	283.56	2020-06-12 10:48:28.077	payment_detail	CREATE INDEX [IX_payment_detail_status_payment_detail_type] ON [Intermediary_Account].[dbo].[payment_detail] ([status], [payment_detail_type]) INCLUDE ([intermediary_code], [payment_date])

	DatabaseID	Avg_Estimated_Impact	Last_User_Seek	TableName	Create_Statement
17	5	50.88	2020-06-12 11:25:47.170	payment_schedule	CREATE INDEX [IX_payment_schedule_status_payment_schedule_type] ON [Intermediary_Account].[dbo].[payment_schedule] ([status],[payment_schedule_type]) INCLUDE ([process_cut_off_date])
18	5	126.84	2020-06-12 10:48:07.353	payment_schedule	CREATE INDEX [IX_payment_schedule_status] ON [Intermediary_Account].[dbo].[payment_schedule] ([status]) INCLUDE ([payment_schedule_type], [process_cut_off_date])
19	5	84.36	2020-06-12 09:58:09.350	payment_schedule	CREATE INDEX [IX_payment_schedule_payment_schedule_type] ON [Intermediary_Account].[dbo].[payment_schedule] ([payment_schedule_type]) INCLUDE ([schedule_run_date], [schedule_payment_date], [payment_category], [process_cut_off_date])
20	5	91.15	2020-06-12 09:58:09.270	payment_schedule	CREATE INDEX [IX_payment_schedule_process_cut_off_date_payment_schedule_type] ON [Intermediary_Account].[dbo].[payment_schedule] ([process_cut_off_date],[payment_schedule_type])


*/


SELECT  OBJECT_NAME(ddius.[object_id], ddius.database_id) AS [object_name] ,
        ddius.index_id ,
        ddius.user_seeks ,
        ddius.user_scans ,
        ddius.user_lookups ,
        ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads ,
        ddius.user_updates AS user_writes ,
        ddius.last_user_scan ,
        ddius.last_user_update
FROM    sys.dm_db_index_usage_stats ddius
WHERE   ddius.database_id > 4 -- filter out system tables
        AND OBJECTPROPERTY(ddius.OBJECT_ID, 'IsUserTable') = 1
        AND ddius.index_id > 0  -- filter out heaps 
--ORDER BY ddius.user_scans DESC 
order by 1


-- List unused indexes
SELECT  OBJECT_NAME(i.[object_id]) AS [Table Name] ,
        i.name
FROM    sys.indexes AS i
        INNER JOIN sys.objects AS o ON i.[object_id] = o.[object_id]
WHERE   i.index_id NOT IN ( SELECT  ddius.index_id
                            FROM    sys.dm_db_index_usage_stats AS ddius
                            WHERE   ddius.[object_id] = i.[object_id]
                                    AND i.index_id = ddius.index_id
                                    AND database_id = DB_ID() )
        AND o.[type] = 'U'
ORDER BY OBJECT_NAME(i.[object_id]) ASC ; 


--  Identify indexes that are being maintained but not used
SELECT  '[' + DB_NAME() + '].[' + su.[name] + '].[' + o.[name] + ']'
            AS [statement] ,
        i.[name] AS [index_name] ,
        ddius.[user_seeks] + ddius.[user_scans] + ddius.[user_lookups]
            AS [user_reads] ,
        ddius.[user_updates] AS [user_writes] ,
        SUM(SP.rows) AS [total_rows]
FROM    sys.dm_db_index_usage_stats ddius
        INNER JOIN sys.indexes i ON ddius.[object_id] = i.[object_id]
                                     AND i.[index_id] = ddius.[index_id]
        INNER JOIN sys.partitions SP ON ddius.[object_id] = SP.[object_id]
                                        AND SP.[index_id] = ddius.[index_id]
        INNER JOIN sys.objects o ON ddius.[object_id] = o.[object_id]
        INNER JOIN sys.sysusers su ON o.[schema_id] = su.[UID]
WHERE   ddius.[database_id] = DB_ID() -- current database only
        AND OBJECTPROPERTY(ddius.[object_id], 'IsUserTable') = 1
        AND ddius.[index_id] > 0
GROUP BY su.[name] ,
        o.[name] ,
        i.[name] ,
        ddius.[user_seeks] + ddius.[user_scans] + ddius.[user_lookups] ,
        ddius.[user_updates]
HAVING  ddius.[user_seeks] + ddius.[user_scans] + ddius.[user_lookups] = 0
ORDER BY ddius.[user_updates] DESC ,
        su.[name] ,
        o.[name] ,
        i.[name ] 


-- Potentially inefficent non-clustered indexes (writes > reads)
SELECT  OBJECT_NAME(ddius.[object_id]) AS [Table Name] ,
        i.name AS [Index Name] ,
        i.index_id ,
        user_updates AS [Total Writes] ,
        user_seeks + user_scans + user_lookups AS [Total Reads] ,
        user_updates - ( user_seeks + user_scans + user_lookups )
            AS [Difference]
FROM    sys.dm_db_index_usage_stats AS ddius WITH ( NOLOCK )
        INNER JOIN sys.indexes AS i WITH ( NOLOCK )
            ON ddius.[object_id] = i.[object_id]
            AND i.index_id = ddius.index_id
WHERE   OBJECTPROPERTY(ddius.[object_id], 'IsUserTable') = 1
        AND ddius.database_id = DB_ID()
        AND user_updates > ( user_seeks + user_scans + user_lookups )
        AND i.index_id > 1
--ORDER BY [Difference] DESC ,
--        [Total Writes] DESC ,
--        [Total Reads] ASC ;

order by 1


--	Identify locking and blocking at the row level
SELECT  '[' + DB_NAME(ddios.[database_id]) + '].[' + su.[name] + '].['
        + o.[name] + ']' AS [statement] ,
        i.[name] AS 'index_name' ,
        ddios.[partition_number] ,
        ddios.[row_lock_count] ,
        ddios.[row_lock_wait_count] ,
        CAST (100.0 * ddios.[row_lock_wait_count]
        / ( ddios.[row_lock_count] ) AS DECIMAL(5, 2)) AS [%_times_blocked] ,
        ddios.[row_lock_wait_in_ms] ,
        CAST (1.0 * ddios.[row_lock_wait_in_ms]
        / ddios.[row_lock_wait_count] AS DECIMAL(15, 2))
             AS [avg_row_lock_wait_in_ms]
FROM    sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ddios
        INNER JOIN sys.indexes i ON ddios.[object_id] = i.[object_id]
                                     AND i.[index_id] = ddios.[index_id]
        INNER JOIN sys.objects o ON ddios.[object_id] = o.[object_id]
        INNER JOIN sys.sysusers su ON o.[schema_id] = su.[UID]
WHERE   ddios.row_lock_wait_count > 0
        AND OBJECTPROPERTY(ddios.[object_id], 'IsUserTable') = 1
        AND i.[index_id] > 0
ORDER BY ddios.[row_lock_wait_count] DESC ,
        su.[name] ,
        o.[name] ,
        i.[name ]


-- Identify latch waits
SELECT  '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME(ddios.[object_id])
        + '].[' + OBJECT_NAME(ddios.[object_id]) + ']' AS [object_name] ,
        i.[name] AS index_name ,
        ddios.page_io_latch_wait_count ,
        ddios.page_io_latch_wait_in_ms ,
        ( ddios.page_io_latch_wait_in_ms / ddios.page_io_latch_wait_count )
                                             AS avg_page_io_latch_wait_in_ms
FROM    sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ddios
        INNER JOIN sys.indexes i ON ddios.[object_id] = i.[object_id]
                                    AND i.index_id = ddios.index_id
WHERE   ddios.page_io_latch_wait_count > 0
        AND OBJECTPROPERTY(i.OBJECT_ID, 'IsUserTable') = 1
ORDER BY ddios.page_io_latch_wait_count DESC ,
        avg_page_io_latch_wait_in_ms DESC 


--	Identify lock escalations
SELECT  OBJECT_NAME(ddios.[object_id], ddios.database_id) AS [object_name] ,
        i.name AS index_name ,
        ddios.index_id ,
        ddios.partition_number ,
        ddios.index_lock_promotion_attempt_count ,
        ddios.index_lock_promotion_count ,
        ( ddios.index_lock_promotion_attempt_count
          / ddios.index_lock_promotion_count ) AS percent_success
FROM    sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ddios
        INNER JOIN sys.indexes i ON ddios.OBJECT_ID = i.OBJECT_ID
                                    AND ddios.index_id = i.index_id
WHERE   ddios.index_lock_promotion_count > 0 

--	Identify indexes associated with lock contention
SELECT  OBJECT_NAME(ddios.OBJECT_ID, ddios.database_id) AS OBJECT_NAME ,
        i.name AS index_name ,
        ddios.index_id ,
        ddios.partition_number ,
        ddios.page_lock_wait_count ,
        ddios.page_lock_wait_in_ms ,
        CASE WHEN DDMID.database_id IS NULL THEN 'N'
             ELSE 'Y'
        END AS missing_index_identified
FROM    sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ddios
        INNER JOIN sys.indexes i ON ddios.OBJECT_ID = i.OBJECT_ID
                                    AND ddios.index_id = i.index_id
        LEFT OUTER JOIN ( SELECT DISTINCT
                                    database_id ,
                                    OBJECT_ID
                          FROM      sys.dm_db_missing_index_details
                        ) AS DDMID ON DDMID.database_id = ddios.database_id
                                      AND DDMID.OBJECT_ID = ddios.OBJECT_ID
WHERE   ddios.page_lock_wait_in_ms > 0
ORDER BY ddios.page_lock_wait_count DESC ;



SELECT  user_seeks * avg_total_user_cost * ( avg_user_impact * 0.01 ) AS [index_advantage] ,
        dbmigs.last_user_seek ,
        dbmid.[statement] AS [Database.Schema.Table] ,
        dbmid.equality_columns ,
        dbmid.inequality_columns ,
        dbmid.included_columns ,
        dbmigs.unique_compiles ,
        dbmigs.user_seeks ,
        dbmigs.avg_total_user_cost ,
        dbmigs.avg_user_impact
FROM    sys.dm_db_missing_index_group_stats AS dbmigs WITH ( NOLOCK )
        INNER JOIN sys.dm_db_missing_index_groups AS dbmig WITH ( NOLOCK )
                    ON dbmigs.group_handle = dbmig.index_group_handle
        INNER JOIN sys.dm_db_missing_index_details AS dbmid WITH ( NOLOCK )
                    ON dbmig.index_handle = dbmid.index_handle
WHERE   dbmid.[database_id] = DB_ID()
ORDER BY index_advantage DESC ;
--order by [Database.Schema.Table]



index_advantage	last_user_seek	Database.Schema.Table	equality_columns	inequality_columns	included_columns	unique_compiles	user_seeks	avg_total_user_cost	avg_user_impact
2132.79399533358	2020-06-12 11:26:59.290	[Intermediary_Account].[dbo].[account_entry]	[gl_account]	NULL	[amount_in_cents], [analysis_code], [gl_company], [financial_transaction_id]	2	2	1103.35954233501	96.65
1581.53939007315	2020-06-12 10:48:22.727	[Intermediary_Account].[dbo].[account_entry]	NULL	[amount_in_cents]	[financial_transaction_id], [account_id]	6	3	3640.74445228626	14.48
7627.65971805809	2020-06-12 12:00:32.757	[Intermediary_Account].[dbo].[financial_transaction]	NULL	[cut_off_date]	[business_event_id]	20	10	2890.3598780061	26.39