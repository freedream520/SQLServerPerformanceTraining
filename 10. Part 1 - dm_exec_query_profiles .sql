-- execute the following query in a separate window
use credit;
GO

set statistics XML on;

declare @ExecuteCounter smallint = 10;
while @ExecuteCounter > 0
begin
	
	select *
	from dbo.charge as c
	inner join dbo.member as m on c.member_no = m.member_no
	where c.statement_no between 1 and 10000000
	order by m.city, c.charge_code
	option (maxdop 1);

end

set statistics xml off