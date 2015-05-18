use credit

GO
-- predicate referencing charge_dt

select charge_no
from dbo.charge as c
where charge_dt = '1999-07-20 10:44:42.157'
GO


-- DBCC SHOW_STATISTICS with STAT_HEADER
-- focus on : updated date, rows, rows samples, step

DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000005_0DAF0CB0)
WITH HISTOGRAM;
GO

-- RANGE_HI_KEY = upper-bound columns for bucket
-- RANGE_ROWS = # of rows in the bucket exluding upper bound (RANGE_HI_KEY)
-- EQ_ROWS = # of rows value = RANGE_HI_KEY
-- DISTINCT_RANGE_ROWS = # of rows with a distinct column value within a historgram bucket, exlcuding upper bound
-- AVG_RANGE_ROWS = Average number of rows with duplicate columns values within hist bucket, excluding upper bound calc -> RANGE_ROWS / DISTINCT_RANGE_ROWS


-- RANGE_HI_KEY is always based on leftmost column
create STATISTICS [charge_multi_cols] ON
dbo.charge (charge_amt, statement_no, charge_dt);

GO

DBCC show_statistics(N'dbo.charge', charge_multi_cols)
WITH HISTOGRAM;

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