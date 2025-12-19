---
nav_order: 12
---

# Bulk Upload

Bulk upload functionality allows users to upload multiple logs using a csv file.

## How Bulk Upload works

Bulk upload file can be uploaded for a specific log type (sales or lettings) for a specific year. During crossover period we ask which collection year the file is for, otherwise we assume the Bulk Upload is for the current year.

When a bulk upload file is successfully uploaded on the service, it:

- Saves a BulkUpload record in the database
- Uploads the file to S3
- Schedules `ProcessBulkUploadJob`

### Bulk upload service

There are several outcomes to a bulk upload:

- Successful upload
- Partial upload: upload has errors but partial logs can be created. Email to error report is sent to the user and the bulk upload needs a user approval
- Errors in bulk upload: errors on important fields, or in the template. Logs can't be created and an email with errors (or a link to error report) is sent to the user

![Bulk Upload Flow](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/bu_flow_diagram.png)

### Bulk upload processing

Most of BU processing logic is in `BulkUpload::Processor`. It chooses the correct `Validator` and `LogCreator` classes for the log type and uses them to process the file.

![Bulk Upload Processing](https://raw.githubusercontent.com/communitiesuk/submit-social-housing-lettings-and-sales-data/main/docs/images/bu_processor.png)

Main differences between different collection years would be in `CsvParsers` and `RowParsers`.

#### Row parser

- Maps any values from a csv row into values saved internally
- Maps any validations into errors for bulk uploads by associating them with relevant fields
- Adds any additional validations that might only make sense in BU (for example, validation that might not relevant in single log submission due to routing)

### Csv parser

- Holds template specific information
  - Header information
  - Row and field information
