use Intermediary_ODS
go


/*
The 1/1 = product category 1.1, then dates separated by ; then the next product category 1/3 = 1.3.  
We need to compare this with our current data in the FSB Adv Prod Category to see where 
there are categories that are on Sanpay but not FSCA and vice versa
*/

declare @string NVARCHAR(MAX) = '1/1/08012007/08012007/;1/3/08012007/08012007/;1/4/08012007/08012007/;1/5/08012007/08012007/;1/8//01102011/;1/9//01102011/;1/10//01102011/;1/11//01102011/;1/12//01102011/;1/13//01102011/;1/14/08012007/08012007/;1/20/08012007/08012007/'
declare @delimiter  NVARCHAR(255) = ';'

      SELECT Item = y.i.value('(./text())[1]', 'nvarchar(4000)')
      FROM 
      ( 
        SELECT x = CONVERT(XML, '<i>' 
          + REPLACE(@string, @delimiter, '</i><i>') 
          + '</i>').query('.')
      ) AS a CROSS APPLY x.nodes('i') AS y(i)
  