require "rails_helper"

RSpec.describe Form::Lettings::Pages::PropertyWheelchairAccessible, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1))) }

  before do
    allow(subsection).to receive(:form).and_return(instance_double(Form, start_year_2024_or_later?: false, start_date: Time.zone.local(2023, 4, 1)))
  end

  it "has correct subsection" do
    expect(page.subsection).to be(subsection)
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

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([{ "is_general_needs?" => true }])
  end
end
