

declare @sql nvarchar(1000);
declare @file_name  nvarchar(200) = 'Y:\MSSQL\BACKUP\BATCH\SRV004685_Intermediary_Account_FULL_20190613_135420.bak';

set @sql ='RESTORE VERIFYONLY  FROM DISK=''' + @file_name + ''''
exec sp_executesql @sql;


RESTORE VERIFYONLY FROM DISK='Y:\MSSQL\BACKUP\BATCH\SRV004685_Intermediary_Account_FULL_20190613_135420.bak'
