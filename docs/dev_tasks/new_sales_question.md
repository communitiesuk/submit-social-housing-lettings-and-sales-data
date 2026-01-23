---
parent: Common dev tasks
nav_order: 1
---

# New Sales Log Questions

Concerns adding a brand-new question to Sales Logs. This question will appear on the website as part of the Sales form and should be handled in Bulk Uploads.

Guide is up-to-date as of 2026.

## Basic checklist of tasks

### 1. Create a migration to add the new field to the database

This allows the answer to the new question to be saved.

You can create a new empty migration file from the terminal if you are in the root of the project:

```
bin/rails generate migration NameOfMigration
```

The new migration file will be saved in `db/migrate`.

Whilst the specifics will vary, the new migration file should look something like this:

```ruby
class AddSexRegisteredAtBirthToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    # Add a new column called "name" of type string to the sales_logs table
    change_table :sales_logs, bulk: true do |t|
      t.column :name, :string
    end
  end
end
```

See also: [Active record migrations](https://guides.rubyonrails.org/active_record_migrations.html)

### 2. Run the new migration

`bundle exec rake db:migrate`

This will update `schema.rb`. You should not edit `schema.rb` directly.

### 3. Create a new question class

This will define the question that gets rendered on the online form.

Existing question classes can be found in `app/models/form/sales/questions/`. Depending on the type of question (checkboxes, radio groups, free-text fields), there will almost certainly be an existing question class that you can refer to as a guide.

For example, if you need to create a new radio form, then you may want to copy `armed_forces.rb`.

See also: [Question]({% link form/question.md %})

### 4. Create a new page class

This creates the page that your new question will be rendered on.

Existing page classes can be found in `app/models/form/sales/pages`.

Usually there is only one question per page, but in some cases there may be multiple. It may not be necessary to create a new page if the new question is being added to an existing one.

See also: [Page]({% link form/page.md %})

### 5. Add new page to an existing subsection

Without this step, your new page will not be inserted into the form!

Subsections can be found in `app/models/form/sales/subsections`.

You will want to add your new page to the appropriate place in the list returned by `def pages`.

To make your new page only appear in the forms for the upcoming year, you wrap the page class in parentheses and add a conditional expression to the end, like so:

```ruby
(Form::Sales::Pages::SexRegisteredAtBirth1.new(nil, nil, self) if form.start_year_2026_or_later?),
```

### 6. Update the locale file

The locale files define some of the text for the new question, including hints and the question itself.

Locale files can be found in `config/locales/forms/<year>/sales/` and there is one locale file for each form subsection.

Copy the entry for an existing question and substitute in the text for your new one.

### 7. Include the new field in exports

The fields that get exported in CSVs and XMLs are defined in `app/services/exports/sales_log_export_constants.rb`.

If there is not a set for POST_<year>_EXPORT_FIELDS, create one. Add your new field to the current year's set.

You may also have to update the `sales_log_export_service.rb` to correctly filter the year-specific fields.

### 8. Update the bulk upload row parser

This will allow bulk upload files to save the new field to the database.

You can find the relevant file at `app/services/bulk_upload/sales/year<year>/row_parser.rb`.

You will need to add a new `field_XXX` for the new field. In total, update the following places:

- Add the new field to `QUESTIONS` with the text of the question.
- Add a new attribute alongside the existing ones neat the top of the file:
  ```ruby
    attribute :field_XXX, :type
  ```
- Add the new field to `field_mapping_for_errors` with the name of the field in the database.
- Add the new field to `attributes_for_log` with the name of the field in the database.

You may also have to add some additional validation rules in this file.

Validation for ensuring that the value uploaded is one of the permitted options is handled automatically, using the question class as the original source of truth.  

### 9. Update unit tests

Create new test files for any new classes you have created. Update any test files for files that you have edited.
