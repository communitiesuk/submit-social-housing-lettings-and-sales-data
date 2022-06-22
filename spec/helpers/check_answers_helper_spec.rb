require "rails_helper"

RSpec.describe CheckAnswersHelper do
  let(:form) { case_log.form }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
  let(:current_user) { FactoryBot.build(:user) }

  describe "display_answered_questions_summary" do
    context "when a section hasn't been completed yet" do
      it "returns that you have unanswered questions" do
        expect(display_answered_questions_summary(subsection, case_log, current_user))
          .to match(/You have answered 2 of 7 questions./)
      end
    end

    context "when a section has been completed" do
      it "returns that you have answered all the questions" do
        case_log.sex1 = "F"
        case_log.hhmemb = 1
        case_log.propcode = "123"
        case_log.ecstat1 = 200
        case_log.ecstat2 = 9
        expect(display_answered_questions_summary(subsection, case_log, current_user))
          .to match(/You answered all the questions./)
        expect(display_answered_questions_summary(subsection, case_log, current_user))
          .not_to match(/href/)
      end
    end
  end
end
