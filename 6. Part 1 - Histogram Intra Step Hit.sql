use credit

go

-- include actual execution plan
select charge_no
from dbo.charge
where charge_amt = 23.99;

-- actual rows = 0
-- estimated rows 303.781, where does this come from?

GO

--statistics for charge_amt?
select s.object_id, s.name, s.auto_created, COL_NAME(s.object_id, sc.column_id) as col_name
from sys.stats as s
join sys.stats_columns sc on s.stats_id = sc.stats_id and s.object_id = sc.object_id
where s.object_id = object_id(N'dbo.charge');

-- The 303.781 estimated rows for the Clustered Index Scan
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0);

-- AVERAGE_RANGE_ROWS  = 303.7806 (before rounding up)
-- since 23.99 is the histogram bucket where RANGE_HI_KEY = 24.00

--Notice the 22 DISTINCT_RANGE_ROWS. Was the sampling accurate?
SELECT distinct charge_amt
from dbo.charge
where charge_amt > 1.0 and charge_amt < 24.0

-- but anything in that range get the AVERAGE_RANGE_ROWS estimate
-- So our 23.99 still gets an estimate of 303.7806!!
-- This assumption is called the -> "Uniformity Assumption"
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