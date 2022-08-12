require "rails_helper"

RSpec.describe CheckAnswersSummaryListCardComponent, type: :component do
  context "when given a set of questions" do
    let(:user) { FactoryBot.build(:user) }
    let(:case_log) { FactoryBot.build(:case_log, :completed) }
    let(:subsection_id) { "household_characteristics" }
    let(:subsection) { case_log.form.get_subsection(subsection_id) }
    let(:questions) { subsection.applicable_questions(case_log) }

    it "renders a summary list card for the answers to those questions" do
      result = render_inline(described_class.new(questions:, case_log:, user:))
      expect(result).to have_content(questions.first.answer_label(case_log))
    end
  end
end
