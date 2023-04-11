require "rails_helper"

RSpec.describe Form::Sales::Pages::AboutPriceValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "savings_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[value_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("savings_value_check")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "purchase_price_out_of_soft_range?" => true }])
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({ "arguments" => [{ "i18n_template" => "value", "key" => "value", "label" => true }], "translation" => "soft_validations.purchase_price.title_text" })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({
      "translation" => "soft_validations.purchase_price.hint_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "purchase_price_soft_min_or_soft_max",
          "i18n_template" => "soft_min_or_soft_max",
        },
        {
          "key" => "purchase_price_min_or_max_text",
          "i18n_template" => "min_or_max",
        },
      ],
    })
  end
end
