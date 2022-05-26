module Exports::CaseLogExportConstants
  MAX_XML_RECORDS = 10_000
  LOG_ID_OFFSET = 300_000_000_000

  EXPORT_MODE = {
    xml: 1,
    csv: 2,
  }.freeze

  QUARTERS = {
    0 => "jan_mar",
    1 => "apr_jun",
    2 => "jul_sep",
    3 => "oct_dec",
  }.freeze

  EXPORT_FIELDS = Set[
    "armedforces",
    "beds",
    "benefits",
    "brent",
    "builtype",
    "cap",
    "cbl",
    "chcharge",
    "chr",
    "cligrp1",
    "cligrp2",
    "createddate", # New metadata coming from our system
    "confidential",
    "earnings",
    "ethnic",
    "form",
    "has_benefits",
    "hb",
    "hbrentshortfall",
    "hcnum",
    "hhmemb",
    "homeless",
    "housingneeds",
    "illness",
    "incfreq",
    "income",
    "incref",
    "intstay",
    "irproduct",
    "irproduct_other",
    "joint",
    "la",
    "lar",
    "layear",
    "leftreg",
    "lettype",
    "manhcnum",
    "maningorgid",
    "maningorgname",
    "mobstand",
    "mrcdate",
    "national",
    "needstype",
    "new_old",
    "newprop",
    "nocharge",
    "offered",
    "owningorgid",
    "owningorgname",
    "period",
    "postcode_full",
    "ppcodenk",
    "ppostcode_full",
    "preg_occ",
    "prevloc",
    "prevten",
    "propcode",
    "providertype",
    "pscharge",
    "reason",
    "reasonother",
    "reasonpref",
    "referral",
    "refused",
    "reghome",
    "renttype",
    "renewal",
    "reservist",
    "rp_dontknow",
    "rp_hardship",
    "rp_homeless",
    "rp_insan_unsat",
    "rp_medwel",
    "rsnvac",
    "scharge",
    "scheme",
    "schtype",
    "shelteredaccom",
    "startdate",
    "startertenancy",
    "supcharg",
    "support",
    "status", # New metadata coming from our system
    "tcharge",
    "tshortfall",
    "tenancy",
    "tenancycode",
    "tenancylength",
    "tenancyother",
    "totadult",
    "totchild",
    "totelder",
    "underoccupation_benefitcap",
    "unitletas",
    "units",
    "unittype_gn",
    "unittype_sh",
    "uploaddate",
    "username",
    "voiddate",
    "waityear",
    "wchair",
    "wchchrg",
    "wpschrge",
    "wrent",
    "wscharge",
    "wsupchrg",
    "wtcharge",
    "wtshortfall",
  ]

  (1..8).each do |index|
    EXPORT_FIELDS << "age#{index}"
    EXPORT_FIELDS << "ecstat#{index}"
    EXPORT_FIELDS << "sex#{index}"
  end
  (2..8).each do |index|
    EXPORT_FIELDS << "relat#{index}"
  end
  (1..10).each do |index|
    EXPORT_FIELDS << "illness_type_#{index}"
  end
  %w[a b c d e f g h].each do |letter|
    EXPORT_FIELDS << "housingneeds_#{letter}"
  end
end
