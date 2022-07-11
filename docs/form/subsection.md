## Subsection

Subsections are under the section level of the form definition. A example subsection might look something like this:

```JSON
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

In the above example the the subsection has the id `property_information`. The `depends_on` contains the set of conditions that must be met for the section to be accessibile to a data provider, in this example subsection depends on the completion of the setup section/subsection (note that this is a common condition as the answers provided to questions in the setup subsection often have an impact on what questions are asked of the data provider in later subsections of the form).

The label contains the text that users will see for that subsection in the tasklist page of a case log.

The pages of the subsection in the example would be `property_postcode` and `property_local_authority`. Subsections can contain one or more pages.