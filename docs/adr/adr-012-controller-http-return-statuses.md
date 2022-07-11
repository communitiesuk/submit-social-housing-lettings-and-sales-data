---
parent: Architecture decisions
---

# 012: Controller HTTP return statuses

Controllers assess authentication by 3 criteria:

1. Are you signed in at all?
2. Are you signed in and requesting an action that your role/user type has access to?
3. Are you signed in, requesting an action that your role/user type has access to and requesting a resource that your user has access to.

When these aren’t met they fail with the following response types:

1. 401: Unauthorized. Redirect to sign-in page.
2. 401: Unauthorized
3. 404: Not found.

This helps make it harder to determine whether a resource exists or not just by enumerating ids.
