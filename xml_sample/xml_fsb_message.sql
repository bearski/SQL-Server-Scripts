use Intermediary_Party
go

drop table if exists #temptable
drop table if exists #id_number
go

create table #temptable(
	ID INT,
	Content XML
)

create table #id_number(
	fsb_message_id int,
	id_number varchar(100)
)

insert  #temptable
select  id, CAST(content AS XML)
from fsb_message as ft
where id in 
(
123639,
123640,
123641,
123642,
123643,
123644,
123645,
123646,
123647,
123648,
123649,
123650,
123651,
123652,
123653,
123654,
123655,
123656,
123657,
123658,
123659,
123660,
123661,
123662,
123663,
123664,
123665,
123666,
123667,
123668,
123669,
123670,
123671,
123672,
123673,
123674,
123675,
123676,
123677,
123678,
123679,
123680,
123681,
123682,
123683,
123684,
123685,
123686,
123687,
123689,
123691
)

insert into #id_number(fsb_message_id, id_number)
select 
	b.id,
	c.value('local-name(.)', 'VARCHAR(MAX)'),
	c.value('.', 'VARCHAR(MAX)') ColumnValue
from  #temptable b
CROSS APPLY content.nodes('//*[text()]') x(c)
where c.value('local-name(.)', 'VARCHAR(MAX)') IN ( 'IDReferenceNo', 'FSPName', 'FSP')


select id_number
from   #id_number


select *
from   #temptable 


SELECT 
    X.Y.value('(*:FSPReferenceNumber)[1]', 'VARCHAR(200)') as FSPReferenceNumber,
	X.Y.value('(*:IDReferenceNo)[1]', 'VARCHAR(200)') as IDReferenceNo
FROM #temptable e
OUTER APPLY e.content.nodes('/*:FSPREPPublicationResponse/*:FSPs/*:FSP') as X(Y)
--WHERE X.Y.value('(AnnualRevenue)[1]', 'BIGINT') > 100000


<EmployeeDetails>
  <BusinessEntityID>3</BusinessEntityID>
  <NationalIDNumber>509647174</NationalIDNumber>
  <JobTitle>Engineering Manager</JobTitle>
  <BirthDate>1974-11-12</BirthDate>
  <MaritalStatus>M</MaritalStatus>
  <Gender>M</Gender>
  <StoreDetail>
    <Store>
      <AnnualSales>800000</AnnualSales>
      <AnnualRevenue>80000</AnnualRevenue>
      <BankName>Guardian Bank</BankName>
      <BusinessType>BM</BusinessType>
      <YearOpened>1987</YearOpened>
      <Specialty>Touring</Specialty>
      <SquareFeet>21000</SquareFeet>
    </Store>
    <Store>
      <AnnualSales>300000</AnnualSales>
      <AnnualRevenue>30000</AnnualRevenue>
      <BankName>International Bank</BankName>
      <BusinessType>BM</BusinessType>
      <YearOpened>1982</YearOpened>
      <Specialty>Road</Specialty>
      <SquareFeet>9000</SquareFeet>
    </Store>
  </StoreDetail>
</EmployeeDetails>




select top 20
	c.value('local-name(.)', 'VARCHAR(MAX)'),
	c.value('.', 'VARCHAR(MAX)') ColumnValue
from  #temptable b
CROSS APPLY content.nodes('//*[text()]') x(c)

select
    --x.c.value('@Reference', 'nvarchar(max)') as Reference,
	x.c.value('/FSPREPPublicationResponse/CarrierCode/@Reference[1]', 'nvarchar(max)')
from   #temptable t
		outer apply t.Content.nodes('/FSPREPPublicationResponse') as x(c)
where t.id = 123639


