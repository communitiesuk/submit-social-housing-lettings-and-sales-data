require "rails_helper"

RSpec.describe Form::Lettings::Pages::NoFemalesPregnantHouseholdPersonAgeValueCheck, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 2 }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to be nil
  end

  it "has the correct description" do
    expect(page.description).to be nil
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[pregnancy_value_check])
  end

  context "with person 2" do
    it "has the correct id" do
      expect(page.id).to eq("no_females_pregnant_household_person_2_age_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "age2_known" => 0,
           "no_females_in_a_pregnant_household?" => true }],
      )
    end

    it "has the correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.pregnancy.title",
        "arguments" => [{
          "key" => "sex1",
          "label" => true,
          "i18n_template" => "sex1",
        }],
      })
    end

    it "has the correct informative_text" do
      expect(page.informative_text).to eq({
        "translation" => "soft_validations.pregnancy.no_females",
        "arguments" => [{
          "key" => "sex1",
          "label" => true,
          "i18n_template" => "sex1",
        }],
      })
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(page.id).to eq("no_females_pregnant_household_person_3_age_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "age3_known" => 0,
           "no_females_in_a_pregnant_household?" => true }],
      )
    end

    it "has the correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.pregnancy.title",
        "arguments" => [{
          "key" => "sex1",
          "label" => true,
          "i18n_template" => "sex1",
        }],
      })
    end

    it "has the correct informative_text" do
      expect(page.informative_text).to eq({
        "translation" => "soft_validations.pregnancy.no_females",
        "arguments" => [{
          "key" => "sex1",
          "label" => true,
          "i18n_template" => "sex1",
        }],
      })
    end
  end
end
