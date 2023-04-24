require "rails_helper"

RSpec.describe Form::Sales::Pages::NumberOfOthersInProperty, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:page_id) { "number_of_others_in_property" }
  let(:page_definition) { nil }
  let(:joint_purchase) { false }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[hholdcount])
  end

  it "has the correct id" do
    expect(page.id).to eq("number_of_others_in_property")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "buyer_has_seen_privacy_notice?" => true,
        "joint_purchase?" => joint_purchase,
      },
      {
        "buyer_not_interviewed?" => true,
        "joint_purchase?" => joint_purchase,
      },
    ])
  end

  context "with joint purchase" do
    let(:page_id) { "number_of_others_in_property_joint_purchase" }
    let(:joint_purchase) { true }

    it "has the correct id" do
      expect(page.id).to eq("number_of_others_in_property_joint_purchase")
    end

    it "has the correct depends_on" do
      expect(page.depends_on).to eq([
        {
          "buyer_has_seen_privacy_notice?" => true,
          "joint_purchase?" => joint_purchase,
        },
        {
          "buyer_not_interviewed?" => true,
          "joint_purchase?" => joint_purchase,
        },
      ])
    end
  end
end
