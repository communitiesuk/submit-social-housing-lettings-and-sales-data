require "rails_helper"
require_relative "../../request_helper"

RSpec.describe "form/page" do
  before do
    RequestHelper.stub_http_requests
  end

  let(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let(:form) { case_log.form }
  let(:subsection) { form.get_subsection("income_and_benefits") }
  let(:page) { form.get_page("net_income") }
  let(:question) { page.questions.find { |q| q.id == "earnings" } }
  let(:initial_page_attribs) { { description: nil, hide_subsection_label: nil } }
  let(:initial_question_attribs) { { type: "numeric", answer_options: nil, prefix: nil, suffix: nil } }
  let(:page_attribs) { {} }
  let(:question_attribs) { {} }

  def assign_attributes(object, attrs)
    attrs.each_pair do |attr, value|
      object.public_send("#{attr}=", value)
    end
  end

  before do
    assign(:case_log, case_log)
    assign(:page, page)
    assign(:subsection, subsection)
    assign_attributes(page, page_attribs)
    assign_attributes(question, question_attribs)
    render
  end

  after do
    # Revert any changes we've made to avoid affecting other specs as the form,
    # subsection, page, question objects being acted on are in memory
    assign_attributes(page, initial_page_attribs)
    assign_attributes(question, initial_question_attribs)
  end

  context "given a page with a description" do
    let(:description) { "Test description <a class=\"govuk-link\" href=\"/files/privacy-notice.pdf\">with link</a>." }
    let(:page_attribs) { { description: description } }
    let(:expected_html) { '<p class="govuk-body govuk-body-m">Test description <a class="govuk-link" href="/files/privacy-notice.pdf">with link</a>.</p>' }

    it "renders the description" do
      expect(rendered).to match(expected_html)
    end
  end

  context "given a page with a header" do
    it "renders the header and the subsection label" do
      expect(rendered).to match(page.header)
      expect(rendered).to match(subsection.label)
    end
  end

  context "given a page with a header and hide_subsection_label true" do
    let(:page_attribs) { { hide_subsection_label: true } }

    it "renders the header but not the subsection label" do
      expect(rendered).to match(page.header)
      expect(rendered).not_to match(subsection.label)
    end
  end

  context "given a numeric question with prefix and suffix" do
    let(:question_attribs) { { type: "numeric", prefix: "£", suffix: "every week" } }

    it "renders prefix and suffix text" do
      expect(rendered).to match(/govuk-input__prefix/)
      expect(rendered).to match(/£/)
      expect(rendered).to match(/govuk-input__suffix/)
      expect(rendered).to match("every week")
    end
  end

  context "given a question with extra guidance" do
    let(:expected_guidance) { /What counts as income?/ }

    context "with radio type" do
      let(:question_attribs) { { type: "radio", answer_options: { "1": "A", "2": "B" } } }
      it "renders the guidance partial for radio questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with text type" do
      let(:question_attribs) { { type: "text", answer_options: nil } }
      it "renders the guidance partial for text questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with numeric type" do
      let(:question_attribs) { { type: "numeric", answer_options: nil } }
      it "renders the guidance partial for numeric questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with select type" do
      let(:question_attribs) { { type: "select", answer_options: { "1": "A", "2": "B" } } }
      it "renders the guidance partial for select questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with checkbox type" do
      let(:question_attribs) { { type: "checkbox", answer_options: { "1": "A", "2": "B" } } }
      it "renders the guidance partial for checkbox questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with date type" do
      let(:question_attribs) { { type: "date", answer_options: nil } }
      it "renders the guidance partial for date questions" do
        expect(rendered).to match(expected_guidance)
      end
    end
  end
end
