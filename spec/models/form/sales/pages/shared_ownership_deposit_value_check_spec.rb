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

  it "has the correct header" do
    expect(page.header).to be_nil
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
      "translation" => "soft_validations.shared_owhership_deposit.title_text",
      "arguments" => [
        {
          "key" => "expected_shared_ownership_deposit_value",
          "label" => false,
          "i18n_template" => "expected_shared_ownership_deposit_value",
        },
      ],
    })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({})
  end
end
