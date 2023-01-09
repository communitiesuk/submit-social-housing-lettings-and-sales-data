require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer1WorkingSituation, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[ecstat1])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_1_working_situation")
  end

  it "has the correct header" do
    expect(page.header).to eq("")
  end
end
