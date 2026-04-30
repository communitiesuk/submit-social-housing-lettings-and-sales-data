---
parent: Common dev tasks
nav_order: 1
---

# New Questions

Concerns adding a brand-new question to Lettings Logs or Sales Logs. This question will appear on the website as part of the form and should be handled in Bulk Uploads. It will be exported as either a CSV download for users or XML export for automated ingestion by downstream users.

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

Existing question classes can be found in `app/models/form/<log type>/questions/`. Depending on the type of question (checkboxes, radio groups, free-text fields), there will almost certainly be an existing question class that you can refer to as a guide.

For example, if you need to create a new radio form, then you may want to copy `armed_forces.rb`.

Sometimes a question will appear in multiple places in the form, or have multiple similar forms. Historically on CORE we'd make a different question class for each, but now we think it's more maintainable to add a small amount of logic to the question to make it dynamic.

See also: [Question]({% link form/question.md %})

### 4. Create a new page class

This creates the page that your new question will be rendered on.

Existing page classes can be found in `app/models/form/<log type>/pages`.

Usually there is only one question per page, but in some cases there may be multiple. It may not be necessary to create a new page if the new question is being added to an existing one.

See also: [Page]({% link form/page.md %})

### 5. Add new page to an existing subsection

Without this step, your new page will not be inserted into the form!

Subsections can be found in `app/models/form/<log type>/subsections`.

You will want to add your new page to the appropriate place in the list returned by `def pages`.

To make your new page only appear in the forms for the upcoming year, you wrap the page class in parentheses and add a conditional expression to the end, like so:

```ruby
(Form::Sales::Pages::SexRegisteredAtBirth1.new(nil, nil, self) if form.start_year_2026_or_later?),
```

Note: the `@id` attribute of a page is what will be displayed in the url when visiting it. It must be unique within a collection year (i.e. two pages in 25/26 cannot share an ID, but two pages in different collection years can share an ID).

Do not use a `depends_on` block for showing a page on a specific year.

### 6. Update the locale file

The locale files define some of the text for the new question, including hints and the question itself.

Locale files can be found in `config/locales/forms/<year>/<log type>/` and there is one locale file for each form subsection.

Copy the entry for an existing question and substitute in the text for your new one.

The locale config for a question by default is laid out like `en.forms.\<year>.\<form type>.\<subsection>.\<page id>`. We assume 1 question per page. If there is more than one question per page you will need to add these as subsections in the page locale and set up a custom <code>@copy_key</code> property in the constructor.

### 7. Add validations

Add validation methods to the appropriate file. For example `app/models/validations/<subsection>_validations.rb` or `app/models/validations/sales/<subsection>_validations.rb` for sales. Any method in these files with a name starting `validate` will be automatically called. Adding an error to the record (log) will show an error on the frontend and the BU.

An error is added by calling `record.errors.add :<question id>, I18n.t("validations.<validation key>")`. You'll need to add the key where appropriate to the relevant locale file inside `config/locales/validations/...`.

Make sure to add errors to all relevant question IDs that can trigger the error. Note that questions on CORE can be answered in any order and amended at will so you cannot make assumptions on order of questions answered. CORE uses the question ID to show the error to the user on the page. If you don't add errors to all relevant question IDs, the user will not see an error but not be able to submit.

### 8. Include the new field in exports

The fields that get exported in CSVs and XMLs are defined in `app/services/exports/\<log type>_log_export_constants.rb`.

If there is not a set for `YEAR_<year>_EXPORT_FIELDS`, create one. Add your new field to the current year's set.

You may also have to update the `<log type>_log_export_service.rb` to correctly filter the year-specific fields.

### 9. Update the bulk upload parser

This will allow bulk upload files to save the new field to the database.

You can find the relevant file at `app/services/bulk_upload/<log type>/year<year>/row_parser.rb`.

If doing this work during yearly rebuild, add this new field as the last field in the file. It's much easier to have a single task at the end to correct all the field numbers.

You will need to add a new `field_XXX` for the new field. In total, update the following places:

- Add the new field to `QUESTIONS` with the text of the question.
- Add a new attribute alongside the existing ones neat the top of the file:
  ```ruby
    attribute :field_XXX, :type
  ```
- Add the new field to `field_mapping_for_errors` with the name of the field in the database.
- Add the new field to `attributes_for_log` with the name of the field in the database.
- If the field needs to be case-insensitive, add to `CASE_INSENSITIVE_FIELDS`.

You may also have to add some additional validation rules in this file.

We should try and keep validations in the BU few, and leave to validations on the log which you set up earlier. Only add validation specific to the csv format. For instance, validating the input format where we allow "R".

Validation for ensuring that the value uploaded is one of the permitted options is handled automatically, using the question class as the original source of truth.

Make sure that if a value fails a BU validation, then a valid value is not written to the log in the `attributes_for_log` method. If a BU produces a log that is 'complete', all errors will be ignored. Errors on fields the log considers 'valid' are ignored. So, you must make sure the log is incomplete for the user to see the error report. Normally you'll do this intuitively as invalid fields will mean you won't have a valid value.

You'll also need to update the field count in `app/services/bulk_upload/<log type>/year<year>/csv_parser.rb`, as well as the `cols` method.

### 10. Update unit tests

- Create new test files for any new classes you have created. Update any test files for files that you have edited.
- Update `spec/fixtures/variable_definitions/sales_download_25_26.csv` (for sales/lettings and for the relevant collection year) with the new question's field name and definition.

### 11. Update factory file

In `spec/factories` there are a series of factory files. These generate populated objects for use in tests. We also use them on CORE for the buttons that generate completed logs.

You will need to update the factory file for the relevant log type to include the new field. Don't worry about gating it to be year specific, old year questions will be ignored.

### 12. Update reference example BU file

In `spec/fixtures/files` we keep a sample BU file for a range of years and both log types. This gives us a fixed reference for a valid BU file. Make sure to update this and test that you can upload it locally.

### 13. Update auto generated example BU file

In the `app/helpers_bulk_upload/<log type>_log_to_csv.rb` file we maintain functions that convert a log into a BU file. This is used by tests and by the button on CORE to download an example BU file.

Make sure that this file is updated to include the new field in the relevant `to_<year>_row` method. You don't need to update the field numbers.

If you're adding a new method for this year, copy paste the previous year's row method. This'll avoid some nasty merge conflicts down the line.

Make sure you can download this test file and then upload it again.

### 14. Check the CSV download service

Users are able to download CSV exports of logs. This is handled by `app/services/csv/<log type>_log_csv_service.rb`. It should automatically include the new field, but worth checking locally that you're happy with both the codes and labels download.

### 15. Add test CSV export definitions

In `spec/fixtures/variable_definitions` there are a series of CSV files that define the names of fields. These are normally set in the UI by CORE but to make our tests more authentic we maintain labels for use in the tests.

If making one for the new year, just add a new file in that folder. The CSV export tests will pick it up automatically.

### 16. Check log export service

We export an XML representation of all logs made that day nightly. This is handled by `app/services/exports/<log type>_log_export_service.rb`. It should automatically include the new field, though make sure the spec file for this service passes. You will need to update `apply_cds_transformation` if the column name requested in the export doesn't match the database.
