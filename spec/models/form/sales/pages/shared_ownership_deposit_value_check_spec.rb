require "rails_helper"

RSpec.describe Form::Sales::Pages::SharedOwnershipDepositValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "shared_ownership_deposit_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[shared_ownership_deposit_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("shared_ownership_deposit_value_check")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "shared_ownership_deposit_invalid?" => true,
      },
    ])
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "soft_validations.shared_ownership_deposit.title_text",
      "arguments" => [
        { "i18n_template" => "mortgage_deposit_and_discount_error_fields", "key" => "mortgage_deposit_and_discount_error_fields" },
        { "arguments_for_key" => "mortgage_deposit_and_discount_total", "i18n_template" => "mortgage_deposit_and_discount_total", "key" => "field_formatted_as_currency" },
      ],
    })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({})
  end

  it "has the correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[mortgage mortgageused cashdis type deposit value equity])
  end
end
