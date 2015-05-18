use credit;
go

-- include actual execution plan
-- we know 50 is a range hi step 
--however we're not going to use this step because we using a variable
declare @charge_amt money = 50.00;

select charge_no
from dbo.charge
where charge_amt = @charge_amt;

-- the 318.916 estimated rows for the Clustered Index Scan. Where does this come from?
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0)
WITH DENSITY_VECTOR;

-- All density * current row count = 318.9156800000
select 0.0001993223 * (select count(*) from dbo.charge);

-- does this scale well?

-- what if we add 10,000 rows (small enough not to tip auto-update)?
-- disabled actual execution plan
set nocount on
go

insert dbo.charge (member_no, provider_no, category_no, charge_dt, charge_amt, statement_no, charge_code)
values ( 8842, 484, 2, '2014-04-06 01:01:21', 50.00, 5561, '');
GO 10000

-- test system only!!
DBCC FREEPROCCACHE

-- include actual execution plan
-- did out estimate change?
declare @charge_amt money = 50.00;

select charge_no
from dbo.charge
where charge_amt = @charge_amt;

-- actual increased by 10000 = 10480
-- estimate = 318.916

-- the 318.916 estimated rows for the Clustered Index Scan. Where does this come from?
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0)
WITH DENSITY_VECTOR;

-- All density * current row count = 318.9156800000
--!!! 318.9156800000 != 320.9089030000
-- IT'S NOT SCALING!!!
select 0.0001993223 * (select count(*) from dbo.charge);

-- why is it not scaled?
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0)
WITH STAT_HEADER;

-- it's using the original count in the stat header that hasn't been updated
-- all density * rows
select 0.0001993223 * 1600000 --  = 318.9156800000

-- why?
-- because we're using a local variable that isn't sniffed by query optimisation process
-- in this scenario; for example we're not using the recompile hint to make value known at execution time
-- so query optimiser has an unknown runtime value so it uses density vector to give the average
-- use case scenarios. So optimising for unkonwn.


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