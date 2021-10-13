require "rails_helper"

RSpec.describe Form, type: :model do
  describe "#new" do
    it "validates age is a number" do
      expect { CaseLog.create!(tenant_age: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is under 120" do
      expect { CaseLog.create!(tenant_age: 121) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is over 0" do
      expect { CaseLog.create!(tenant_age: 0) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
