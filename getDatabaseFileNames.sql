SELECT 
	sdf.name AS [FileName],
	size/128 AS [Size_in_MB],
	fg.name AS [File_Group_Name],
	sdf.physical_name
FROM sys.database_files sdf
	INNER JOIN sys.filegroups fg
		ON sdf.data_space_id=fg.data_space_id