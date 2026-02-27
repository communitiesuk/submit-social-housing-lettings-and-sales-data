require "rails_helper"

RSpec.describe Form::Sales::Pages::BuildingHeightClass, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:start_date) { collection_start_date_for_year(2026) }
  let(:form) { instance_double(Form, start_date:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[buildheightclass])
  end

  it "has the correct id" do
    expect(page.id).to eq("building_height_class")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([
      { "proptype" => 1 },
      { "proptype" => 2 },
      { "proptype" => 9 },
    ])
  end
end
