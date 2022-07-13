---
parent: Architecture decisions
---

# 013: Inferring LA from postcode

We use ONS data to infer local authority from postcode in the property information section.

The Office for National Statistics (ONS) publishes the National Statistics Postcode Lookup (NSPL) and ONS Postcode Directory (ONSPD) datasets, which may be used to find a local authority district for a postcode when compiling statistics.

We’re using postcodes.io API with postcodes_io gem. Postcodes.io uses OS and ONS data which is updated as soon as new data becomes available.

We are not using OS places API due to the lack of data. Closest data point to LA in OS places api is ADMINISTRATIVE_AREA which does not always match with local authority.
