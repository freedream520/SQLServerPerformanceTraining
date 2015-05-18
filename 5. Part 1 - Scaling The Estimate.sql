use credit

go

-- the prior demo showed that EQ_ROWS and estimated rows matched
-- include actual execution plan
select charge_no
from dbo.charge
where charge_amt = 50.00

-- what if we add 10,000 rows (small enough not to tip auto-update)?
-- disabled actual execution plan
set nocount on
go

insert dbo.charge (member_no, provider_no, category_no, charge_dt, charge_amt, statement_no, charge_code)
values ( 8842, 484, 2, '2014-04-06 01:01:21', 50.00, 5561, '');
GO 10000

-- do we get a different estimate?
-- include actual execution plan
select charge_no
from dbo.charge
where charge_amt = 50.00

--estimate is up to 516.683 from 513.474
GO

--statistics for charge_amt?
select s.object_id, s.name, s.auto_created, COL_NAME(s.object_id, sc.column_id) as col_name
from sys.stats as s
join sys.stats_columns sc on s.stats_id = sc.stats_id and s.object_id = sc.object_id
where s.object_id = object_id(N'dbo.charge');

-- what is the selectivity for the specific 50.00 step?
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0);

-- EQ_Rows / Rows before insert! since Stats not updated!!
select 0.000320921312 as Selectivity;

GO

-- And what is the selectivity * current rowcount?
select 0.000320921312 * (select count(*) from dbo.charge); 

-- = 516.683312320000
-- therefore  = selectivity * Current Table Cardinality
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