use credit

go 
-- check statistics on dbo.charge table
select 
	s.object_id, s.name, s.auto_created,
	COL_NAME(s.object_id, sc.column_id) as col_name
from sys.stats as s
join sys.stats_columns as sc on s.stats_id = sc.stats_id and s.object_id = sc.object_id
where s.object_id = object_id('dbo.charge')

GO
-- predicate referencing charge_dt

select charge_no
from dbo.charge as c
where charge_dt = '1999-07-20 10:44:42.157'
GO
--check statistics again
select 
	s.object_id, s.name, s.auto_created,
	COL_NAME(s.object_id, sc.column_id) as col_name
from sys.stats as s
join sys.stats_columns as sc on s.stats_id = sc.stats_id and s.object_id = sc.object_id
where s.object_id = object_id('dbo.charge')
GO

-- DBCC SHOW_STATISTICS with STAT_HEADER
-- focus on : updated date, rows, rows samples, step

DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000005_0DAF0CB0)
WITH STAT_HEADER;
GO

USE [master]

ALTER DATABASE [Credit] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [Credit]
RESTORE DATABASE [Credit]
FROM	DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\CreditBackup100.bak'
WITH	FILE = 1,
		MOVE N'CreditData' TO
		     N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\CreditData.mdf',
		MOVE N'CreditLog' TO
		     N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\CreditData.ldf',
		NOUNLOAD, STATS = 5;
GO
