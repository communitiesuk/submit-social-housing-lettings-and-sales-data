require "rails_helper"

RSpec.describe Form::Sales::Pages::DepositValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: false) }

  let(:page_id) { "deposit_value_check" }
  let(:page_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2026_or_later?: false) }
  let(:subsection) { instance_double(Form::Subsection, form:) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[deposit_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("deposit_value_check")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "deposit_over_soft_max?" => true,
        "not_joint_purchase?" => true,
      },
      {
        "deposit_over_soft_max?" => true,
        "jointpur" => nil,
      },
    ])
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "is has correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[savings deposit])
  end
end
