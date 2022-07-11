---
nav_order: 7
---

# Exporting to CDS

All data collected by the application needs to be exported to the Consolidated Data Store (CDS) which is a data warehouse based on MS SQL running in the DAP (Data Analytics Platform).

This is done via XML exports saved in an S3 bucket located in the DAP VPC using dedicated credentials shared out of band. The data mapping for this export can be found in `app/services/exports/case_log_export_service.rb`

Initially the application database field names and field types were chosen to match the existing CDS data as closely as possible to minimise the amount of transformation needed. This has led to a less than optimal data model though and increasingly we should look to transform at the mapping layer where beneficial for our application.

The export service is triggered nightly using [Gov PaaS tasks](https://docs.cloudfoundry.org/devguide/using-tasks.html). These tasks are triggered from a GitHub action, as Gov PaaS does not currently support the Cloud Foundry Task Scheduler.

The S3 bucket is located in the DAP VPC rather than the application VPC as DAP runs in an AWS account directly so access to the S3 bucket can be restricted to only the IPs used by the application. This is not possible the other way around as [Gov PaaS does not support restricting S3 access by IP](https://github.com/alphagov/paas-roadmap/issues/107).

## Other options previously considered

- CDC replication using a managed service such as [AWS DMS](https://aws.amazon.com/dms/)
  - Would require VPC peering which [Gov PaaS does not currently support](https://github.com/alphagov/paas-roadmap/issues/105)
  - Would require CDS to make changes to their ingestion model
