require "rails_helper"

RSpec.describe Form::Lettings::Pages::FirstTimePropertyLetAsSocialHousing, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }

  before do
    allow(form).to receive(:start_year_2024_or_later?).and_return(false)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[first_time_property_let_as_social_housing])
  end

  it "has the correct id" do
    expect(page.id).to eq("first_time_property_let_as_social_housing")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([{ "is_renewal?" => false }])
  end
end
