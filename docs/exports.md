---
nav_order: 7
---

# Exporting to CDS

All data collected by the application needs to be exported to the Consolidated Data Store (CDS) which is a data warehouse based on MS SQL running in the DAP (Data Analytics Platform).

This is done via XML exports saved in an S3 bucket.
We currently export lettings logs, users and organisations.
The data mapping for these exports can be found in:
- Lettings logs `app/services/exports/lettings_log_export_service.rb`
- Organisations `app/services/exports/organisation_export_service.rb`
- Users `app/services/exports/user_export_service.rb`

Initially the application database field names and field types were chosen to match the existing CDS data as closely as possible to minimise the amount of transformation needed. This has led to a less than optimal data model though and increasingly we should look to transform at the mapping layer where beneficial for our application.

We have a cron job triggering the export service daily at 5am.
