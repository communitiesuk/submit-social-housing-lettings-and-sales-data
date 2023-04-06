require "rails_helper"

RSpec.describe Form::Lettings::Pages::MaxRentValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "shared_ownership_deposit_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[rent_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("max_rent_value_check")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "rent_in_soft_max_range?" => true }])
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({ "arguments" => [{ "i18n_template" => "brent", "key" => "brent", "label" => true, "money" => true }], "translation" => "soft_validations.rent.outside_range_title" })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({ "arguments" => [{ "i18n_template" => "soft_max_for_period", "key" => "soft_max_for_period", "label" => false, "money" => true }], "translation" => "soft_validations.rent.max_hint_text" })
  end
end
