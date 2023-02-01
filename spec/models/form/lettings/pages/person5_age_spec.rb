require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonAge, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 5 }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to eq("")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[age5_known age5])
  end

  it "has the correct id" do
    expect(page.id).to eq("person_5_age")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq(
      [{ "details_known_5" => 0 }],
    )
  end
end
