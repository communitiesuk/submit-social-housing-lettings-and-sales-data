SELECT
  id,
  status,
  created_at,
  'lettings' as log_type
FROM lettings_logs

UNION

SELECT
  id,
  status,
  created_at,
  'sales' as log_type
FROM sales_logs
