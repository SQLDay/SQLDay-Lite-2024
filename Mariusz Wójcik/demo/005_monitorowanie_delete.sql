--szybki podgląd na wielkośc loga transakcyjnego
DBCC SQLPERF(LOGSPACE);

DBCC LOGINFO;
--bardziej szczegółowe informacje

SELECT 
dbs.[name] AS [Database Name], 
CONVERT(DECIMAL(18,2), dopc1.cntr_value/1024.0) AS [Log Size (MB)], 
CONVERT(DECIMAL(18,2), dopc.cntr_value/1024.0) AS [Log Used (MB)],
CONVERT(DECIMAL(18,2), dopc1.cntr_value/1024.0) - CONVERT(DECIMAL(18,2), dopc.cntr_value/1024.0)[Log Free Space Left (MB)],
CAST(CAST(dopc.cntr_value AS FLOAT) / CAST(dopc1.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log space Used (%)], 
dbs.recovery_model_desc AS [Recovery Model], 
dbs.state_desc [Database State], 
dbs.log_reuse_wait_desc AS [Log Reuse Wait Description]
FROM sys.databases AS dbs WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS dopc  WITH (NOLOCK) ON dbs.name = dopc.instance_name
INNER JOIN sys.dm_os_performance_counters AS dopc1 WITH (NOLOCK) ON dbs.name = dopc1.instance_name
WHERE dopc.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND dopc1.counter_name LIKE N'Log File(s) Size (KB)%'
AND dopc1.cntr_value > 0 
order by 5 



--pobierz i zainstaluj zanim uruchomisz: https://github.com/amachanic/sp_whoisactive  
EXEC sp_whoisactive @get_transaction_info = 1, @sort_order = '[tran_log_writes] DESC'


  
--bardziej szczegółowe informacje o wykonanym DELETE (jesli puste - checkpoint się wykonał i log transakcyjny jest pusty
SELECT  [Transaction ID],
  [Transaction Name],
    Operation,
    Context,
    AllocUnitName 
	[Current LSN],
	[Begin Time]
	FROM fn_dblog(NULL, NULL) 
  WHERE Operation = 'LOP_DELETE_ROWS'

  

SELECT    Operation,
    [Transaction ID],
    [Begin Time],
    [Transaction Name],
    [Transaction SID]
FROM fn_dblog(NULL, NULL)

WHERE [Transaction ID] = '' --wstawić wartość z poprzedniego zapytania
AND   [Operation] = 'LOP_BEGIN_XACT'