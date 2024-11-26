---
parent: Form definition
grand_parent: Generating forms
nav_order: 1
---

# Section

Sections sit at the top level of a form definition.

An example section might look something like this:

```
class Form::Sales::Sections::TenancyAndProperty < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "tenancy_and_property"
    @label =  "Property and tenancy information"
    @description = ""
    @subsections = [
      Form::Sales::Subsections::PropertyInformation.new(nil, nil, self),
      Form::Sales::Subsections::TenancyInformation.new(nil, nil, self)
    ]
  end
end
```

In the above example the section id would be `tenancy_and_property` and its subsections would be `PropertyInformation` and `TenancyInformation`.

The label contains the text that users will see for that section in the task list page of a lettings log.

Sections can contain one or more [subsections](subsection).
