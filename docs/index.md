---
nav_order: 1
---

# Overview

All lettings and sales of social housing in England need to be logged with the Ministry of Housing, Communities and Local Government (MHCLG). This is done by data providing organisations: Local Authorities and Private Registered Providers (PRPs, i.e. housing associations).

Data is collected via a form that runs on an annual data collection window basis. Form changes are made annually to add new questions, remove any that are no longer needed, or adjust wording or answer options etc.

Each data collection window runs from 1 April to 1 April the following year (plus an extra 3 months to allow for any late submissions). This means that between April and June, 2 collection windows are open simultaneously and logs can be submitted for either. This is called the **crossover period**.

ADD (Analytics & Data Directorate) statisticians are the other primary users of the service. The data collected is transferred to MHCLG's consolidated data store (CDS) via nightly XML exports to an S3 bucket. CDS ingests and transforms this data, ultimately storing it in a MS SQL database and exposing it to analysts and statisticians via Amazon Workspaces.

## Users

External data providing organisations have 2 main user types:

- **Data coordinators** are administrators for their organisation, but may also complete logs
- **Data providers** complete the logs

Additionally, there are data protection officers (DPO). For some organisations this is a separate role, but in our codebase this is modelled as an attribute of a user (i.e. a data coordinator or provider can additionally be a DPO). They are responsible for ensuring the organisation has signed the data sharing agreement.

There are also 2 internal user types:

- **Customer support:** can administrate all organisations
- **Statisticians:** primary consumers of the collected data

## Organisations

There are 2 types of organisation:

- An **owning organisations** own housing stock. It may manage the allocation of people in and out of their accommodation, or contract this function out to managing agents.

- A **managing organisation** (or managing agent) is responsible for the allocation of people in and out of accommodation, and/or responsible for the services provided to support those people in the accommodation (in the case of supported housing).

### Relationships between organisations

Organisations that own stock can contract out the management of that stock to another organisation. This relationship is often referred to as a parent/child relationship.

This is a useful analogy as a parent can have multiple children, and a child can have many parents. A child organisation can also be a parent, and a parent organisation can also be a child organisation:

![Organisational relationships](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/organisational_relationships.png)

### User permissions within organisations

The lettings logs that a user can see depends on their role:

- Customer support users can access any lettings log

- Data coordinators can access any lettings log for which the organisation they work for is ultimately responsible for, meaning they can see logs managed by a child organisation

- Data providers can only access lettings logs for which their organisation manages (or directly owns)

Taking the relationships from the above diagram, and looking at which logs each user can access:

![User log access permissions](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/user_log_permissions.png)

## Logs

There are two types of logs: sales logs and lettings logs.
Sales and lettings logs have some validations and fields in common, but many more are specific to either sales or to lettings.

### Sales logs

From 2025 onwards, we collect data on sales of these types:

- **Discounted ownership** transactions are where the buyer(s) buy the entire property using a scheme (eg. Right to Buy scheme) that offers them a discount on the purchase price.
- **Shared ownership initial transactions** are where the buyers(s) purchase a proportion less than 100% of the property, and typically continue to pay rent on the remaining portion.
- **Staircasing** transactions are where the buyer(s) already have shared ownership of a property, and they buy an additional share, increasing the proportion they own. The first transaction is not considered a staircasing transaction. Staircasing transactions are also considered shared ownership transactions.

**Shared ownership** transactions may include either shared ownership initial transactions or staircasing transactions.

In 2024 and before, we also collected data on **outright sales** - full property sales with no discount scheme (ie any other property sale).

### Lettings logs

There are two types of lettings logs: general needs and supported housing.

- **General needs** refers to a letting that is not part of a supported housing scheme.
- **Supported housing** lettings are those belonging to a **scheme**, as described in the following section.

The user-facing `guidance` page at <https://submit-social-housing-data.communities.gov.uk/guidance> contains detail about logs which may also be useful to developers.
In particular, it lists a lot of lettings situations for which CORE does or does not collect logs.

### Supported housing schemes

A **supported housing scheme** (or service) provides shared or self-contained housing for a particular client group, for example younger or vulnerable people. A scheme can be run at one or multiple **locations**, and a single location may contain multiple units (for example bedrooms in shared houses or a bungalow with 3 bedrooms).

Logs for supported housing will share a number of similar characteristics at this location. Additional data also needs to be collected specifically regarding the supported housing scheme, such as the type of client groups served and type of support provided.

Asking these questions would require data inputters to re-enter the same information repeatedly and answer more questions than those asked for general needs lettings. Schemes exist in CORE to reduce this burden, and effectively act as predefined answer sets.
