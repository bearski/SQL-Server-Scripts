DECLARE @path NVARCHAR(260);

SELECT 
   @path = REVERSE(SUBSTRING(REVERSE([path]), 
   CHARINDEX(CHAR(92), REVERSE([path])), 260)) + N'log.trc'
FROM    sys.traces
WHERE   is_default = 1;

SELECT *, rn = ROW_NUMBER() OVER 
  (PARTITION BY DatabaseName ORDER BY StartTime)
INTO #blat
FROM sys.fn_trace_gettable(@path, DEFAULT) 
WHERE DatabaseName IN (
  N'Intermediary_Account', N'Intermediary_Agreement', N'Intermediary_Ancillary_Services', 'Intermediary_Common', 'Intermediary_Communication', 'Intermediary_Compensation', 'Intermediary_Employee', 'Intermediary_ODS', 'Intermediary_Party', 'Intermediary_Reporting'
)
ORDER BY StartTime DESC; 

SELECT 
b.DatabaseName, b.TextData, b.StartTime, b2.StartTime EndTime,
  ApproximateRestoreTime = DATEDIFF(MILLISECOND, b.StartTime, b2.StartTime)
FROM #blat AS b 
LEFT OUTER JOIN #blat AS b2
ON b.DatabaseName = b2.DatabaseName
AND b2.rn = b.rn + 1
WHERE b.EventClass = 115 AND b.EventSubClass = 2
ORDER BY b.StartTime DESC;

