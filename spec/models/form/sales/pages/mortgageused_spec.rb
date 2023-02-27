require "rails_helper"

RSpec.describe Form::Sales::Pages::Mortgageused, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, question_number:) }

  let(:page_id) { "mortgage_used" }
  let(:page_definition) { nil }
  let(:question_number) { "Q98" }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[mortgageused])
  end

  it "has the correct id" do
    expect(page.id).to eq("mortgage_used")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end
end
