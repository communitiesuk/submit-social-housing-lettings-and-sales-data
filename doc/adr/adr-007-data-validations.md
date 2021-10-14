### ADR - 007: Data Validations

Data validations that happen in CORE at the point of data collection fall into two categories:

- Presence checks (i.e. does a response exist for this question)
- Validity check (i.e. is the response allowed and correct)

These are handled slightly differently:

##### Validity checks

These run for all submitted data. Every time a form page (in the UI is submitted), the fields related to that form page will be checked to ensure that any responses given are valid. If they are not, an error message will be shown on screen, and it will not be possible to "Save and continue" until the response is fixed or removed.

Similarly if an API request is made to create a case log with data that contains _invalid_ fields, that data will be rejected, and an error message will be returned.


##### Presence checks

These are not strictly error checks since it's possible to submit partial data. In the form UI it is possible to click "Save and continue" and move past questions that you might not know right now, and leave them to come back to later. We shouldn't prevent this workflow.

Similar the API client (3rd party software system) may not have all the required data and may only be submitting a partial log. This is still a valid use case so we should not be enforcing presence checks and returning errors based on them for either submission type.

Instead we determine the _status_ of the case log based the presence checks. Every time data is submitted (via a form page, bulk upload or API), before saving the data, the system will check whether all fields have been completed *and* pass validity checks. If so, the case log will be marked as *completed*, if not it will be marked as *in progress*.

By default all fields that a Case Log has will be assumed to be required unless explicitly marked as not required (for example as a result of other answers rendering a question inapplicable).

On the form UI this will work by by not allowing you to "submit" the form, until all presence checks have been satisfied, but all other navigation is allowed. On the API this will work by returning a Case Log that is "in progress" if you've submitted a partial log, or "completed" if you've submitted a full log, or "Errors" if you've submitted an invalid log.
