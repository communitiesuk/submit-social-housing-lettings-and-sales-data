require "rails_helper"

RSpec.describe CheckAnswersHelper do
  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }

  describe "display_answered_questions_summary" do
    context "given a section that hasn't been completed yet" do
      it "returns a link to the next unanswered question" do
        expect(display_answered_questions_summary(subsection, case_log))
          .to match(/You answered 2 of 4 questions/)
        expect(display_answered_questions_summary(subsection, case_log))
          .to match(/href/)
      end
    end

    context "given a section that has been completed" do
      it "returns that you have answered all the questions" do
        case_log.sex1 = "F"
        case_log.other_hhmemb = 0
        expect(display_answered_questions_summary(subsection, case_log))
          .to match(/You answered all the questions/)
        expect(display_answered_questions_summary(subsection, case_log))
          .not_to match(/href/)
      end
    end
  end
end
