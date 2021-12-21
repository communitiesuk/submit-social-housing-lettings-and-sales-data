### ADR - 014: Annual form changes

Given that the data collection form changes annually and that the data collection windows overlap by several months to allow for late submissions of data from the previous year, we need to be able to run at least two different versions of a form concurrently. We can do this in one of at least two ways:

1. Use our existing routing logic: Make new questions for a given year dependent on the answer to the tenancy start date question, and for tweaks to the wording of existing questions and/or answer options etc, split it into two questions in the definition with each being dependent on the corresponding answer to the start date question.

2. Have a separate form definition file per year, and load the question details from the correct one based on the answer to the start date question.

We chosen option 2 which has the following impact:

- It results in a lot of duplication across form definition files since the bulk of the form is likely to be the same across following years, but this duplication is likely to be predominantly copy and paste and unlikely to add significant effort
- It makes it easier to reason about removing no longer needed logic and versions since files whose data collection windows have closed can be safely deleted without fear of impacting running data collections
- The form definition files themselves are already long and complex so splitting them up where possible makes them easier to reason about individually
- It is easy to move back to option 1 if this path is deemed not to work well
