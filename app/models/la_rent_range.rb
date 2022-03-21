class LaRentRange < ApplicationRecord
  PROVIDER_TYPE = {
    "LA": 1,
    "HA": 2,
  }.freeze

  NEEDS_TYPE = {
    "General Needs": 1,
    "Supported Housing": 0,
  }.freeze

  enum provider_type: PROVIDER_TYPE
  enum needstype: NEEDS_TYPE
end
