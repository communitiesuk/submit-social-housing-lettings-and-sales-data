require "rails_helper"

RSpec.describe Form::Lettings::Pages::CareHomeChargesValueCheck, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be nil
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[carehome_charges_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("care_home_charges_value_check")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq(
      [{ "care_home_charge_expected_not_provided?" => true }],
    )
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "forms.2024.lettings.soft_validations.care_home_charges_value_check.title_text",
    })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({ "arguments" => [], "translation" => "forms.2024.lettings.soft_validations.care_home_charges_value_check.informative_text" })
  end

  it "has the correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[chcharge is_carehome])
  end
end
