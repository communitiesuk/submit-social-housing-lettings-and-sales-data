---
parent: Form definition
grand_parent: Generating forms
nav_order: 2
---

# Subsection

Subsections sit below the [`Section`](section) level of a form definition.

An example subsection might look something like this:

```
class Form::Sales::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = property_information
    @depends_on = [{ "setup": "completed" }]
    @label = "Property information"
  end

  def pages
    @pages ||= [Form::Sales::Pages::PropertyPostcode.new(nil, nil, self),Form::Sales::Pages::PropertyLocalAuthority.new(nil, nil, self)]
  end
end
```

In the above example the the subsection has the id `property_information`. The `depends_on` contains the set of conditions that must be met for the section to be accessible to a data provider, in this example subsection depends on the completion of the setup section/subsection (note that this is a common condition as the answers provided to questions in the setup subsection often have an impact on what questions are asked of the data provider in later subsections of the form).

The label contains the text that users will see for that subsection in the task list page of a lettings log.

The pages of the subsection in the example would be `PropertyPostcode` and `PropertyLocalAuthority`.

Subsections can contain one or more [pages](page).
