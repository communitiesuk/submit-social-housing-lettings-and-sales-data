---
parent: Form definition
grand_parent: Generating forms
nav_order: 1
---

# Section

Sections sit at the top level of a form definition.

An example section might look something like this:

```json
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

The label contains the text that users will see for that section in the task list page of a case log.

Sections can contain one or more [subsections](subsection).
