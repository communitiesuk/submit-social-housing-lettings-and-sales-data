---
parent: Form definition
grand_parent: Generating forms
nav_order: 2
---

# Subsection

Subsections sit below the [`Section`](section) level of a form definition.

An example subsection might look something like this:

```json
"property_information": {
  "label": "Property information",
  "depends_on": [
    {
      "setup": "completed"
    }
  ],
  "pages": {
    "property_postcode": {
      ...
    },
    "property_local_authority": {
      ...
    }
  }
}
```

In the above example the the subsection has the id `property_information`. The `depends_on` contains the set of conditions that must be met for the section to be accessible to a data provider, in this example subsection depends on the completion of the setup section/subsection (note that this is a common condition as the answers provided to questions in the setup subsection often have an impact on what questions are asked of the data provider in later subsections of the form).

The label contains the text that users will see for that subsection in the task list page of a case log.

The pages of the subsection in the example would be `property_postcode` and `property_local_authority`.

Subsections can contain one or more [pages](page).
