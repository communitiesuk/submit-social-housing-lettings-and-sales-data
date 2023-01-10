require "rails_helper"

RSpec.describe Form::Sales::Pages::AboutDepositWithDiscount, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[deposit cashdis])
  end

  it "has the correct id" do
    expect(page.id).to eq("about_deposit_with_discount")
  end

  it "has the correct header" do
    expect(page.header).to eq("About the deposit")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq(
      [{ "is_type_discount?" => true }],
    )
  end
end
