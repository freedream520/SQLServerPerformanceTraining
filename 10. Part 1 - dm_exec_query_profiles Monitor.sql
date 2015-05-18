-- while the prior query is execution, execute the following query
select session_id, node_id, physical_operator_name, estimated_row_count, row_count
from sys.dm_exec_query_profiles

