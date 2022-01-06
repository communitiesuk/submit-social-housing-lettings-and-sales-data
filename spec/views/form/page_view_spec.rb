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

  def assign_attributes(object, attrs)
    attrs.each_pair do |attr, value|
      object.public_send("#{attr}=", value)
    end
  end

  context "given a question with extra guidance" do
    let(:expected_guidance) { /What counts as income?/ }
    before do
      assign(:case_log, case_log)
      assign(:page, page)
      assign(:subsection, subsection)
      assign_attributes(question, attribs)
      render
    end

    context "with radio type" do
      let(:attribs) { { type: "radio", answer_options: { "1": "A", "2": "B" } } }
      it "renders the guidance partial for radio questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with text type" do
      let(:attribs) { { type: "text", answer_options: nil } }
      it "renders the guidance partial for text questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with numeric type" do
      let(:attribs) { { type: "numeric", answer_options: nil } }
      it "renders the guidance partial for numeric questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with select type" do
      let(:attribs) { { type: "select", answer_options: { "1": "A", "2": "B" } } }
      it "renders the guidance partial for select questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with checkbox type" do
      let(:attribs) { { type: "checkbox", answer_options: { "1": "A", "2": "B" } } }
      it "renders the guidance partial for checkbox questions" do
        expect(rendered).to match(expected_guidance)
      end
    end

    context "with date type" do
      let(:attribs) { { type: "date", answer_options: nil } }
      it "renders the guidance partial for date questions" do
        expect(rendered).to match(expected_guidance)
      end
    end
  end
end
