require "rails_helper"

RSpec.describe Form::Lettings::Pages::PreviousPostcode, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "previous_postcode" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_year_2024_or_later?: false, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(
      %w[
        ppcodenk
        ppostcode_full
      ],
    )
  end

  it "has the correct id" do
    expect(page.id).to eq("previous_postcode")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to match([{ "renewal" => 0 }])
  end
end
