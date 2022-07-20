declare @package varchar(50)
declare kurs cursor for
select a.package
from
(
SELECT distinct 
	left(c.name,len(c.name)-5) as package
	
	
FROM   [catalog].[folders] a
         JOIN [catalog].[projects] b ON b.folder_id = a.folder_id
         JOIN [catalog].[packages] c ON c.project_id = b.project_id
         JOIN [catalog].[environments] d ON d.folder_id = a.folder_id
WHERE  a.name = 'SanPay'
and c.name like 'ods_ssis%'

) as a
order by
	case when a.package like '%pers%' then 1
		 when a.package like '%inb%' then 2
		 when a.package like '%out%' then 3
	else 4
	end asc

open kurs
fetch next from kurs into @package

while @@FETCH_STATUS = 0
begin
	print 'exec SSIS_Sanpay_SpyTB ''' + @package + '''
	go'
	fetch next from kurs into @package	
end

close kurs
deallocate kurs
