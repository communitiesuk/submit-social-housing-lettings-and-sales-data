---
parent: Architecture decisions
---

# 004: Infrastructure switch to GOV.UK PaaS

The application infrastructure will be moved from the initial AWS set up to GOV.UK PaaS. The initial expectation is to have a GOV.UK PaaS account `dluhc-core` with 2 spaces `sandbox`, `production`.

Sandbox will consist of 2 small instances (512M) and 1 tiny-unencrypted-13 Postgres instance.

Production infrastructure sizing will be decided at a later time and once our account has been upgraded to a paid account.

The reasoning for this is:

- Department policy is to use GOV.UK PaaS whenever possible
- DLUHC does not have a lot of internal dev ops skills/capacity so by leveraging GOV.UK PaaS we can leverage having most of the monitoring, running, scaling and security already provided.
- We get a simpler infrastructure setup than the AWS setup we currently have
- All of the infrastructure we currently require is well supported on GOV.UK PaaS

One potential downside is that data replication to CDS may be slightly more complicated as adding our database to a VPC requires the Gov PaaS support team to do that on our behalf.

This also means the GitHub repository previously used for [Infrastructure](https://github.com/communitiesuk/mhclg-data-collection-beta-infrastructure) will be archived after this change goes in as it won’t be needed any more.
