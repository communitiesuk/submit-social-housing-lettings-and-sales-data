require "rails_helper"

RSpec.describe Form::Lettings::Pages::TenancyType, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq %w[tenancy tenancyother]
  end

  it "has the correct id" do
    expect(page.id).to eq "tenancy_type"
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq [{ "starter_tenancy?" => false }]
  end
end
