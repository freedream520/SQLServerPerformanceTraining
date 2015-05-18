use credit

go

--include actual execution plan
select charge_no
from dbo.charge
where charge_amt = 50.00

--statistics for charge_amt?
select s.object_id, s.name, s.auto_created, COL_NAME(s.object_id, sc.column_id) as col_name
from sys.stats as s
join sys.stats_columns sc on s.stats_id = sc.stats_id and s.object_id = sc.object_id
where s.object_id = object_id(N'dbo.charge');

-- the 513.474 estimated rows for the clustered index scan
-- suggests we used sample statistics. Did we? 
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0);

-- EQ_ROWS is 513.474

-- restoring from demo database from backup

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