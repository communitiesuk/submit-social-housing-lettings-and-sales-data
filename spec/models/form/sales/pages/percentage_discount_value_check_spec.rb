require "rails_helper"

RSpec.describe Form::Sales::Pages::PercentageDiscountValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "percentage_discount_value_check" }
  let(:page_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }
  let(:subsection) { instance_double(Form::Subsection, form:) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[percentage_discount_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("percentage_discount_value_check")
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "forms.2024.sales.soft_validations.percentage_discount_value_check.title_text",
      "arguments" => [{ "key" => "discount", "label" => true, "i18n_template" => "discount" }],
    })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({
      "translation" => "forms.2024.sales.soft_validations.percentage_discount_value_check.informative_text",
      "arguments" => [],
    })
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "percentage_discount_invalid?" => true,
      },
    ])
  end

  it "has correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[discount proptype])
  end
end
