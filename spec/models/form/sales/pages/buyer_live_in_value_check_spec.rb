require "rails_helper"

RSpec.describe Form::Sales::Pages::BuyerLiveInValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_id) { "buyer_1_live_in_value_check" }
  let(:page_definition) { nil }
  let(:person_index) { 1 }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[buyer_livein_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_1_live_in_value_check")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "buyer1_not_livein?" => true,
      },
    ])
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "soft_validations.buyer1_not_livein.title_text",
      "arguments" => [{ "key" => "owhership_scheme", "label" => false, "i18n_template" => "owhership_scheme" }],
    })
  end

  context "with buyer 2" do
    let(:person_index) { 2 }

    it "has correct depends_on" do
      expect(page.depends_on).to eq([
        {
          "buyer2_not_livein?" => true,
        },
      ])
    end

    it "has the correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.buyer2_not_livein.title_text",
        "arguments" => [{ "key" => "owhership_scheme", "label" => false, "i18n_template" => "owhership_scheme" }],
      })
    end
  end
end
