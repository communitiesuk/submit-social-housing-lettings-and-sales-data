module Exports::OrganisationExportConstants
  MAX_XML_RECORDS = 10_000

  EXPORT_FIELDS = Set[
   "id",
   "name",
   "phone",
   "provider_type",
   "address_line1",
   "address_line2",
   "postcode",
   "holds_own_stock",
   "housing_registration_no",
   "active",
   "old_org_id",
   "old_visible_id",
   "merge_date",
   "absorbing_organisation_id",
   "available_from",
   "deleted_at",
   "dsa_signed",
   "dsa_signed_at",
   "dpo_email",
   "profit_status",
   "group"
  ]
end
