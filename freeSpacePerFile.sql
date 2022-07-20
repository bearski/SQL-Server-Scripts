;with db_file_cte as
(
    select
        name,
        type_desc,
        physical_name,
        size_mb = 
            convert(decimal(11, 2), size * 8.0 / 1024),
        space_used_mb = 
            convert(decimal(11, 2), fileproperty(name, 'spaceused') * 8.0 / 1024)
    from sys.database_files
)
select
    name,
    type_desc,
    physical_name,
    size_mb,
    space_used_mb,
    space_used_percent = 
        case size_mb
            when 0 then 0
            else convert(decimal(5, 2), space_used_mb / size_mb * 100)
        end
from db_file_cte;