
select r.session_id
	,r.start_time
	,TotalElapsedTime_ms = r.total_elapsed_time
	,r.[status]
	,r.command
	,DatabaseName = DB_Name(r.database_id)
	,r.wait_type
	,r.last_wait_type
	,r.wait_resource
	,r.cpu_time
	,r.reads
	,r.writes
	,r.logical_reads
	,t.[text] as [executing batch]
	,SUBSTRING(t.[text], r.statement_start_offset / 2, (
			case 
				when r.statement_end_offset = - 1
					then DATALENGTH(t.[text])
				else r.statement_end_offset
				end - r.statement_start_offset
			) / 2) as [executing statement]
	,p.query_plan
from sys.dm_exec_requests r
cross apply sys.dm_exec_sql_text(r.sql_handle) as t
cross apply sys.dm_exec_query_plan(r.plan_handle) as p
order by r.total_elapsed_time desc;

select st.text
	,qp.query_plan
	,qs.*
from (
	select top 50 *
	from sys.dm_exec_query_stats
	order by total_worker_time desc
	) as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
cross apply sys.dm_exec_query_plan(qs.plan_handle) as qp
where qs.max_worker_time > 300
	or qs.max_elapsed_time > 300
