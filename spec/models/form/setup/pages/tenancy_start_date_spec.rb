require "rails_helper"

RSpec.describe Form::Setup::Pages::TenancyStartDate, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[startdate])
  end

  it "has the correct id" do
    expect(page.id).to eq("tenancy_start_date")
  end

  it "has the correct header" do
    expect(page.header).to be nil
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to be nil
  end
end