select
    m.c.value('@id', 'nvarchar(max)') as id,
    m.c.value('@type', 'nvarchar(max)') as type,
    m.c.value('@unit', 'nvarchar(max)') as unit,
    m.c.value('@sum', 'nvarchar(max)') as [sum],
    m.c.value('@count', 'nvarchar(max)') as [count],
    m.c.value('@minValue', 'nvarchar(max)') as minValue,
    m.c.value('@maxValue', 'nvarchar(max)') as maxValue,
    m.c.value('.', 'nvarchar(max)') as Value,
    m.c.value('(text())[1]', 'nvarchar(max)') as Value2
from sqm as s
    outer apply s.data.nodes('Sqm/Metrics/Metric') as m(c)



SELECT 
	--e.*,
    X.Y.value('@CategoryNo', 'varchar(20)') as CategoryNo,
	X.Y.value('@SubCategoryNo', 'varchar(20)') as SubCategoryNo
FROM #temptable e
OUTER APPLY e.Content.nodes('/*:FSPREPPublicationResponse/*:FSPs/*:FSP/*:Categories/*:Category') as X(Y)
where e.ID = 123639


SELECT 
    X.Y.value('@FSPReferenceNumber', 'varchar(20)') as FSPReferenceNumber,
	X.Y.value('@FSPAction', 'varchar(20)') as FSPAction,
	X.Y.value('(*:Representatives/*:RepEntity/*:IDReferenceNo)[1]', 'varchar(20)') as IDReferenceNo,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/@CategoryNo)[1]', 'varchar(20)') as CategoryNo,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/@SubCategoryNo)[1]', 'varchar(20)') as SubCategoryNo,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/*:AdviceDateActive)[1]', 'varchar(20)') as AdviceDateActive,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/*:IntermediaryDateActive)[1]', 'varchar(20)') as IntermediaryDateActive
FROM #temptable e
OUTER APPLY e.Content.nodes('/*:FSPREPPublicationResponse/*:FSPs/*:FSP') as X(Y)
--where e.ID = 123639


union

SELECT 
    X.Y.value('@FSPReferenceNumber', 'varchar(20)') as FSPReferenceNumber,
	X.Y.value('@FSPAction', 'varchar(20)') as FSPAction,
	X.Y.value('(*:Representatives/*:RepEntity/*:IDReferenceNo)[1]', 'varchar(20)') as IDReferenceNo,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/@CategoryNo)[2]', 'varchar(20)') as CategoryNo,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/@SubCategoryNo)[2]', 'varchar(20)') as SubCategoryNo,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/*:AdviceDateActive)[2]', 'varchar(20)') as AdviceDateActive,
	X.Y.value('(*:Representatives/*:RepEntity/*:Categories/*:Category/*:IntermediaryDateActive)[2]', 'varchar(20)') as IntermediaryDateActive
FROM #temptable e
OUTER APPLY e.Content.nodes('/*:FSPREPPublicationResponse/*:FSPs/*:FSP') as X(Y)



order by 1

select
    Tab.Col.value('@ID', 'int') as OrderHDR_ID,
    Tab.Col.value('custID[1]', 'int') as Cust_ID,
    Tab1.Col1.value('@ID', 'int') as OrderDTL_ID,
    Tab1.Col1.value('prodID[1]', 'int') as Prod_ID,
    Tab1.Col1.value('qty[1]', 'int') as QTY,
    Tab1.Col1.value('cost[1]', 'float') as Cost,
    Tab.Col.value('count(./orderDTL)', 'int') as Cust_Ord_Count
from @xml.nodes('/Root/orderHRD') as Tab(Col)
cross apply Tab.Col.nodes('orderDTL') as Tab1(Col1)

select 
	fsp.e.value('(*:IDReferenceNo)[1]', 'varchar(20)') as IDReferenceNo
FROM #temptable.Content.nodes('/*:FSPREPPublicationResponse/*:FSPs/*:FSP/*:Representatives/*:RepEntity') as fsp(e)
OUTER APPLY fsp.e.nodes('/*:Categories/*:Category') as cat(f)
where #temptable.ID = 123639
