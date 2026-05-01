---
auto_execution_mode: 0
description: Fix failing tests
---
For doing markups of PRs after they've been reviewed:
1. Use GitHub MCP to find the PR and the status of the last run
2. Start by summarising each test fail, grouping them by test fails that seem to be from the same root cause
3. Wait for me to provide any guidance
4. Then, go through each test fail group one by one, and suggest a fix for the test passing. Provide some example code if possible.
5. If I say yes, make the change, if I say no, move on to the next test fail.
6. Do this until all test fails are resolved