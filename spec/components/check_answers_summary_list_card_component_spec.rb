require "rails_helper"

RSpec.describe CheckAnswersSummaryListCardComponent, type: :component do
  subject(:component) { described_class.new(questions:, log:, user:) }

  let(:rendered) { render_inline(component) }

  context "when given a set of questions" do
    let(:user) { build(:user) }
    let(:log) { build(:lettings_log, :completed, age2: 99, startdate: Time.zone.local(2021, 5, 1)) }
    let(:subsection_id) { "household_characteristics" }
    let(:subsection) { log.form.get_subsection(subsection_id) }
    let(:questions) { subsection.applicable_questions(log) }

    it "renders a summary list card for the answers to those questions" do
      expect(rendered).to have_content(questions.first.answer_label(log))
    end

    it "applicable questions doesn't return questions that are hidden in check answers" do
      expect(component.applicable_questions.map(&:id).include?("retirement_value_check")).to eq(false)
    end

    it "has the correct answer label for a question" do
      sex1_question = questions[2]
      expect(component.get_answer_label(sex1_question)).to eq("Female")
    end

    context "when filtered by bulk upload with unanswered question" do
      subject(:component) { described_class.new(questions:, log:, user:, bulk_upload:) }

      let(:bulk_upload) { build(:bulk_upload, :lettings) }
      let(:log) { build(:lettings_log, :in_progress, bulk_upload:, age2: 99, startdate: Time.zone.local(2021, 5, 1)) }

      it "is displayed with tweaked copy in red" do
        expect(rendered).to have_selector("span", class: "app-!-colour-red", text: "You still need to answer this question")
      end
    end
  end
end
