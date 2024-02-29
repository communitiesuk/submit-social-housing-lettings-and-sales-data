module ChargesHelper
  CHARGE_MAXIMA_PER_WEEK = {
    scharge: {
      private_registered_provider: {
        general_needs: 800,
        supported_housing: 800,
      },
      local_authority: {
        general_needs: 500,
        supported_housing: 500,
      },
    },
    pscharge: {
      private_registered_provider: {
        general_needs: 700,
        supported_housing: 700,
      },
      local_authority: {
        general_needs: 200,
        supported_housing: 200,
      },
    },
    supcharg: {
      private_registered_provider: {
        general_needs: 800,
        supported_housing: 800,
      },
      local_authority: {
        general_needs: 200,
        supported_housing: 200,
      },
    },
  }.freeze

  PROVIDER_TYPE = { 1 => :local_authority, 2 => :private_registered_provider }.freeze
  NEEDSTYPE_VALUES = { 2 => :supported_housing, 1 => :general_needs }.freeze
  CHARGE_NAMES = { scharge: "service charge", pscharge: "personal service charge", supcharg: "support charge" }.freeze
end
