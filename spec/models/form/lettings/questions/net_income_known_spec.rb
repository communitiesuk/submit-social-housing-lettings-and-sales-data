require "rails_helper"

RSpec.describe Form::Lettings::Questions::NetIncomeKnown do
  subject(:question) { described_class.new(nil, {}, nil) }

  describe "#id" do
    it "is net_income_known" do
      expect(question.id).to eql("net_income_known")
    end
  end

  describe "#type" do
    it "is radio" do
      expect(question.type).to eql("radio")
    end
  end
end
