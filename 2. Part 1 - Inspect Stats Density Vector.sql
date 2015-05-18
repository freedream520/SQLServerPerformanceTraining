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
WITH DENSITY_VECTOR;
GO


-- Density = 1/# of distinct values in a column
-- if we create mulit-column stats or have a mulit-column index,
-- what do we see?

CREATE STATISTICS [charge_multi_cols] ON
dbo.charge (charge_amt, statement_no, charge_dt);
GO

DBCC SHOW_STATISTICS(N'dbo.charge', charge_multi_cols)
WITH DENSITY_VECTOR;

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
