---
parent: Generating forms
has_children: true
nav_order: 3
---

# Form definition

The current system is built around a form definition constructed from various Form subclasses. At the top level every form will expect to have the following attributes:

- Form type: this is to define whether the form is a lettings form or a sales form. The questions will differ between the types.
- Start date: the start of the collection window for the form, this will usually be in April.
- Submission deadline: the official end date of the collection window for the form, this will usually be in July, a year after the start date.
- New logs end date: the end date for creating any new logs for this form
- Edit end date: the end date for editing any existing logs for this form
- Sections: the sections in the form, this block is where the bulk of the form definition will be.

Note that the end date of one form will overlap the start date of another to allow for late submissions. This means that every year there will be a period of time in which two forms are running simultaneously.

A form is split up is as follows:

- A form is divided up into one or more [sections](section)
- Each section can have one or more [subsections](subsection)
- Each subsection can have one or more [pages](page)
- Each page can have one or more [questions](question)

Rails uses the model, view, controller (MVC) pattern which we follow.

## Form model

There is no need to manually initialise a form object as this is handled by the FormHandler class at boot time.

A form has the following attributes:

- `name`: The name of the form
- `setup_sections`: The setup section
- `form_sections`: The sections passed to form on init
- `type`: The type of form (this is used to indicate if the form is for a sale or a letting)
- `sections`: The combination of the setup section with form sections
- `subsections`: The subsections of the form (these live under the sections)
- `pages`: The pages of the form (these live under the subsections)
- `questions`: The questions of the form (these live under the pages)
- `start_date`: The start date of the form, in ISO 8601 format
- `submission_deadline`: The official end date of the form, in ISO 8601 format
- `new_logs_end_date`: The new logs end date of the form, in ISO 8601 format
- `edit_end_date`: The edit end date of the form, in ISO 8601 format

Logs with a form that has `edit_end_date` in the past can no longer be edited through the UI.

## Form views

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

## Form controller

The form controller handles the form submission as well as the rendering of the check answers page and the review page.

## FormHandler helper class

The FormHandler helper is a helper that loads all of the defined forms and initialises them as Form objects. It can also be used to get specific forms if needed.
When the log type is chosen and the date is entered in the setup section of the form, an appropriate form for that log is selected and associated with the log.

The current collection window gets incremented automatically in `FormHandler` and is determined within the `form_name_from_start_year`by looking at `current_collection_start_year` method which would increment the collection window on the 1st of April each year.
