---
parent: Architecture decisions
---

# 017: Dropping ActiveAdmin & The Admin User class

Originally ActiveAdmin was used as a quick way to spin up a panel that developers or support users could use to check or amend data. An AdminUser class/model separate from the User class was created specifically for access to this (see ADR-010).

Testing ActiveAdmin with support users found that it was not useable for them. The main problems were:

- Data values were largely raw database values, not translated to value strings (which don't necessarily have a 1-1 mapping but might depend on the form year etc)
- The default design was not as accessible as the rest of the service
- The default design was very visually different and doesn't match the Govuk design patterns

We briefly explored whether the ActiveAdmin interface could be themed to [match the Govuk design system and be more accessible](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/pull/397) but that experiment itself relied on unmaintained dependencies. Overall testing suggested making ActiveAdmin maintainable and suitable for support users was likely to be more work than building those functions into the service.

As a result we removed [ActiveAdmin and the AdminUser class](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/pull/611). This helped simplify our Devise setup (only 1 authenticable model), and also helped slim down dependencies and simplify our asset setup since we know longer need to ship jQuery etc.

Support user functionality like adding, editing, activating or deactivating users, organisations, schemes and logs are now built into the service itself. In general this re-uses the same views data coordinators already have for these functions, it just lets them act on all organisations rather than the single organisation the user belongs to.
