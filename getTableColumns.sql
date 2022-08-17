
SELECT 
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    c.precision ,
    c.scale ,
    c.is_nullable,
    ISNULL(i.is_primary_key, 0) 'Primary Key'
	--,
	--c.name + ' ' + 
	--t.Name + 
	--case t.Name
	--	when 'bit' then ','
	--	when 'date' then ','
	--	when 'uniqueidentifier' then ','
	--	when 'datetime2' then ','
	--	when 'timestamp' then ','
	--	when 'int' then ','
	--	when 'bigint' then ','
	--	when 'decimal' then '(' + try_cast(c.precision as nvarchar(20)) + ', ' + try_cast(c.scale as nvarchar(20)) + '),'
	--	when 'nvarchar' then '(' + iif(c.max_length = -1, 'max', try_cast(c.max_length as nvarchar(20))) + '),'
	--end
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE
    c.object_id = OBJECT_ID('Customers')
order by c.column_id