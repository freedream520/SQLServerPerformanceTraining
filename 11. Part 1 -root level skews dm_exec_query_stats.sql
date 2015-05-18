use credit;
go

-- lets step through each plan individually and then
-- re-execute and loot at sys.dm_exec_query_stats

-- test system only please
DBCC FREEPROCCACHE;
GO

-- Query 1: No Cardinality Estimate Issue
select r.region_name, m.lastname, m.firstname
from dbo.member as m
inner join dbo.region as r on r.region_no = m.region_no
where r.region_no = 9

go

-- Query 2: Cardinality Estimate Issue, Leaf-Level + Final Operator
declare @column int = 2,
@value int = 10;

select *
from dbo.charge c
inner join dbo.member m on c.member_no = m.member_no
where choose(@column, c.provider_no, c.category_no) = @value

go

-- Query 3: Cardinality Estimate Leaf-Level Skew and No Skew
-- for Root Operatory
select top (1000)
	m.member_no, m.lastname, m.firstname,
	r.region_no, r.region_name, p.provider_name,
	c.category_desc, ch.charge_no, ch.provider_no,
	ch.category_no, ch.charge_dt, ch.charge_amt,
	ch.charge_code
from dbo.provider as p
inner join dbo.charge as ch on p.provider_no = ch.provider_no
inner join dbo.member as m on m.member_no = ch.member_no
inner join dbo.region as r on r.region_no = m.region_no
inner join dbo.category as c on c.category_no = ch.category_no
go

-- detecting issues
select 
	t.text, 
	p.query_plan, 
	s.last_execution_time,
	p.query_plan.value('(//@EstimateRows)[1]','varchar(128)') as estimated_rows,
	s.last_rows
from sys.dm_exec_query_stats as s
cross apply sys.dm_exec_sql_text(s.sql_handle) as t
cross apply sys.dm_exec_query_plan(s.plan_handle) as p
where datediff(mi, s.last_execution_time, getdate()) < 1
go





