module Exports::UserExportConstants
  MAX_XML_RECORDS = 10_000

  EXPORT_FIELDS = Set[
    "id",
    "email",
    "name",
    "phone",
    "organisation_id",
    "organisation_name",
    "role",
    "is_dpo",
    "is_key_contact",
    "active",
    "sign_in_count",
    "last_sign_in_at",
  ]
end
