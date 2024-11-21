---
nav_order: 8
---

# Using the App API

In order to use the app as an API, you will need to configure requests to the API as so:

- Configure your request with Basic Auth. Set the username to be the same as `API_USER` and password as the `API_KEY` (`API_USER` and `API_KEY` are environment variables that should be set for the application)
- Check the endpoint you are calling is an action that is `create`, `show` or `update`
- Check you are setting the following request headers:
  - `Content-Type = application/json`
  - `Action = application/json` N.B. If you use `*/*` instead, the request won't be recognised as an API request`

Currently, only the Logs Controller is configured to accept and authenticate API requests, provided that the specified API environment variables are set. Please note that the API has not been actively maintained for an extended period and may not function as expected. Additionally, the required environment variables are not configured on any of the environments deployed on AWS, rendering API requests to those environments non-functional.