SET NOCOUNT ON;

declare @backup_desc nvarchar(50)   = '';
declare @backup_dir nvarchar(100)   = '';
declare @counter int                = 0;
declare @db_name nvarchar(50)       = '';
declare @file_name nvarchar(100)    = '';
declare @limit int                  = 0;
declare @sql nvarchar(1000)         = '';
declare @timestamp nvarchar(8)      = replace(convert(nvarchar(8), getdate(), 108), ':', '') 
declare @today nvarchar(8)          = convert(nvarchar(8), getdate(), 112)

declare @db_list table (
    id int identity(1,1),
    dbName sysname
);

--  get backup dir
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', @backup_dir OUTPUT
SELECT @backup_dir = @backup_dir + '\BATCH\'

--  get database names
insert into @db_list(dbName)
    select name
    from   sys.databases
    where  name in (
        'Intermediary_Account',
        'Intermediary_Agreement',
        'Intermediary_Ancillary_Services',
        'Intermediary_Common',
        'Intermediary_Compensation',
        'Intermediary_Party',
        'Intermediary_Employee',
        'Intermediary_ODS'
    );

set @limit = @@ROWCOUNT;
set @counter = 1;


while (@counter <= @limit)
begin
    select @db_name = dbName
    from  @db_list
    where id = @counter;

    set @file_name =    @backup_dir + 
                        REPLACE(CAST(SERVERPROPERTY('ServerName') AS NVARCHAR), '\', '$') 
                        + '_' + @db_name + '_FULL_' +
                        @today + '_' + 
                        @timestamp + '.bak';
    
    set @backup_desc = 'SanPay Backup: ' + @db_name 

    set @sql =  'BACKUP DATABASE [' + @db_name + '] ' +
                'TO DISK = ''' + @file_name + '''' +
                ' WITH COMPRESSION, STATS = 1, INIT, DESCRIPTION = '''+ @backup_desc + ''''

    --print @sql;
    exec sp_executesql @sql;
    set @counter = @counter + 1;
end
GO

