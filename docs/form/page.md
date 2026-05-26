---
parent: Form definition
grand_parent: Generating forms
nav_order: 3
---

# Page

Pages sit below the [`Subsection`](subsection) level of a form definition.

An example page might look something like this:

```
class Form::Sales::Pages::SomePage < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "some_page"
    @depends_on = [{ "needstype" => 1 }, { "age#{@person_index}" => { "operator" => "<", "operand" => 16 } }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Question.new(nil, nil, self),
    ]
  end
end
```

In the above example the the subsection has the id `property_postcode`. This id is used for the url of the web page, but the underscore is replaced with a dash, so the url for this page would be `[environment-url]/logs/[log-id]/property-postcode` e.g. on staging this url might look like the following: `https://staging.submit-social-housing-data.communities.gov.uk/logs/1234/property-postcode`.

The header is optional but if provided is used for the heading displayed on the page.

The description is optional but if provided is used for a paragraph displayed under the page header.

It’s worth noting that like subsections a page can also have a `depends_on` which contains the set of conditions that must be met for the section to be accessible to a data provider. If the conditions are not met then the page is not routed to as part of the form flow. The `depends_on` for a page will usually depend on answers given to questions, most likely to be questions in the setup section. In the above example the page is dependent on the answer to the `needstype` question being `1`, which corresponds to picking `General needs` on that question as displayed to the data provider.

Pages can contain one or more [questions](question).

## Useful Properties

<dl>
<dt>id</dt>
<dd>
The name of the field. This should correspond to a column in the database. In the example, the id is 'ppcodenk'.
<br>
Note page IDs must be unique. If not unique, you may run into issues where the next page function will have a stack overflow exception. This is true if using `depends_on` blocks to hide/show pages. You can however reuse page names if using ternary or if conditions to dynamically add pages to a subsection. We only do this for year specific pages on CORE, so page IDs don't have to be unique across all years.
<br>
A potential issue you may see is if you accidentally set the page ID to null, the code to register all the page routes will try to register a nil route, which will set it to the root path for a log. This means you'll get a strange error on the log summary page.</dd>
<dt>depends_on</dt>
<dd>
Pages can have a `depends_on` which contains the set of conditions that must be met for the page to be accessible. It is specified as a hash from properties of a log to conditions.
<br>
A condition can be a single value that must equal the property or a hash of comparisons. Multiple conditions in a single hash work as 'AND' conditions. Multiple hashes work as 'OR' conditions.
<br>
If the conditions are not met then the page is not routed to as part of the form flow. In the above example the page is dependent on picking `General needs` on the `needstype` question, or age being 16+.</dd>
<dt>questions</dt>
<dd>Array of questions to show on the page.</dd>
</dl>
