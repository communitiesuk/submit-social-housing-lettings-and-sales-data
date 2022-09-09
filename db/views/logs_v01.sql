SELECT
  lettings_logs.id,
  status,
  lettings_logs.created_at,
  tenancycode,
  propcode,
  created_by_id,
  owning_organisation_id,
  managing_organisation_id,
  'lettings' as log_type
FROM lettings_logs

UNION

SELECT
  sales_logs.id,
  status,
  sales_logs.created_at,
  null as tenancycode,
  null as propcode,
  created_by_id,
  owning_organisation_id,
  managing_organisation_id,
  'sales' as log_type
FROM sales_logs
