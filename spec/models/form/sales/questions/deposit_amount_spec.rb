require "rails_helper"

RSpec.describe Form::Sales::Questions::DepositAmount, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1, optional:) }

  let(:optional) { false }
  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  context "when the ownership type is shared" do
    let(:log) { build(:sales_log, :completed, ownershipsch: 1, mortgageused: 2) }

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
end
