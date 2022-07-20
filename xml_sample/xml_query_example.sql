/****** script for selecttopnrows command from ssms  ******/

with remuneration_statement_xml
as (
    select top 500
        [id]
        ,[intermediary_code]
        ,try_cast([statement] as xml) [xml_statement]
    from [intermediary_compensation].[dbo].[remuneration_statement]
)
SELECT 
    e.id 
    ,e.[intermediary_code]
    ,rem.val.value('(*:type)[1]', 'VARCHAR(100)') [type]
    ,rem.val.value('(*:totalAmount)[1]', 'VARCHAR(100)') totalAmount
    ,rem.val.value('(*:totalVatAmount)[1]', 'VARCHAR(100)') totalVatAmount
    ,rem.val.value('(*:remunerationDetailDataValues/*:planNumber)[1]', 'VARCHAR(100)') planNumber
    ,rem.val.value('(*:remunerationDetailDataValues/*:isTableFootNote)[1]', 'VARCHAR(100)') isTableFootNote
    ,rem.val.value('(*:remunerationDetailDataValues/*:productType)[1]', 'VARCHAR(100)') productType
    ,rem.val.value('(*:remunerationDetailDataValues/*:movementType/*:english)[1]', 'VARCHAR(100)')      movementType_english
    ,rem.val.value('(*:remunerationDetailDataValues/*:movementType/*:afrikaans)[1]', 'VARCHAR(100)')    movementType_afrikaans
    ,rem.val.value('(*:remunerationDetailDataValues/*:amount)[1]', 'VARCHAR(100)') amount
    ,rem.val.value('(*:remunerationDetailDataValues/*:vatAmount)[1]', 'VARCHAR(100)') vatAmount
    ,rem.val.value('(*:remunerationDetailDataValues/*:startDate)[1]', 'VARCHAR(100)') startDate
    ,rem.val.value('(*:remunerationDetailDataValues/*:planHolderInitials)[1]', 'VARCHAR(100)') planHolderInitials
    ,rem.val.value('(*:remunerationDetailDataValues/*:planHolderSurname)[1]', 'VARCHAR(100)') planHolderSurname
    ,rem.val.value('(*:remunerationDetailDataValues/*:annualPayment)[1]', 'VARCHAR(100)') annualPayment
    ,rem.val.value('(*:remunerationDetailDataValues/*:periodInForceStartDate)[1]', 'VARCHAR(100)') periodInForceStartDate
    ,rem.val.value('(*:remunerationDetailDataValues/*:periodInForceEndDate)[1]', 'VARCHAR(100)') periodInForceEndDate
    ,rem.val.value('(*:remunerationDetailDataValues/*:fundValue)[1]', 'VARCHAR(100)') fundValue
    ,rem.val.value('(*:remunerationDetailDataValues/*:sharePercentage)[1]', 'VARCHAR(100)') sharePercentage
    ,rem.val.value('(*:remunerationDetailDataValues/*:businessType/*:english)[1]', 'VARCHAR(100)') english
    ,rem.val.value('(*:remunerationDetailDataValues/*:businessType/*:afrikaans)[1]', 'VARCHAR(100)') afrikaans
    ,rem.val.value('(*:remunerationDetailDataValues/*:eventType/*:english)[1]', 'VARCHAR(100)') english
    ,rem.val.value('(*:remunerationDetailDataValues/*:eventType/*:afrikaans)[1]', 'VARCHAR(100)') afrikaans
    ,rem.val.value('(*:remunerationDetailDataValues/*:feePercentage)[1]', 'VARCHAR(100)') feePercentage
    ,rem.val.value('(*:remunerationDetailDataValues/*:fee)[1]', 'VARCHAR(100)') fee
    ,rem.val.value('(*:remunerationDetailDataValues/*:shortTermCode)[1]', 'VARCHAR(100)') shortTermCode
    ,rem.val.value('(*:remunerationDetailDataValues/*:realityIndicator/*:english)[1]', 'VARCHAR(100)') english
    ,rem.val.value('(*:remunerationDetailDataValues/*:realityIndicator/*:afrikaans)[1]', 'VARCHAR(100)') afrikaans
    ,rem.val.value('(*:remunerationDetailDataValues/*:frequency/*:english)[1]', 'VARCHAR(100)') english
    ,rem.val.value('(*:remunerationDetailDataValues/*:frequency/*:afrikaans)[1]', 'VARCHAR(100)') afrikaans
    ,rem.val.value('(*:remunerationDetailDataValues/*:productCode)[1]', 'VARCHAR(100)') productCode
    ,rem.val.value('(*:remunerationDetailDataValues/*:product)[1]', 'VARCHAR(100)') product
    ,rem.val.value('(*:remunerationDetailDataValues/*:monthsSinceEventType)[1]', 'VARCHAR(100)') monthsSinceEventType
    ,rem.val.value('(*:remunerationDetailDataValues/*:amountVatInclusive)[1]', 'VARCHAR(100)') amountVatInclusive
    ,rem.val.value('(*:remunerationDetailDataValues/*:applicationNumber)[1]', 'VARCHAR(100)') applicationNumber
    ,rem.val.value('(*:remunerationDetailDataValues/*:calculatedFeePercentage)[1]', 'VARCHAR(100)') calculatedFeePercentage
FROM remuneration_statement_xml e
    CROSS APPLY e.[xml_statement].nodes ('/*:request/*:remunerationDetail/*:remunerationDetailData') as rem(val)



        

