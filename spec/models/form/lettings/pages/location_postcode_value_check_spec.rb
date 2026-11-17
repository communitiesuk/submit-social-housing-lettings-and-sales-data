require "rails_helper"

RSpec.describe Form::Lettings::Pages::LocationPostcodeValueCheck, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2026, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[location_postcode_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("location_postcode_value_check")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "postcode_does_not_match_location_postcode?" => true }])
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "forms.2026.lettings.soft_validations.location_postcode_value_check.title_text",
      "arguments" => [
        { "key" => "postcode_full", "label" => false, "i18n_template" => "postcode_full" },
        { "key" => "location_postcode", "label" => false, "i18n_template" => "location_postcode" },
      ],
    })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({
      "translation" => "forms.2026.lettings.soft_validations.location_postcode_value_check.informative_text",
      "arguments" => [],
    })
  end

  it "has the correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[location_id uprn postcode_full])
  end
end
