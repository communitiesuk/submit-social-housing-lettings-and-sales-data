require "rails_helper"

RSpec.describe Form::Sales::Questions::DepositAmount, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1, optional:) }

  let(:optional) { false }
  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  context "when the ownership type is shared" do
    let(:log) { create(:sales_log, :completed, ownershipsch: 1, mortgageused: 2) }

    it "is not marked as derived" do
      expect(question.derived?(log)).to be false
    end
  end

  context "when the ownership type is discounted for 2023" do
    let(:log) { build(:sales_log, :completed, ownershipsch: 2, mortgageused: 2, saledate: Time.zone.local(2024, 3, 1)) }

    it "is not marked as derived" do
      expect(question.derived?(log)).to be false
    end
  end

  context "when the ownership type is outright" do
    let(:log) { build(:sales_log, :outright_sale_setup_complete, mortgageused:) }

    context "when a mortgage is used" do
      let(:mortgageused) { 1 }

      it "is not marked as derived " do
        expect(question.derived?(log)).to be false
      end
    end

    context "when a mortgage is not used" do
      let(:mortgageused) { 2 }

      it "is marked as derived " do
        expect(question.derived?(log)).to be true
      end
    end

    context "when the mortgage use is unknown" do
      let(:mortgageused) { 3 }

      it "is marked as derived " do
        expect(question.derived?(log)).to be true
      end
    end
  end

  describe "hint text" do
    context "when optional is false" do
      let(:optional) { false }

      it "has the correct hint" do
        expect(question.hint_text).to eq("Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage. This excludes any grant or loan")
      end
    end

    context "when optional is true" do
      let(:optional) { true }

      it "has the correct hint" do
        expect(question.hint_text).to eq("Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage. This excludes any grant or loan. As this is a fully staircased sale this question is optional. If you do not have the information available click save and continue")
      end
    end
  end
end
