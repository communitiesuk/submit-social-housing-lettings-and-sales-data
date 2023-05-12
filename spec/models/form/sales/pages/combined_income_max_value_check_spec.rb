require "rails_helper"

RSpec.describe Form::Sales::Pages::CombinedIncomeMaxValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, check_answers_card_number: nil) }

  let(:page_id) { "prefix_combined_income_max_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[combined_income_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("prefix_combined_income_max_value_check")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "combined_income_over_soft_max?" => true,
      },
    ])
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end
end
