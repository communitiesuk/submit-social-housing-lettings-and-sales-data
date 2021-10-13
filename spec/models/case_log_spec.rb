require "rails_helper"

RSpec.describe Form, type: :model do
  describe "#new" do
    it "validates age is under 120" do
      expect { CaseLog.create!(tenant_age: 121) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
