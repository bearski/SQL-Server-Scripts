DECLARE @FolderName nvarchar(128) = N'SanPay'
DECLARE @EnvName nvarchar(128)= 'SSRSSubscriptions_DEV'
SELECT 
'DECLARE @FolderName nvarchar(128) = N''' + @FolderName + '''
DECLARE @EnvName nvarchar(128)= ''' + @EnvName + '''
EXEC [SSISDB].[catalog].[create_environment] @folder_name=@FolderName, @environment_name=@EnvName, @environment_description=N''' + COALESCE(e.description, '') + '''' 
as tsql_EnvCopy 
FROM SSISDB.catalog.folders f
INNER JOIN SSISDB.catalog.environments e on e.folder_id = f.folder_id
WHERE f.name = @FolderName
AND e.name = @EnvName
UNION ALL 
SELECT 
'EXEC [SSISDB].[catalog].[create_environment_variable] 
@folder_name=@FolderName, 
@environment_name=@EnvName, 
@variable_name=N'''+ ev.name + ''', 
@data_type=N'''+ ev.type + ''', 
@sensitive='+ CONVERT(NCHAR,ev.sensitive) +', 
@value = ' + 
CASE ev.sensitive
WHEN 0 THEN 
CASE ev.type 
WHEN 'Date Time' THEN ''''+ CONVERT(NVARCHAR(max),ev.value) + ''''
WHEN 'String' THEN 'N'''+ CONVERT(NVARCHAR(max),ev.value) + ''''
ELSE CONVERT(NVARCHAR(max),ev.value)
END 
WHEN 1 THEN 
'##########'
END + ',
@description=N'''+ ev.description + ''''
as tsql_EnvVarcreate
FROM SSISDB.catalog.folders f
INNER JOIN SSISDB.catalog.environments e on e.folder_id = f.folder_id
INNER JOIN SSISDB.catalog.environment_variables ev on ev.environment_id = e.environment_id
WHERE f.name = @FolderName
AND e.name = @EnvName