require "rails_helper"

RSpec.describe Form::Page, type: :model do
  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
  let(:section_id) { "rent_and_charges" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "income_and_benefits" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }
  let(:subsection) { Form::Subsection.new(subsection_id, subsection_definition, section) }
  let(:page_id) { "net_income" }
  let(:page_definition) { subsection_definition["pages"][page_id] }
  subject { Form::Page.new(page_id, page_definition, subsection) }

  it "has an id" do
    expect(subject.id).to eq(page_id)
  end

  it "has a header" do
    expect(subject.header).to eq("Test header")
  end

  it "has a description" do
    expect(subject.description).to eq("Some extra text for the page")
  end

  it "has questions" do
    expected_questions = %w[earnings incfreq]
    expect(subject.questions.map(&:id)).to eq(expected_questions)
  end

  it "has soft validations" do
    expected_soft_validations = %w[override_net_income_validation]
    expect(subject.soft_validations.map(&:id)).to eq(expected_soft_validations)
  end

  it "has a soft_validation helper" do
    expect(subject.has_soft_validations?).to be true
  end

  it "has expected form responses" do
    expected_responses = %w[earnings incfreq override_net_income_validation]
    expect(subject.expected_responses.map(&:id)).to eq(expected_responses)
  end

  context "for a given case log" do
    let(:case_log) { FactoryBot.build(:case_log, :in_progress) }

    it "knows if it's been routed to" do
      expect(subject.routed_to?(case_log)).to be true
    end

    context "given routing conditions" do
      let(:page_id) { "dependent_page" }

      it "evaluates not met conditions correctly" do
        expect(subject.routed_to?(case_log)).to be false
      end

      it "evaluates not conditions correctly" do
        case_log.incfreq = "Weekly"
        expect(subject.routed_to?(case_log)).to be true
      end
    end

    context "when the page's subsection has routing conditions" do
      let(:section_id) { "submission" }
      let(:subsection_id) { "declaration" }
      let(:page_id) { "declaration" }
      let(:completed_case_log) { FactoryBot.build(:case_log, :completed, incfreq: "Weekly") }

      it "evaluates the sections dependencies" do
        expect(subject.routed_to?(case_log)).to be false
        expect(subject.routed_to?(completed_case_log)).to be true
      end
    end
  end
end
