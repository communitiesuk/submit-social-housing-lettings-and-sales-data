require "rails_helper"

RSpec.describe Form::Sales::Pages::PropertyBuildingType, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { instance_double(Form) }
  let(:subsection) { instance_double(Form::Subsection, enabled?: true, form:) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[builtype])
  end

  it "has the correct id" do
    expect(page.id).to eq("property_building_type")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "with form year 2024" do
    let(:form) { Form.new(nil, 2024, [], "sales") }
    let(:saledate) { Time.zone.local(2024, 4, 1) }

    context "with a staircasing log" do
      let(:log) { build(:sales_log, :shared_ownership_setup_complete, staircase: 1, saledate:) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to be true
      end
    end

    context "with a non-staircasing log" do
      let(:log) { build(:sales_log, staircase: nil, saledate:) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to be true
      end
    end
  end

  context "with form year 2025" do
    let(:form) { Form.new(nil, 2025, [], "sales") }
    let(:saledate) { Time.zone.local(2025, 4, 1) }

    context "with a staircasing log" do
      let(:log) { build(:sales_log, :shared_ownership_setup_complete, staircase: 1, saledate:) }

      it "is not routed to" do
        expect(page.routed_to?(log, nil)).to be false
      end
    end

    context "with a non-staircasing log" do
      let(:log) { build(:sales_log, staircase: nil, saledate:) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to be true
      end
    end
  end
end
