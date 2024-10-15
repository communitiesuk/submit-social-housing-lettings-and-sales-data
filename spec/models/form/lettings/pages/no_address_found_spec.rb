require "rails_helper"

RSpec.describe Form::Lettings::Pages::NoAddressFound, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:log) { create(:lettings_log) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_search_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("no_address_found")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "address_options_present?" => false,
                                     "is_supported_housing?" => false,
                                     "uprn_known" => nil },
                                   { "address_options_present?" => false,
                                     "is_supported_housing?" => false,
                                     "uprn_known" => 0 },
                                   { "address_options_present?" => false,
                                     "is_supported_housing?" => false,
                                     "uprn_confirmed" => 0 }])
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({ "arguments" => [], "translation" => "soft_validations.no_address_found.title_text" })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({ "arguments" => [], "translation" => "soft_validations.no_address_found.informative_text" })
  end

  it "has the correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[address_line1_input])
  end
end
