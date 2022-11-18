require "rails_helper"

RSpec.describe Answer, type: :model do
  subject(:answer) { described_class.new(question:, log:) }

  let(:log) { FactoryBot.build(:lettings_log, :in_progress) }
  let(:form) { log.form }
  let(:question_id) { "incfreq" }
  let(:section_id) { "rent_and_charges" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "income_and_benefits" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }
  let(:subsection) { Form::Subsection.new(subsection_id, subsection_definition, section) }
  let(:page_definition) { subsection_definition["pages"][page_id] }
  let(:question_definition) { page_definition["questions"][question_id] }
  let(:page) { Form::Page.new(page_id, page_definition, subsection) }
  let(:page_id) { "net_income" }
  let(:question) { Form::Question.new(question_id, question_definition, page) }

  describe "#answer_label" do
    context "with a lettings log" do
      it "has an answer label" do
        log.incfreq = 1

        expect(answer.answer_label).to eql("Weekly")
      end
    end

    context "when type is date" do
      let(:section_id) { "local_authority" }
      let(:subsection_id) { "local_authority" }
      let(:page_id) { "property_major_repairs" }
      let(:question_id) { "mrcdate" }

      it "displays a formatted answer label" do
        log.mrcdate = Time.zone.local(2021, 10, 11)
        expect(answer.answer_label).to eql("11 October 2021")
      end

      it "can handle nils" do
        log.mrcdate = nil
        expect(answer.answer_label).to eql("")
      end
    end

    context "when type is checkbox" do
      let(:section_id) { "household" }
      let(:subsection_id) { "household_needs" }
      let(:page_id) { "accessibility_requirements" }
      let(:question_id) { "accessibility_requirements" }

      it "has a joined answers label" do
        log.housingneeds_a = 1
        log.housingneeds_c = 1
        expected_answer_label = "Fully wheelchair accessible housing, Level access housing"
        expect(answer.answer_label).to eql(expected_answer_label)
      end
    end

    context "when answers have a suffix dependent on another answer" do
      let(:section_id) { "rent_and_charges" }
      let(:subsection_id) { "income_and_benefits" }
      let(:page_id) { "net_income" }
      let(:question_id) { "earnings" }

      it "displays the correct label for given suffix and answer the suffix depends on" do
        log.incfreq = 1
        log.earnings = 500
        expect(answer.answer_label).to eql("£500.00 every week")
        log.incfreq = 2
        expect(answer.answer_label).to eql("£500.00 every month")
        log.incfreq = 3
        expect(answer.answer_label).to eql("£500.00 every year")
      end
    end

    context "with inferred_check_answers_value" do
      context "when Lettings form" do
        let(:section_id) { "household" }
        let(:subsection_id) { "household_needs" }
        let(:page_id) { "armed_forces" }
        let(:question_id) { "armedforces" }

        it "returns the inferred label value" do
          log.armedforces = 3
          expect(answer.answer_label).to eql("Prefers not to say")
        end
      end

      context "when Sales form" do
        let(:log) { FactoryBot.create(:sales_log, :completed, ethnic_group: 17) }
        let(:question) { log.form.get_question("ethnic_group", log) }

        it "returns the inferred label value" do
          expect(answer.answer_label).to eql("Prefers not to say")
        end
      end
    end
  end

  describe "#completed?" do
    context "when the question has inferred value only for check answers display" do
      let(:section_id) { "tenancy_and_property" }
      let(:subsection_id) { "property_information" }
      let(:page_id) { "property_postcode" }
      let(:question_id) { "postcode_full" }

      it "returns true" do
        log["postcode_known"] = 0
        expect(answer.completed?).to be(true)
      end
    end
  end
end
