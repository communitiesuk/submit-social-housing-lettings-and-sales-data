## Section

Sections are under the top level of the form definition. A example section might look something like this:

```JSON
"sections": {
    "tenancy_and_property": {
      "label": "Property and tenancy information",
      "subsections": {
        "property_information": {
          ...
        },
        "tenancy_information": {
          ...
        }
      }
    },
    ...
}
```

In the above example the section id would be `tenancy_and_property` and its subsections would be `property_information` and `tenancy_information`.

The label contains the text that users will see for that section in the tasklist page of a case log.

Sections can contain one or more subsections. For more information about subsections follow this link.