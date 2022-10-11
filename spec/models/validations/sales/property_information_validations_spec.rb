require "rails_helper"

RSpec.describe Validations::Sales::PropertyInformationValidations do
  subject(:date_validator) { validator_class.new }

  describe "#validate_bedsit_has_one_room" do
    context "when property is bedsit" do
    end

    context "when property is not a bedsit" do
    end
  end
end
