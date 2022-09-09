SELECT
  id,
  status,
  created_at,
  tenancycode,
  propcode,
  created_by_id,
  'lettings' as log_type
FROM lettings_logs

UNION

SELECT
  id,
  status,
  created_at,
  null as tenancycode,
  null as propcode,
  created_by_id,
  'sales' as log_type
FROM sales_logs
