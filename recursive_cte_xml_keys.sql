

--DECLARE @xml xml
--SET @xml = '<a><b /><c><d /><d /><d /></c></a>';

--WITH Xml_CTE AS
--(
--    SELECT
--        CAST('/' + node.value('fn:local-name(.)',
--            'varchar(100)') AS varchar(100)) AS name,
--        node.query('*') AS children
--    FROM @xml.nodes('/*') AS roots(node)

--    UNION ALL

--    SELECT
--        CAST(x.name + '/' + 
--            node.value('fn:local-name(.)', 'varchar(100)') AS varchar(100)),
--        node.query('*') AS children
--    FROM Xml_CTE x
--    CROSS APPLY x.children.nodes('*') AS child(node)
--)
--SELECT DISTINCT name
--FROM Xml_CTE
--OPTION (MAXRECURSION 1000)



with remuneration_statement_xml
as (
    select top 100
    rs.[id]
    ,rs.[intermediary_code]
    ,rs.cut_off_month
    ,try_cast(rs.[statement] as xml) [xml_statement]
    from Intermediary_Compensation.[dbo].[remuneration_statement] rs
    order by id desc
    where rs.id = 1
),
xml_cte as (
    select
        cast('/' + node.value('fn:local-name(.)', 'varchar(100)') as varchar(100)) as name,
        node.query('*') as children
    from remuneration_statement_xml e
        cross apply e.[xml_statement].nodes('/*') as roots(node)

    union all

    select
        cast(x.name + '/' + 
            node.value('fn:local-name(.)', 'varchar(100)') as varchar(100)),
        node.query('*') as children
    from xml_cte x
    cross apply x.children.nodes('*') as child(node)

)
select * 
from xml_cte
option (maxrecursion 1000)