require "rails_helper"

RSpec.describe Form::Sales::Pages::PropertyWheelchairAccessible, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { instance_double(Form, start_year_2024_or_later?: true, start_date: current_collection_start_date) }
  let(:subsection) { instance_double(Form::Subsection, enabled?: true, form:) }
  let(:saledate) { current_collection_start_date }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[wchair])
  end

  it "has the correct id" do
    expect(page.id).to eq("property_wheelchair_accessible")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "with a staircasing log" do
    let(:form) { Form.new(nil, current_collection_start_year, [], "sales") }
    let(:log) { build(:sales_log, :shared_ownership_setup_complete, staircase: 1, saledate:) }

    it "is not routed to" do
      expect(page.routed_to?(log, nil)).to be false
    end
  end

  context "with a non-staircasing log" do
    let(:form) { Form.new(nil, current_collection_start_year, [], "sales") }
    let(:log) { build(:sales_log, :shared_ownership_setup_complete, staircase: 2, saledate:) }

    it "is routed to" do
      expect(page.routed_to?(log, nil)).to be true
    end
  end
end
