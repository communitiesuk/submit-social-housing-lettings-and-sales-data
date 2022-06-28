# External Users

The primary users of the system are external data providing organisations: Local Authorities and Private Registered Providers (Housing Associations). These have 2 main user type:

- Data Coordinators - administrators for their own organisation, can also complete logs
- Data Providers - complete the logs

Additionally there are Data Protection Officers (DPO) which at some organisations is a separate role, but in our codebase is modelled as an attribute of the user (i.e. a data coordinator or provider can additionally be a DPO). They are responsible for ensuring the organisation has signed the data sharing agreement.

# Internal users

- Customer support (helpdesk) - can administrate all organisations
- ADD statisticians - primary consumers of the data collected via CDS/DAP
