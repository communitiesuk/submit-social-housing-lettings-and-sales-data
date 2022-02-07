require "rails_helper"

RSpec.describe "form/page" do
  let(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let(:form) { case_log.form }
  let(:subsection) { form.get_subsection("income_and_benefits") }
  let(:page) { form.get_page("net_income") }
  let(:question) { page.questions.find { |q| q.id == "earnings" } }
  let(:initial_page_attributes) { { description: nil, hide_subsection_label: nil } }
  let(:initial_question_attributes) { { type: "numeric", answer_options: nil, prefix: nil, suffix: nil } }
  let(:page_attributes) { {} }
  let(:question_attributes) { {} }

  def assign_attributes(object, attrs)
    attrs.each_pair do |attr, value|
      object.public_send("#{attr}=", value)
    end
  end

  before do
    assign(:case_log, case_log)
    assign(:page, page)
    assign(:subsection, subsection)
    assign_attributes(page, page_attributes)
    assign_attributes(question, question_attributes)
    render
  end

  after do
    # Revert any changes we've made to avoid affecting other specs as the form,
    # subsection, page, question objects being acted on are in memory
    assign_attributes(page, initial_page_attributes)
    assign_attributes(question, initial_question_attributes)
  end

  context "with a page containing a description" do
    let(:description) { "Test description <a class=\"govuk-link\" href=\"/files/privacy-notice.pdf\">with link</a>." }
    let(:page_attributes) { { description: description } }
    let(:expected_html) { '<p class="govuk-body govuk-body-m">Test description <a class="govuk-link" href="/files/privacy-notice.pdf">with link</a>.</p>' }

    it "renders the description" do
      expect(rendered).to match(expected_html)
    end
  end

  context "with a page containing a header" do
    it "renders the header and the subsection label" do
      expect(rendered).to match(page.header)
      expect(rendered).to match(subsection.label)
    end
  end

  context "with a page containing a header and hide_subsection_label true" do
    let(:page_attributes) { { hide_subsection_label: true } }

    it "renders the header but not the subsection label" do
      expect(rendered).to match(page.header)
      expect(rendered).not_to match(subsection.label)
    end
  end

  context "when rendering a numeric question with prefix and suffix" do
    let(:question_attributes) { { type: "numeric", prefix: "£", suffix: "every week" } }

    it "renders prefix and suffix text" do
      expect(rendered).to match(/govuk-input__prefix/)
      expect(rendered).to match(/£/)
      expect(rendered).to match(/govuk-input__suffix/)
      expect(rendered).to match("every week")
    end

    context "when the suffix is conditional and not a string" do
      let(:question_attributes) do
        {
          type: "numeric",
          prefix: "£",
          suffix: [
            { "label": "every week", "depends_on": { "incfreq": "Weekly" } },
            { "label": "every month", "depends_on": { "incfreq": "Monthly" } },
            { "label": "every month", "depends_on": { "incfreq": "Yearly" } },
          ],
        }
      end

      it "does not render the suffix" do
        expect(rendered).not_to match(/govuk-input__suffix/)
        expect(rendered).not_to match("every week")
        expect(rendered).not_to match("every month")
        expect(rendered).not_to match("every year")
      end
    end
  end

  context "with a question containing extra guidance" do
    let(:expected_guidance) { /What counts as income?/ }

    context "with radio type" do
      let(:question_attributes) { { type: "radio", answer_options: { "1": "A", "2": "B" } } }

      it "renders the guidance partial for radio questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with text type" do
      let(:question_attributes) { { type: "text", answer_options: nil } }

      it "renders the guidance partial for text questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with numeric type" do
      let(:question_attributes) { { type: "numeric", answer_options: nil } }

      it "renders the guidance partial for numeric questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with select type" do
      let(:question_attributes) { { type: "select", answer_options: { "1": "A", "2": "B" } } }

      it "renders the guidance partial for select questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with checkbox type" do
      let(:question_attributes) { { type: "checkbox", answer_options: { "1": "A", "2": "B" } } }

      it "renders the guidance partial for checkbox questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with date type" do
      let(:question_attributes) { { type: "date", answer_options: nil } }

      it "renders the guidance partial for date questions" do
        expect(rendered).to match(expected_guidance)
      end
    end
  end
end
