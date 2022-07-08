## Page

Pages are under the subsection level of the form definition. A example page might look something like this:

```JSON
"property_postcode": {
  "header": "",
  "description": "",
  "questions": {
    ...
  },
  "depends_on": [
    {
      "needstype": 1
    }
  ]
}
```

In the above example the the subsection has the id `property_postcode`. This id is used for the url of the web page, but the underscore is replaced with a hash, so the url for this page would be `[environment-url]/logs/[log-id]/property-postcode` e.g. on staging this url might look like the following: `https://dluhc-core-staging.london.cloudapps.digital/logs/1234/property-postcode`

The header is optional but if provided is used for the heading displayed on the page

The description is optional but if provided is used for a paragraph displayed under the page header

It's worth noting that like subsections a page can also have a `depends_on` which contains the set of conditions that must be met for the section to be accessibile to a data provider. If the conditions are not met then the page is not routed to as part of the form flow. The `depends_on` for a page will usually depend on answers given to questions, most likely to be questions in the setup section. In the above example the page is dependent on the answer to the `needstype` question being `1`, which corresponds to picking `General needs` on that question as displayed to the data provider.


