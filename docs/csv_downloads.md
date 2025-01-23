---
nav_order: 10
---
# CSV Downloads

The CSV download functionality allows users to download various types of data from the service. This documentation provides an overview of how CSV downloads work, the different types of downloads available, and common development tasks related to CSV downloads.

## How CSV Downloads Work

CSV downloads are generated based on the data accessible to the user in the service. Sales and lettings data must be downloaded for a specific year due to differences in templates and collected data.

When a download is requested:
1. The request is queued using **Sidekiq** and processed in the background.
2. The generated CSV file is stored in an **S3 bucket**.
3. Users receive an email with a link to the service, where they can download the file via a **presigned URL**, valid for 2 days.

## Available Types of CSV Downloads

### For Support Users
Support users can download the following data:
- **Lettings Logs**: Either *labels* or *codes* version, one download per specific year.
- **Sales Logs**: Either *labels* or *codes* version, one download per specific year.
- **Schemes**
- **Locations**
- **Combined Schemes and Locations**: Contains the same data as above, but joined.
- **Users**

### For Non-Support Users
Non-support users can download:
- **Lettings Logs**: Logs owned or managed by their organisation (or merged organisations) in the *labels* version only. One download per specific year.
- **Sales Logs**: Logs owned or reported by their organisation (or merged organisations) in the *labels* version only. One download per specific year.
- **Schemes**: Available to their organisation.
- **Locations**: Available to their organisation.
- **Combined Schemes and Locations**: Available to their organisation.

### Applying Filters
Users can download a subset of this data by applying filters and search. **Year filter** is mandatory for logs downloads.

---

## Labels vs. Codes in CSV Downloads

### Labels
Labels represent the verbal answer options displayed in the service.

For a lettings log `reason` field with the data `"4" => { "value" => "Loss of tied accommodation" }`, the value in the *labels* version would be `Loss of tied accommodation`.

### Codes
_Codes only_ exports use integers where possible as field values.

For the same `reason` field above, the value in the codes CSV download version would be `4`.

The integers for _codes only_ export should correspond to the numbers in bulk upload specification and CDS export.

Most of the codes saved internally align with the values exported, meaning the exported codes are typically identical to their internal representations. 

In cases where internal values differ from the expected export format, such as the `rent_type` field (exported under the `renttype_detail` header), the values are mapped to the expected format directly in the CSV export service. In this case, the mapping is handled in the `renttype_detail_code` method.

### Things to note
- **Some fields are always exported as codes**: Such as `la`.
- **Some fields are always exported as labels**: Such as `la_label`.
- **Mapping**: For fields where internal values don’t match export requirements (e.g., `rent_type` - exported as `renttype_detail`), mappings are applied directly in the CSV export service.
- For fields without corresponding codes (e.g., `tenancycode`), the *codes* version will have the same value as the *labels* version.

---

## Common Development Tasks

### 1. Adding New Columns

- **Logs (Lettings/Sales)**: 
  - By default all of the question fields from the specific form will be exported in the CSV download, unless they're manually removed in the `lettings_log_attributes` or `sales_log_attributes` method. 
  - Update `lettings_log_attributes` or `sales_log_attributes` methods to add or remove fields.
- **Schemes/Locations**: 
  - Exported scheme/location CSV fields are hardcoded in `scheme_attributes` and `location_attributes`. Update `scheme_attributes` or `location_attributes` methods to add or remove fields.
- **Users**: 
  - Users CSV download is generated in users model `self.to_csv` and exported attributes are defined in `self.download_attributes`. Modify the `self.download_attributes` method in the `User` model to add or remove fields.

### 2. Reordering Columns
- **Logs (Lettings/Sales)**: 
  - Logs download question order coresponds to the order of the questions in the form flow and any additional ordering is applied in the `lettings_log_attributes` or `sales_log_attributes` methods.
  - Modify the order in `lettings_log_attributes` or `sales_log_attributes` to update field order.
- **Schemes/Locations**: 
  - Adjust order in `scheme_attributes` or `location_attributes`.
- **Users**: 
  - Update column order in `self.download_attributes`.

### 3. Populating CSV Variable Definitions
CSV variable definitions describe each header in the logs downloads.
Definitions are saved in a `csv_variable_definitions` table and have been populated with initial values on production. The definitions are expected to be updated manually from `/admin` page when an update is needed, this is so that the definitions could be updated by support users.

To populate initial CSV variable definitions locally or on a review app run `data_import:add_variable_definitions` rake task with the path to one of the variable definitions in `config/csv/definitions`

```
rake data_import:add_variable_definitions\[config/csv/definitions/lettings_download_24_25.csv\]
```

## Viewing and Updating CSV variable definitions
To locate the CSV variable definitions:
- Log in as a support user
- Navigate to the admin page of the app `<base_url>/admin`
- Select `CSV Variable Definitions` table

A list of all the CSV variable definitions for logs download should be displayed and can be edited directly from here. Editing these would have an instant effect, so it might be worth trying it on staging environments first.
