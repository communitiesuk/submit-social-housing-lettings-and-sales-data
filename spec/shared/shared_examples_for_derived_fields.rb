require "rails_helper"

RSpec.shared_examples "shared examples for derived fields" do |log_type|
  describe "sets ethnic based on the value of ethnic_refused" do
    it "is set to 17 when ethnic_group is 17" do
      log = FactoryBot.build(log_type, ethnic_group: 17, ethnic: nil)

      expect { log.set_derived_fields! }.to change(log, :ethnic).from(nil).to(17)
    end

    it "is is not modified otherwise" do
      log = FactoryBot.build(log_type, ethnic_group: nil, ethnic: nil)

      expect { log.set_derived_fields! }.not_to change(log, :ethnic)
    end
  end
end
