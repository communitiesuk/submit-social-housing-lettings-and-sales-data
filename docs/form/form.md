## Form Definition

The current system is built around a form definition written in JSON. At the top level every form will expect to have the following attributes:

- Form type: this is to define whether the form is a lettings form or a sales form. The questions will differ between the types.
- Start date: the start of the collection window for the form, this will usually be in April.
- End date: the end date of the collection window for the form, this will usually be in July, a year after the start date.
- Sections: the sections in the form, this block is where the bulk of the form definition will be.

An example of this might look like the following:
```JSON
{ 
  "form_type": "lettings",
  "start_date": "2021-04-01T00:00:00.000+01:00",
  "end_date": "2022-07-01T00:00:00.000+01:00",
  "sections": {
    ... 
  }
}
```

Note that the end date of one form will overlap the start date of another to allow for late submissions. This means that every year there will be a period of time in which two forms are running simultaneously.

### How is the form split up?

A summary of how the form is split up is as follows:

- A form is divided up into one or more sections. 
- Each section can have one or more subsections. 
- Each subsection can have one or more pages. 
- Each page can have one or more questions.

More information about these form elements can be found in the following links:

- [Section](docs/form/section.md)
- [Subsection](docs/form/subsection.md)
- [Page](docs/form/page.md)
- [Question](docs/form/question.md)

### The Form Model, Views and Controller

Rails uses the Model, View, Controller (MVC) pattern which we follow.

#### The Form Model

There is no need to manually initialise a form object as this is handled by the FormHandler class at boot time. If a new form needs to be added then a JSON file containing the form definition should be added to `config/forms` where the FormHandler will be able to locate it and instantiate it.

A form has the following attributes:

- name: The name of the form
- setup_sections: The setup section (this is not defined in the JSON, for more information see this)
- form_definition: The parsed form JSON
- form_sections: The sections found within the form definition JSON
- type: The type of form (this is used to indicate if the form is for a sale or a letting)
- sections: The combination of the setup section with those found in the JSON definition
- subsections: The subsections of the form (these live under the sections)
- pages: The pages of the form (these live under the subsections)
- questions: The questions of the form (these live under the pages)
- start_date: The start date of the form, in iso8601 format
- end_date: The end date of the form, in iso8601 format


#### The Form Views

The main view used for rendering the form is the `app/views/form/page.html.erb` view as the Form contains multiple pages (which live in subsections within sections). This page view then renders the appropriate partials for the question types of the questions on the current page.

We currently have views for the following question types:
- Numerical
- Date
- Checkbox
- Radio
- Select
- Text
- Textarea
- Interruption screen

Interruption screen questions are radio questions used for soft validation of fields. They usually have yes and no options for a user to confirm a value is correct.

#### The Form Controller

The form controller handles the form submission as well as the rendering of the check answers page and the review page.

### The FormHandler helper class

The FormHandler helper is a helper that loads all of the defined forms and initialises them as Form objects. It can also be used to get specific forms if needed.

