require "rails_helper"

RSpec.describe Validations::LocalAuthorityValidations do
  subject(:local_auth_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::LocalAuthorityValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }


end
