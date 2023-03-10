require "rails_helper"

RSpec.describe Form::Sales::Pages::PreviousOwnership, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:page_id) { "example_id" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:joint_purchase) { true }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[prevown])
  end

  it "has the correct id" do
    expect(page.id).to eq("example_id")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "when sale is a joint purchase has the correct depends on" do
    expect(page.depends_on).to eq([{ "joint_purchase?" => true }])
  end

  context "when sale is not a joint purchase" do
    let(:joint_purchase) { false }

    it "has the correct depends on" do
      expect(page.depends_on).to eq([{ "joint_purchase?" => false }])
    end
  end
end
