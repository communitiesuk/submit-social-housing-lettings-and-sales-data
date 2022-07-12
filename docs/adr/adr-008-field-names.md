---
parent: Architecture decisions
---

# 008: Field names

We are changing the schema to reflect the way the data is stored in CORE. This is due to the SPSS queries that are being performed by ADD and the complexity that would come with changing them.

The field names are saved lowercase as opposed to the uppercase versions we see in CORE. This is due to Ruby expecting the uppercase parameters to be constants and database fields are expected to be lower case. These fields could be mapped to their uppercase versions during the replication if needed.

A lot of the values are now also being stored as enums. This gives as some validation by default as the values not defined in the enums will fail to save.
