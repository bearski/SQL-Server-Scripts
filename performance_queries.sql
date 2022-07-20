select top 100 qs.total_elapsed_time / qs.execution_count / 1000000.0 as average_seconds,
	qs.total_elapsed_time / 1000000.0 as total_seconds,
	qs.execution_count,
	SUBSTRING(qt.text, qs.statement_start_offset / 2, (
			case 
				when qs.statement_end_offset = - 1
					then LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
				else qs.statement_end_offset
				end - qs.statement_start_offset
			) / 2) as individual_query,
	o.name as object_name,
	DB_NAME(qt.dbid) as database_name
from sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
left outer join sys.objects o on qt.objectid = o.object_id
where qt.dbid = DB_ID()
order by average_seconds desc;


select top 100 (total_logical_reads + total_logical_writes) / qs.execution_count as average_IO,
	(total_logical_reads + total_logical_writes) as total_IO,
	qs.execution_count as execution_count,
	SUBSTRING(qt.text, qs.statement_start_offset / 2, (
			case 
				when qs.statement_end_offset = - 1
					then LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
				else qs.statement_end_offset
				end - qs.statement_start_offset
			) / 2) as indivudual_query,
	o.name as object_name,
	DB_NAME(qt.dbid) as database_name
from sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
left outer join sys.objects o on qt.objectid = o.object_id
where qt.dbid = DB_ID()
order by average_IO desc;


select top (10) creation_time,
	last_execution_time,
	(total_worker_time + 0.0) / 1000 as total_worker_time,
	(total_worker_time + 0.0) / (execution_count * 1000) as [AvgCPUTime],
	execution_count,
	o.name as object_name
from sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(sql_handle) st
left outer join sys.objects o on st.objectid = o.object_id
where total_worker_time > 0
order by total_worker_time desc



EXEC sp_Who2;
