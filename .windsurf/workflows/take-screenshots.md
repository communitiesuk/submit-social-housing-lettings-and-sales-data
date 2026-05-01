---
auto_execution_mode: 0
description: Take screenshots of what I changed and save them to review-screenshots
---

Check playwright-cli --help for available commands.
Check the git diff to see what changed.
Figure out what pages could have changed.
Take screenshots of those pages. A server will be running at http://localhost:3000/.
Ensure the question text, any error text and the submit button are all visible.
Save the screenshots to the review-screenshots folder.
Present them to me for review. Present all at once with links to the screenshots.
When presenting use `code` to show me the screenshot.
After I've confirmed them all, run ./clear-review-screenshots.sh. This is a dangerous command.