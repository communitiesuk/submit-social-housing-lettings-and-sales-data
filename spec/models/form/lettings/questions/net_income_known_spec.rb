require "rails_helper"

RSpec.describe Form::Lettings::Questions::NetIncomeKnown do
  subject(:question) { described_class.new(nil, {}, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

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

  describe "#partial guidance" do
    it "is at the top" do
      expect(question.top_guidance?).to eq(true)
      expect(question.bottom_guidance?).to eq(false)
    end
  end
end
