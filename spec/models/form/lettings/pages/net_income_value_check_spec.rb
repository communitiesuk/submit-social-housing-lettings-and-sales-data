require "rails_helper"

RSpec.describe Form::Lettings::Pages::NetIncomeValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "shared_ownership_deposit_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[net_income_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("net_income_value_check")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "net_income_soft_validation_triggered?" => true }])
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({ "translation" => "soft_validations.net_income.title_text", "arguments" => [{ "i18n_template" => "incfreq", "key" => "incfreq", "label" => true }, { "arguments_for_key" => "earnings", "i18n_template" => "earnings", "key" => "field_formatted_as_currency" }] })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({
      "arguments" => [{ "i18n_template" => "net_income_higher_or_lower_text", "key" => "net_income_higher_or_lower_text", "label" => false }],
      "translation" => "soft_validations.net_income.hint_text",
    })
  end
end
