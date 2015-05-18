use credit;
go

create procedure dbo.Charge_No_by_Charge_Amt
	@charge_amt money
AS

	select charge_no
	from dbo.charge
	where charge_amt = @charge_amt;

GO

-- Iclude actual execution plan
execute dbo.Charge_No_by_Charge_Amt 50.00

-- estimated number of rows 513.474, where does this come from?
-- (instead of 381.916 density vector * rows guess in the last demo)

-- Also, look at the parameter compiled and runtime values

-- EQ_ROWS = 513.4741, since direct hit at 50
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0)
WITH HISTOGRAM;

-- does this scale well?

-- what if we add 10,000 rows (small enough not to tip auto-update)?
-- disabled actual execution plan
set nocount on
go

insert dbo.charge (member_no, provider_no, category_no, charge_dt, charge_amt, statement_no, charge_code)
values ( 8842, 484, 2, '2014-04-06 01:01:21', 50.00, 5561, '');
GO 10000

-- Iclude actual execution plan
-- Any change to estimates?
-- Estimate = 513.474 HAS NOT SCALED! We've retained the original compile time estimate
-- In execution plan click Select node and look at parameter list
-- Compiled value and Runtime value are the same which is in fact true for the above.
execute dbo.Charge_No_by_Charge_Amt 50.00

-- clear the cache 
DBCC FREEPROCCACHE;

-- Include actual execution plan
-- Estimate increased from 513.4741 from 516.683, So this HAS SCALED!!
-- Where does this come from?
execute dbo.Charge_No_by_Charge_Amt 50.00

-- statistics weren't updated so we still have 
-- the old Rows = 1600000
-- the old EQ_ROWS = 513.4741
DBCC SHOW_STATISTICS(N'dbo.charge', _WA_Sys_00000006_0DAF0CB0)

-- cacl selectivity
select 513.4741/1600000 as selectivity -- = 0.000320921312

-- scaled estimate = selectivity * current row count = 516.683312320000
select 0.000320921312 * (select count(*) from dbo.charge); --= 516.683312320000

-- NOTE! this doesn't happen automatically. 
-- We had to clear the cache so that it becomes recomiled.
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