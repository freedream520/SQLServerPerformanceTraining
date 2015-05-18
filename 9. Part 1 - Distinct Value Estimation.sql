USE Credit;
GO

-- Include actual execution plan
SELECT DISTINCT charge_dt
from dbo.charge

-- note the hash match
-- actual rows = 99395
-- estimated rows = 101193
-- where does estimate come from

GO

--statistics for charge_dte?
select s.object_id, s.name, s.auto_created, COL_NAME(s.object_id, sc.column_id) as col_name
from sys.stats as s
join sys.stats_columns sc on s.stats_id = sc.stats_id and s.object_id = sc.object_id
where s.object_id = object_id(N'dbo.charge');

-- what is the "all density" value?
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000005_0DAF0CB0)
WITH DENSITY_VECTOR
-- All Density = 9.882204E-06

-- take recirpocal
select 1/9.882204E-06 -- = 101192.001298496

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