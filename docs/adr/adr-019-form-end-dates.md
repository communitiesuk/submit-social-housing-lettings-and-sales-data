---
parent: Architecture decisions
---

# 019: Form end dates

CORE operates on financial years, e.g. the 2022/23 collection is about tenancies that start on a date between 1st April 2022 and 31st March 2023 inclusive.
We allow providers until the first Friday in June to submit data for the collection year ending in March.

There might be short extensions to the deadline, so shortly after the last day to submit data, new logs cannot be created with a tenancy start date in that collection year, but existing logs can still be edited or deleted.

Also, if incorrect data is found during QA process, data providers might be asked to correct it. Once the data has been through its first QA processes and is as present and correct as possible, the ability to edit and delete logs is closed. This is typically in late summer/autumn, but it depends on the statistical analysis.

To accommodate the different end dates, we will now store 3 different dates on the form definition:

- Submission deadline (submission_deadline) - this is the date displayed at the top of a completed log in lettings and sales - "You can review and make changes to this log until 9 June 2024.". Nothing happens on this date
- New logs end date (new_logs_end_date) - no new logs for that collection year can be submitted, but logs can be edited
- Edit and delete logs end date (edit_end_date) - logs can no longer be edited or deleted. Completed logs can still be viewed. Materials / references to the collection year are removed.
