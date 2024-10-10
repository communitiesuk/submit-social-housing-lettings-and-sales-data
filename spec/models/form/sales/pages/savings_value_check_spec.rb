require "rails_helper"

RSpec.describe Form::Sales::Pages::SavingsValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: false) }

  let(:page_id) { "savings_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[savings_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("savings_value_check")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      { "not_joint_purchase?" => true,
        "savings_over_soft_max?" => true },
      { "jointpur" => nil,
        "savings_over_soft_max?" => true },
    ])
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has the correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[savings])
  end

  context "with joint purchase" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: true) }

    it "has correct depends_on" do
      expect(page.depends_on).to eq([
        { "joint_purchase?" => true,
          "savings_over_soft_max?" => true },
      ])
    end
  end
end
