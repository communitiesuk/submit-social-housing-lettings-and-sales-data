require "rails_helper"

RSpec.describe Form::Lettings::Subsections::Setup, type: :model do
  include CollectionTimeHelper

  subject(:setup) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::Setup) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }

  before do
    allow(section).to receive(:form).and_return(form)
  end

  it "has correct section" do
    expect(setup.section).to eq(section)
  end

  describe "pages" do
    it "has correct pages" do
      expect(setup.pages.map(&:id)).to eq(
        %w[
          stock_owner
          managing_organisation
          assigned_to
          needs_type
          scheme
          location
          location_search
          renewal
          tenancy_start_date
          rent_type
          tenant_code
          property_reference
          declaration
        ],
      )
    end
  end

  it "has the correct id" do
    expect(setup.id).to eq("setup")
  end

  it "has the correct label" do
    expect(setup.label).to eq("Set up this lettings log")
  end
end
