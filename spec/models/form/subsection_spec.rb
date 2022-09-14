require "rails_helper"
require_relative "../../request_helper"

RSpec.describe Form::Subsection, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:lettings_log) { FactoryBot.build(:lettings_log) }
  let(:form) { lettings_log.form }
  let(:section_id) { "household" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "household_characteristics" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json", "2021_2022") }

  before do
    RequestHelper.stub_http_requests
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  it "has an id" do
    expect(subsection.id).to eq(subsection_id)
  end

  it "has a label" do
    expect(subsection.label).to eq("Household characteristics")
  end

  it "has pages" do
    expected_pages = %w[tenant_code_test person_1_age person_1_gender person_1_working_situation household_number_of_members retirement_value_check person_2_working_situation propcode]
    expect(subsection.pages.map(&:id)).to eq(expected_pages)
  end

  it "has questions" do
    expected_questions = %w[tenancycode age1 sex1 ecstat1 hhmemb relat2 age2 sex2 retirement_value_check ecstat2 propcode]
    expect(subsection.questions.map(&:id)).to eq(expected_questions)
  end

  context "with an in progress lettings log" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }

    it "has a status" do
      expect(subsection.status(lettings_log)).to eq(:in_progress)
    end

    it "has a completed status for completed subsection" do
      subsection_definition = section_definition["subsections"]["household_needs"]
      subsection = described_class.new("household_needs", subsection_definition, section)
      lettings_log.armedforces = 3
      lettings_log.illness = 1
      lettings_log.housingneeds_a = 1
      lettings_log.la = "E06000014"
      lettings_log.illness_type_1 = 1
      expect(subsection.status(lettings_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(subsection.is_incomplete?(lettings_log)).to be(true)
      expect(subsection.is_started?(lettings_log)).to be(true)
    end

    context "with optional fields" do
      subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

      let(:section_id) { "tenancy_and_property" }
      let(:section_definition) { form.form_definition["sections"][section_id] }
      let(:section) { Form::Section.new(section_id, section_definition, form) }
      let(:subsection_id) { "property_information" }
      let(:subsection_definition) { section_definition["subsections"][subsection_id] }

      it "has a started status even if only an optional field has been answered" do
        lettings_log.postcode_known = 0
        expect(subsection.is_started?(lettings_log)).to be(true)
      end
    end

    it "has question helpers for the number of applicable questions" do
      expected_questions = %w[tenancycode age1 sex1 ecstat1 hhmemb ecstat2 propcode]
      expect(subsection.applicable_questions(lettings_log).map(&:id)).to eq(expected_questions)
    end
  end

  context "with a completed lettings log" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :completed) }

    it "has a status" do
      expect(subsection.status(lettings_log)).to eq(:completed)
    end

    it "has a status when optional fields are not filled" do
      lettings_log.update!({ propcode: nil })
      lettings_log.reload
      expect(subsection.status(lettings_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(subsection.is_incomplete?(lettings_log)).to be(false)
      expect(subsection.is_started?(lettings_log)).to be(true)
    end
  end
end
