# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_13_105230) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bulk_upload_errors", force: :cascade do |t|
    t.bigint "bulk_upload_id"
    t.text "category"
    t.text "cell"
    t.text "col"
    t.datetime "created_at", null: false
    t.text "error"
    t.text "field"
    t.text "property_ref"
    t.text "purchaser_code"
    t.text "row"
    t.text "tenant_code"
    t.datetime "updated_at", null: false
    t.index ["bulk_upload_id"], name: "index_bulk_upload_errors_on_bulk_upload_id"
  end

  create_table "bulk_uploads", force: :cascade do |t|
    t.text "choice"
    t.datetime "created_at", null: false
    t.string "failure_reason"
    t.text "filename"
    t.uuid "identifier", null: false
    t.text "log_type", null: false
    t.integer "moved_user_id"
    t.integer "needstype"
    t.integer "organisation_id"
    t.boolean "processing"
    t.string "rent_type_fix_status", default: "not_applied"
    t.integer "total_logs_count"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "year", null: false
    t.index ["identifier"], name: "index_bulk_uploads_on_identifier", unique: true
    t.index ["user_id"], name: "index_bulk_uploads_on_user_id"
  end

  create_table "collection_resources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "display_name"
    t.string "download_filename"
    t.string "log_type"
    t.boolean "mandatory"
    t.boolean "released_to_user"
    t.string "resource_type"
    t.string "short_display_name"
    t.datetime "updated_at", null: false
    t.integer "year"
  end

  create_table "csv_downloads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "download_type"
    t.integer "expiration_time"
    t.string "filename"
    t.bigint "organisation_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["organisation_id"], name: "index_csv_downloads_on_organisation_id"
    t.index ["user_id"], name: "index_csv_downloads_on_user_id"
  end

  create_table "csv_variable_definitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "definition", null: false
    t.datetime "last_accessed"
    t.string "log_type", null: false
    t.datetime "updated_at", null: false
    t.string "variable", null: false
    t.integer "year", null: false
    t.check_constraint "log_type::text = ANY (ARRAY['lettings'::character varying, 'sales'::character varying]::text[])", name: "log_type_check"
    t.check_constraint "year >= 2000 AND year <= 2099", name: "year_check"
  end

  create_table "data_protection_confirmations", force: :cascade do |t|
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.string "data_protection_officer_email"
    t.bigint "data_protection_officer_id"
    t.string "data_protection_officer_name"
    t.string "old_id"
    t.string "old_org_id"
    t.string "organisation_address"
    t.bigint "organisation_id"
    t.string "organisation_name"
    t.string "organisation_phone_number"
    t.datetime "signed_at"
    t.datetime "updated_at", null: false
    t.index ["data_protection_officer_id"], name: "dpo_user_id"
    t.index ["organisation_id"], name: "index_data_protection_confirmations_on_organisation_id"
  end

  create_table "download_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "download_filters", null: false
    t.integer "download_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "user_organisation_id", null: false
    t.integer "user_role"
    t.index ["user_id"], name: "index_download_records_on_user_id"
    t.index ["user_organisation_id"], name: "index_download_records_on_user_organisation_id"
  end

  create_table "exports", force: :cascade do |t|
    t.integer "base_number", default: 1, null: false
    t.string "collection"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "empty_export", default: false, null: false
    t.integer "increment_number", default: 1, null: false
    t.datetime "started_at", null: false
    t.integer "year"
  end

  create_table "la_rent_ranges", force: :cascade do |t|
    t.integer "beds"
    t.datetime "created_at", null: false
    t.decimal "hard_max", precision: 10, scale: 2
    t.decimal "hard_min", precision: 10, scale: 2
    t.string "la"
    t.integer "lettype"
    t.integer "ranges_rent_id"
    t.decimal "soft_max", precision: 10, scale: 2
    t.decimal "soft_min", precision: 10, scale: 2
    t.integer "start_year"
    t.datetime "updated_at", null: false
    t.index ["start_year", "lettype", "beds", "la"], name: "index_la_rent_ranges_on_start_year_and_lettype_and_beds_and_la", unique: true
  end

  create_table "la_sale_ranges", force: :cascade do |t|
    t.integer "bedrooms"
    t.datetime "created_at", null: false
    t.string "la"
    t.decimal "soft_max", precision: 10, scale: 2
    t.decimal "soft_min", precision: 10, scale: 2
    t.integer "start_year"
    t.datetime "updated_at", null: false
    t.index ["start_year", "bedrooms", "la"], name: "index_la_sale_ranges_on_start_year_bedrooms_la", unique: true
  end

  create_table "legacy_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "old_user_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["old_user_id"], name: "index_legacy_users_on_old_user_id", unique: true
  end

  create_table "lettings_logs", force: :cascade do |t|
    t.integer "accessible_register"
    t.string "address_line1"
    t.string "address_line1_as_entered"
    t.string "address_line1_input"
    t.string "address_line2"
    t.string "address_line2_as_entered"
    t.integer "address_search_value_check"
    t.integer "age1"
    t.integer "age1_known"
    t.integer "age2"
    t.integer "age2_known"
    t.integer "age3"
    t.integer "age3_known"
    t.integer "age4"
    t.integer "age4_known"
    t.integer "age5"
    t.integer "age5_known"
    t.integer "age6"
    t.integer "age6_known"
    t.integer "age7"
    t.integer "age7_known"
    t.integer "age8"
    t.integer "age8_known"
    t.integer "armedforces"
    t.bigint "assigned_to_id"
    t.integer "beds"
    t.integer "benefits"
    t.decimal "brent", precision: 10, scale: 2
    t.integer "builtype"
    t.bigint "bulk_upload_id"
    t.integer "cap"
    t.integer "carehome_charges_value_check"
    t.integer "cbl"
    t.decimal "chcharge", precision: 10, scale: 2
    t.integer "chr"
    t.string "county"
    t.string "county_as_entered"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "creation_method", default: 1
    t.integer "declaration"
    t.integer "details_known_2"
    t.integer "details_known_3"
    t.integer "details_known_4"
    t.integer "details_known_5"
    t.integer "details_known_6"
    t.integer "details_known_7"
    t.integer "details_known_8"
    t.datetime "discarded_at"
    t.integer "duplicate_set_id"
    t.integer "earnings"
    t.integer "ecstat1"
    t.integer "ecstat2"
    t.integer "ecstat3"
    t.integer "ecstat4"
    t.integer "ecstat5"
    t.integer "ecstat6"
    t.integer "ecstat7"
    t.integer "ecstat8"
    t.integer "ethnic"
    t.integer "ethnic_group"
    t.integer "first_time_property_let_as_social_housing"
    t.string "gender_description1"
    t.string "gender_description2"
    t.string "gender_description3"
    t.string "gender_description4"
    t.string "gender_description5"
    t.string "gender_description6"
    t.string "gender_description7"
    t.string "gender_description8"
    t.integer "gender_same_as_sex1"
    t.integer "gender_same_as_sex2"
    t.integer "gender_same_as_sex3"
    t.integer "gender_same_as_sex4"
    t.integer "gender_same_as_sex5"
    t.integer "gender_same_as_sex6"
    t.integer "gender_same_as_sex7"
    t.integer "gender_same_as_sex8"
    t.integer "has_benefits"
    t.integer "hb"
    t.integer "hbrentshortfall"
    t.integer "hhmemb"
    t.integer "hhtype"
    t.integer "homeless"
    t.integer "household_charge"
    t.integer "housingneeds"
    t.integer "housingneeds_a"
    t.integer "housingneeds_b"
    t.integer "housingneeds_c"
    t.integer "housingneeds_f"
    t.integer "housingneeds_g"
    t.integer "housingneeds_h"
    t.integer "housingneeds_other"
    t.integer "housingneeds_type"
    t.integer "illness"
    t.integer "illness_type_1"
    t.integer "illness_type_10"
    t.integer "illness_type_2"
    t.integer "illness_type_3"
    t.integer "illness_type_4"
    t.integer "illness_type_5"
    t.integer "illness_type_6"
    t.integer "illness_type_7"
    t.integer "illness_type_8"
    t.integer "illness_type_9"
    t.integer "incfreq"
    t.integer "incref"
    t.integer "irproduct"
    t.string "irproduct_other"
    t.integer "is_carehome"
    t.boolean "is_la_inferred"
    t.boolean "is_previous_la_inferred"
    t.integer "joint"
    t.string "la"
    t.string "la_as_entered"
    t.integer "lar"
    t.integer "layear"
    t.integer "leftreg"
    t.integer "letting_allocation_unknown"
    t.integer "lettype"
    t.bigint "location_id"
    t.integer "major_repairs_date_value_check"
    t.integer "majorrepairs"
    t.bigint "managing_organisation_id"
    t.boolean "manual_address_entry_selected", default: false
    t.datetime "mrcdate", precision: nil
    t.integer "multiple_partners_value_check"
    t.integer "national"
    t.integer "nationality_all"
    t.integer "nationality_all_group"
    t.integer "needstype"
    t.integer "net_income_known"
    t.integer "net_income_value_check"
    t.integer "new_old"
    t.integer "newprop"
    t.integer "nocharge"
    t.integer "offered"
    t.integer "old_form_id"
    t.string "old_id"
    t.bigint "owning_organisation_id"
    t.integer "partner_under_16_value_check"
    t.integer "period"
    t.string "postcode_full"
    t.string "postcode_full_as_entered"
    t.string "postcode_full_input"
    t.integer "postcode_known"
    t.integer "ppcodenk"
    t.string "ppostcode_full"
    t.integer "preg_occ"
    t.integer "pregnancy_value_check"
    t.integer "previous_la_known"
    t.string "prevloc"
    t.integer "prevten"
    t.string "propcode"
    t.string "property_manager_organisation"
    t.string "property_owner_organisation"
    t.integer "property_relet"
    t.decimal "pscharge", precision: 10, scale: 2
    t.integer "pscharge_value_check"
    t.string "purchaser_code"
    t.integer "reason"
    t.string "reasonother"
    t.integer "reasonother_value_check"
    t.integer "reasonpref"
    t.integer "referral"
    t.integer "referral_noms"
    t.integer "referral_org"
    t.integer "referral_register"
    t.integer "referral_type"
    t.integer "referral_value_check"
    t.integer "refused"
    t.string "relat2"
    t.string "relat3"
    t.string "relat4"
    t.string "relat5"
    t.string "relat6"
    t.string "relat7"
    t.string "relat8"
    t.integer "renewal"
    t.integer "rent_type"
    t.integer "rent_value_check"
    t.integer "renttype"
    t.integer "reservist"
    t.integer "retirement_value_check"
    t.integer "rp_dontknow"
    t.integer "rp_hardship"
    t.integer "rp_homeless"
    t.integer "rp_insan_unsat"
    t.integer "rp_medwel"
    t.integer "rsnvac"
    t.decimal "scharge", precision: 10, scale: 2
    t.integer "scharge_value_check"
    t.bigint "scheme_id"
    t.string "sex1"
    t.string "sex2"
    t.string "sex3"
    t.string "sex4"
    t.string "sex5"
    t.string "sex6"
    t.string "sex7"
    t.string "sex8"
    t.string "sexrab1"
    t.string "sexrab2"
    t.string "sexrab3"
    t.string "sexrab4"
    t.string "sexrab5"
    t.string "sexrab6"
    t.string "sexrab7"
    t.string "sexrab8"
    t.integer "sheltered"
    t.datetime "startdate", precision: nil
    t.integer "startertenancy"
    t.integer "status", default: 0
    t.integer "status_cache", default: 0, null: false
    t.decimal "supcharg", precision: 10, scale: 2
    t.integer "supcharg_value_check"
    t.decimal "tcharge", precision: 10, scale: 2
    t.integer "tenancy"
    t.string "tenancycode"
    t.integer "tenancylength"
    t.string "tenancyother"
    t.integer "tenancyother_value_check"
    t.integer "totadult"
    t.integer "totchild"
    t.integer "totelder"
    t.string "town_or_city"
    t.string "town_or_city_as_entered"
    t.decimal "tshortfall", precision: 10, scale: 2
    t.integer "tshortfall_known"
    t.integer "underoccupation_benefitcap"
    t.integer "unitletas"
    t.integer "unittype_gn"
    t.boolean "unresolved"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.string "uprn"
    t.integer "uprn_confirmed"
    t.integer "uprn_known"
    t.string "uprn_selection"
    t.integer "vacdays"
    t.datetime "values_updated_at"
    t.integer "void_date_value_check"
    t.datetime "voiddate", precision: nil
    t.integer "waityear"
    t.integer "wchair"
    t.decimal "wchchrg", precision: 10, scale: 2
    t.integer "working_situation_illness_check"
    t.decimal "wpschrge", precision: 10, scale: 2
    t.decimal "wrent", precision: 10, scale: 2
    t.decimal "wscharge", precision: 10, scale: 2
    t.decimal "wsupchrg", precision: 10, scale: 2
    t.decimal "wtcharge", precision: 10, scale: 2
    t.decimal "wtshortfall", precision: 10, scale: 2
    t.index ["assigned_to_id"], name: "index_lettings_logs_on_assigned_to_id"
    t.index ["bulk_upload_id"], name: "index_lettings_logs_on_bulk_upload_id"
    t.index ["created_by_id"], name: "index_lettings_logs_on_created_by_id"
    t.index ["location_id"], name: "index_lettings_logs_on_location_id"
    t.index ["managing_organisation_id", "id"], name: "index_lettings_logs_on_managing_org_and_id_desc", order: { id: :desc }
    t.index ["managing_organisation_id"], name: "index_lettings_logs_on_managing_organisation_id"
    t.index ["old_id"], name: "index_lettings_logs_on_old_id", unique: true
    t.index ["owning_organisation_id", "id"], name: "index_lettings_logs_on_owning_org_and_id_desc", order: { id: :desc }
    t.index ["owning_organisation_id"], name: "index_lettings_logs_on_owning_organisation_id"
    t.index ["scheme_id"], name: "index_lettings_logs_on_scheme_id"
    t.index ["updated_by_id"], name: "index_lettings_logs_on_updated_by_id"
  end

  create_table "local_authorities", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "end_date"
    t.string "name", null: false
    t.datetime "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_local_authority_code", unique: true
  end

  create_table "local_authority_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "linked_local_authority_id"
    t.bigint "local_authority_id"
    t.datetime "updated_at", null: false
    t.index ["linked_local_authority_id"], name: "index_local_authority_links_on_linked_local_authority_id"
    t.index ["local_authority_id"], name: "index_local_authority_links_on_local_authority_id"
  end

  create_table "location_deactivation_periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivation_date"
    t.bigint "location_id"
    t.datetime "reactivation_date"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_location_deactivation_periods_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "is_la_inferred"
    t.string "location_admin_district"
    t.string "location_code"
    t.string "mobility_type"
    t.string "name"
    t.string "old_id"
    t.string "old_visible_id"
    t.string "postcode"
    t.bigint "scheme_id", null: false
    t.datetime "startdate"
    t.integer "type_of_unit"
    t.integer "units"
    t.datetime "updated_at", null: false
    t.index ["old_id"], name: "index_locations_on_old_id", unique: true
    t.index ["scheme_id"], name: "index_locations_on_scheme_id"
  end

  create_table "log_validations", force: :cascade do |t|
    t.boolean "bulk_upload_specific", default: false
    t.string "case"
    t.boolean "checked"
    t.string "collection_year"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "error_message"
    t.string "field"
    t.datetime "from"
    t.string "hard_soft"
    t.string "log_type"
    t.string "other_validated_models"
    t.string "section"
    t.datetime "to"
    t.datetime "updated_at", null: false
    t.string "validation_name"
    t.string "validation_type"
  end

  create_table "merge_request_organisations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "merge_request_id"
    t.integer "merging_organisation_id"
    t.datetime "updated_at", null: false
  end

  create_table "merge_requests", force: :cascade do |t|
    t.integer "absorbing_organisation_id"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "existing_absorbing_organisation"
    t.boolean "has_helpdesk_ticket"
    t.string "helpdesk_ticket"
    t.datetime "last_failed_attempt"
    t.datetime "merge_date"
    t.boolean "processing"
    t.boolean "request_merged"
    t.integer "requester_id"
    t.integer "requesting_organisation_id"
    t.boolean "signed_dsa", default: false
    t.integer "total_lettings_logs"
    t.integer "total_managing_agents"
    t.integer "total_sales_logs"
    t.integer "total_schemes"
    t.integer "total_stock_owners"
    t.integer "total_users"
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_date"
    t.string "link_text"
    t.string "page_content"
    t.boolean "show_additional_page"
    t.boolean "show_on_unauthenticated_pages"
    t.datetime "start_date"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "organisation_name_changes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "discarded_at"
    t.string "name", null: false
    t.bigint "organisation_id", null: false
    t.date "startdate", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id", "startdate", "discarded_at"], name: "index_org_name_changes_on_org_id_startdate_discarded_at", unique: true
    t.index ["organisation_id"], name: "index_organisation_name_changes_on_organisation_id"
  end

  create_table "organisation_relationships", force: :cascade do |t|
    t.integer "child_organisation_id"
    t.datetime "created_at", null: false
    t.integer "parent_organisation_id"
    t.datetime "updated_at", null: false
    t.index ["child_organisation_id"], name: "index_organisation_relationships_on_child_organisation_id"
    t.index ["parent_organisation_id", "child_organisation_id"], name: "index_org_rel_parent_child_uniq", unique: true
    t.index ["parent_organisation_id"], name: "index_organisation_relationships_on_parent_organisation_id"
  end

  create_table "organisation_rent_periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organisation_id"
    t.integer "rent_period"
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_organisation_rent_periods_on_organisation_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.bigint "absorbing_organisation_id"
    t.boolean "active", default: true
    t.string "address_line1"
    t.string "address_line2"
    t.datetime "available_from"
    t.integer "cbl_proportion_percentage"
    t.boolean "choice_allocation_policy"
    t.boolean "choice_based_lettings"
    t.boolean "common_housing_register"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "enter_affordable_logs"
    t.integer "general_needs_units"
    t.integer "group"
    t.boolean "group_member"
    t.integer "group_member_id"
    t.boolean "holds_own_stock"
    t.string "housing_management_system"
    t.string "housing_registration_no"
    t.string "managing_agents_label"
    t.datetime "merge_date"
    t.string "name"
    t.integer "old_association_type"
    t.string "old_org_id"
    t.string "old_visible_id"
    t.string "other_stock_owners"
    t.boolean "owns_affordable_logs"
    t.string "phone"
    t.string "postcode"
    t.integer "profit_status"
    t.integer "provider_type"
    t.datetime "schemes_deduplicated_at"
    t.string "software_supplier_id"
    t.integer "supported_housing_units"
    t.integer "unspecified_units"
    t.datetime "updated_at", null: false
    t.index ["absorbing_organisation_id"], name: "index_organisations_on_absorbing_organisation_id"
    t.index ["name"], name: "index_organisations_on_name", unique: true
    t.index ["old_visible_id"], name: "index_organisations_on_old_visible_id", unique: true
  end

  create_table "read_marks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "readable_id"
    t.string "readable_type", null: false
    t.bigint "reader_id"
    t.string "reader_type", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.datetime "updated_at", null: false
    t.index ["readable_type", "readable_id"], name: "index_read_marks_on_readable_type_and_readable_id"
    t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", unique: true
    t.index ["reader_type", "reader_id"], name: "index_read_marks_on_reader_type_and_reader_id"
  end

  create_table "sales_logs", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line1_as_entered"
    t.string "address_line1_input"
    t.string "address_line2"
    t.string "address_line2_as_entered"
    t.integer "address_search_value_check"
    t.integer "age1"
    t.integer "age1_known"
    t.integer "age2"
    t.integer "age2_known"
    t.integer "age3"
    t.integer "age3_known"
    t.integer "age4"
    t.integer "age4_known"
    t.integer "age5"
    t.integer "age5_known"
    t.integer "age6"
    t.integer "age6_known"
    t.integer "armedforcesspouse"
    t.bigint "assigned_to_id"
    t.integer "beds"
    t.integer "buildheightclass"
    t.integer "builtype"
    t.bigint "bulk_upload_id"
    t.integer "buy1livein"
    t.integer "buy2livein"
    t.integer "buy2living"
    t.integer "buyer_livein_value_check"
    t.integer "buylivein"
    t.decimal "cashdis", precision: 10, scale: 2
    t.integer "combined_income_value_check"
    t.integer "companybuy"
    t.string "county"
    t.string "county_as_entered"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "creation_method", default: 1
    t.decimal "deposit", precision: 10, scale: 2
    t.integer "deposit_and_mortgage_value_check"
    t.integer "deposit_value_check"
    t.integer "details_known_2"
    t.integer "details_known_3"
    t.integer "details_known_4"
    t.integer "details_known_5"
    t.integer "details_known_6"
    t.integer "disabled"
    t.datetime "discarded_at"
    t.decimal "discount", precision: 10, scale: 2
    t.integer "discounted_sale_value_check"
    t.integer "duplicate_set_id"
    t.integer "ecstat1"
    t.integer "ecstat2"
    t.integer "ecstat3"
    t.integer "ecstat4"
    t.integer "ecstat5"
    t.integer "ecstat6"
    t.decimal "equity", precision: 10, scale: 2
    t.integer "ethnic"
    t.integer "ethnic_group"
    t.integer "ethnic_group2"
    t.integer "ethnicbuy2"
    t.datetime "exdate"
    t.integer "exday"
    t.integer "exmonth"
    t.integer "extrabor"
    t.integer "extrabor_value_check"
    t.integer "exyear"
    t.integer "firststair"
    t.integer "frombeds"
    t.integer "fromprop"
    t.string "gender_description1"
    t.string "gender_description2"
    t.string "gender_description3"
    t.string "gender_description4"
    t.string "gender_description5"
    t.string "gender_description6"
    t.integer "gender_same_as_sex1"
    t.integer "gender_same_as_sex2"
    t.integer "gender_same_as_sex3"
    t.integer "gender_same_as_sex4"
    t.integer "gender_same_as_sex5"
    t.integer "gender_same_as_sex6"
    t.decimal "grant", precision: 10, scale: 2
    t.integer "grant_value_check"
    t.integer "has_management_fee"
    t.integer "has_mscharge"
    t.integer "hasservicechargeschanged"
    t.integer "hb"
    t.integer "hhmemb"
    t.integer "hholdcount"
    t.integer "hhregres"
    t.integer "hhregresstill"
    t.integer "hhtype"
    t.datetime "hodate"
    t.integer "hodate_check"
    t.integer "hoday"
    t.integer "homonth"
    t.integer "hoyear"
    t.integer "inc1mort"
    t.integer "inc2mort"
    t.integer "income1"
    t.integer "income1_value_check"
    t.integer "income1nk"
    t.integer "income2"
    t.integer "income2_value_check"
    t.integer "income2nk"
    t.datetime "initialpurchase"
    t.boolean "is_la_inferred"
    t.boolean "is_previous_la_inferred"
    t.integer "jointmore"
    t.integer "jointpur"
    t.string "la"
    t.string "la_as_entered"
    t.integer "la_known"
    t.integer "lanomagr"
    t.datetime "lasttransaction"
    t.decimal "management_fee", precision: 10, scale: 2
    t.bigint "managing_organisation_id"
    t.boolean "manual_address_entry_selected", default: false
    t.integer "monthly_charges_value_check"
    t.decimal "mortgage", precision: 10, scale: 2
    t.integer "mortgage_value_check"
    t.integer "mortgagelender"
    t.string "mortgagelenderother"
    t.integer "mortgageused"
    t.integer "mortlen"
    t.integer "mortlen_known"
    t.decimal "mrent", precision: 10, scale: 2
    t.decimal "mrentprestaircasing", precision: 10, scale: 2
    t.decimal "mscharge", precision: 10, scale: 2
    t.integer "multiple_partners_value_check"
    t.integer "national"
    t.integer "nationalbuy2"
    t.integer "nationality_all"
    t.integer "nationality_all_buyer2"
    t.integer "nationality_all_buyer2_group"
    t.integer "nationality_all_group"
    t.decimal "newservicecharges", precision: 10, scale: 2
    t.integer "noint"
    t.integer "numstair"
    t.integer "old_form_id"
    t.string "old_id"
    t.integer "old_persons_shared_ownership_value_check"
    t.string "othtype"
    t.integer "ownershipsch"
    t.bigint "owning_organisation_id"
    t.integer "partner_under_16_value_check"
    t.string "pcode1"
    t.string "pcode2"
    t.integer "pcodenk"
    t.integer "percentage_discount_value_check"
    t.string "postcode_full"
    t.string "postcode_full_as_entered"
    t.string "postcode_full_input"
    t.integer "ppcodenk"
    t.string "ppostc1"
    t.string "ppostc2"
    t.string "ppostcode_full"
    t.integer "pregblank"
    t.integer "pregghb"
    t.integer "pregla"
    t.integer "pregother"
    t.integer "pregyrha"
    t.integer "previous_la_known"
    t.string "prevloc"
    t.integer "prevown"
    t.integer "prevshared"
    t.integer "prevten"
    t.integer "prevtenbuy2"
    t.integer "privacynotice"
    t.integer "proplen"
    t.integer "proplen_asked"
    t.integer "proptype"
    t.string "purchid"
    t.string "relat2"
    t.string "relat3"
    t.string "relat4"
    t.string "relat5"
    t.string "relat6"
    t.integer "resale"
    t.integer "retirement_value_check"
    t.datetime "saledate"
    t.integer "saledate_check"
    t.integer "savings"
    t.integer "savings_value_check"
    t.integer "savingsnk"
    t.string "sex1"
    t.string "sex2"
    t.string "sex3"
    t.string "sex4"
    t.string "sex5"
    t.string "sex6"
    t.string "sexrab1"
    t.string "sexrab2"
    t.string "sexrab3"
    t.string "sexrab4"
    t.string "sexrab5"
    t.string "sexrab6"
    t.integer "shared_ownership_deposit_value_check"
    t.integer "socprevten"
    t.integer "soctenant"
    t.decimal "stairbought"
    t.integer "staircase"
    t.integer "staircase_bought_value_check"
    t.integer "staircasesale"
    t.decimal "stairowned"
    t.integer "stairowned_value_check"
    t.integer "status", default: 0
    t.integer "status_cache", default: 0, null: false
    t.integer "student_not_child_value_check"
    t.integer "totadult"
    t.integer "totchild"
    t.string "town_or_city"
    t.string "town_or_city_as_entered"
    t.integer "type"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.string "uprn"
    t.integer "uprn_confirmed"
    t.integer "uprn_known"
    t.string "uprn_selection"
    t.decimal "value", precision: 10, scale: 2
    t.integer "value_value_check"
    t.datetime "values_updated_at"
    t.integer "wchair"
    t.integer "wheel"
    t.integer "wheel_value_check"
    t.index ["assigned_to_id"], name: "index_sales_logs_on_assigned_to_id"
    t.index ["bulk_upload_id"], name: "index_sales_logs_on_bulk_upload_id"
    t.index ["created_by_id"], name: "index_sales_logs_on_created_by_id"
    t.index ["managing_organisation_id", "id"], name: "index_sales_logs_on_managing_org_and_id_desc", order: { id: :desc }
    t.index ["managing_organisation_id"], name: "index_sales_logs_on_managing_organisation_id"
    t.index ["old_id"], name: "index_sales_logs_on_old_id", unique: true
    t.index ["owning_organisation_id", "id"], name: "index_sales_logs_on_owning_org_and_id_desc", order: { id: :desc }
    t.index ["owning_organisation_id"], name: "index_sales_logs_on_owning_organisation_id"
    t.index ["updated_by_id"], name: "index_sales_logs_on_updated_by_id"
  end

  create_table "scheme_deactivation_periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivation_date"
    t.datetime "reactivation_date"
    t.bigint "scheme_id"
    t.datetime "updated_at", null: false
    t.index ["scheme_id"], name: "index_scheme_deactivation_periods_on_scheme_id"
  end

  create_table "schemes", force: :cascade do |t|
    t.string "arrangement_type"
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "end_date"
    t.integer "has_other_client_group"
    t.string "intended_stay"
    t.string "old_id"
    t.string "old_visible_id"
    t.bigint "owning_organisation_id", null: false
    t.string "primary_client_group"
    t.integer "registered_under_care_act"
    t.integer "scheme_type"
    t.string "secondary_client_group"
    t.integer "sensitive"
    t.string "service_name"
    t.datetime "startdate"
    t.integer "support_type"
    t.integer "total_units"
    t.datetime "updated_at", null: false
    t.index ["owning_organisation_id"], name: "index_schemes_on_owning_organisation_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at"
    t.datetime "discarded_at"
    t.string "email", default: "", null: false
    t.string "encrypted_otp_secret_key"
    t.string "encrypted_otp_secret_key_iv"
    t.string "encrypted_otp_secret_key_salt"
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0
    t.boolean "force_reset_password_on_confirmation", default: false
    t.boolean "initial_confirmation_sent"
    t.boolean "is_dpo", default: false
    t.boolean "is_key_contact", default: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name"
    t.string "old_user_id"
    t.bigint "organisation_id"
    t.string "phone"
    t.string "phone_extension"
    t.boolean "reactivate_with_organisation"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "role"
    t.integer "second_factor_attempts_count", default: 0
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "totp_timestamp", precision: nil
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.datetime "values_updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["encrypted_otp_secret_key"], name: "index_users_on_encrypted_otp_secret_key", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "download_records", "organisations", column: "user_organisation_id"
  add_foreign_key "download_records", "users"
  add_foreign_key "lettings_logs", "locations"
  add_foreign_key "lettings_logs", "organisations", column: "owning_organisation_id", on_delete: :cascade
  add_foreign_key "lettings_logs", "schemes"
  add_foreign_key "local_authority_links", "local_authorities"
  add_foreign_key "local_authority_links", "local_authorities", column: "linked_local_authority_id"
  add_foreign_key "locations", "schemes"
  add_foreign_key "organisation_name_changes", "organisations"
  add_foreign_key "organisation_relationships", "organisations", column: "child_organisation_id"
  add_foreign_key "organisation_relationships", "organisations", column: "parent_organisation_id"
  add_foreign_key "organisations", "organisations", column: "absorbing_organisation_id"
  add_foreign_key "sales_logs", "organisations", column: "owning_organisation_id", on_delete: :cascade
  add_foreign_key "schemes", "organisations", column: "owning_organisation_id", on_delete: :cascade
  add_foreign_key "users", "organisations", on_delete: :cascade
end
