### ADR - 005: Form Definition

#### Config driven front-end

We will initially try to model the form as a JSON structure that should describe all the information needed to display the form to the user. That means it will need to describe the sections, subsections, pages, questions, answer options etc.

The idea is to decouple the code that creates the required routes, controller methods, views etc to display the form from the actual wording of questions or order of pages such that it becomes possible to make changes to the form with little or no code changes.

This should also mean that in the future it could be possible to create a UI that can construct the JSON config, which would open up the ability to make form changes to a wider audience. Doing this fully would require generating and running the necessary migrations for data storage, generating the required ActiveRecord methods to validate the data server side, and generating/updating API endpoints and documentation. All of this is likely to be beyond the scope of initial MVP but could be looked at in the future.

Since initially the JSON config will not create database migrations or ActiveRecord model validations, it will instead assume that these have been correctly created for the config provided. The reasoning for this is the following assumptions:

- The form will be tweaked regularly (amending questions wording, changing the order of questions or the page a question is displayed on)
- The actual data collected will change very infrequently. Time series continuity is very important to ADD (Analysis and Data Directorate) so the actual data collected should stay largely consistent i.e. in general we can change the question wording in ways that makes the intent clearer or easier to understand, but not in ways that would make the data provider give a different answer. 

A form parser class will parse this config into ruby objects/methods that can be used as an API by the rest of the application, such that we could change the underlying config if needed (for example swap JSON for YAML or for DataBase objects) without needing to change the rest of the application.

#### JSON Structure

First pass of a form definition

```
{
  form_type: [lettings/sales]
  start_year: yyyy
  end_year: yyyy
  sections: {
    snake case section name string: {
      label: string,
      subsections: {
        snake case subsection name string: {
          label: string,
          pages: {
            snake case page name string: {
              header: string,
              description: string,
              questions: {
                snake case question name string: {
                  header: string,
                  hint_text: string,
                  type: [text / numeric / radio / checkbox / date ],
                  min: integer, (numeric only),
                  max: integer, (numeric only),
                  step: integer (numeric only),
                  answer_options: { (checkbox and radio only)
                    "0": string,
                    "1": string
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

Assumptions made by the format:

- All forms have at least 1 section
- All sections have at least 1 subsection
- All subsections have at least 1 page
- All pages have at least 1 question
- The ActiveRecord case log model has a field for each question name (must match)
- Text not required by a page/question such as a header or hint text should be passed as an empty string
