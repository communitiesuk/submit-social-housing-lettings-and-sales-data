require "rails_helper"

RSpec.describe Form::Sales::Pages::PreviousPropertyType, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[fromprop])
  end

  it "has the correct id" do
    expect(page.id).to eq("previous_property_type")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "soctenant" => 1,
      },
      {
        "soctenant" => 0,
      },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevten" => 1 },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevten" => 2 },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevtenbuy2" => 1 },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevtenbuy2" => 2 },
    ])
  end
end
