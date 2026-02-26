require "rails_helper"

RSpec.describe Form::Lettings::Pages::PreviousHousingSituation, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false, start_year_2026_or_later?: false)) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[prevten])
  end

  it "has the correct id" do
    expect(page.id).to eq("previous_housing_situation")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([{ "is_renewal?" => false }])
  end
end
