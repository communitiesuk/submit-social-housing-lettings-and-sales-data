require "rails_helper"

RSpec.describe CheckAnswersHelper do
  let(:form) { lettings_log.form }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }
  let(:current_user) { FactoryBot.build(:user) }

  around do |example|
    Timecop.freeze(Time.zone.local(2022, 1, 1)) do
      Singleton.__init__(FormHandler)
      example.run
    end
  end

  describe "display_answered_questions_summary" do
    context "when a section hasn't been completed yet" do
      it "returns that you have unanswered questions" do
        expect(display_answered_questions_summary(subsection, lettings_log, current_user))
          .to match(/You have answered 4 of 10 questions./)
      end
    end

    context "when a section has been completed" do
      it "returns that you have answered all the questions" do
        lettings_log.sex1 = "F"
        lettings_log.hhmemb = 1
        lettings_log.propcode = "123"
        lettings_log.ecstat1 = 200
        lettings_log.ecstat2 = 9
        expect(display_answered_questions_summary(subsection, lettings_log, current_user))
          .to match(/You answered all the questions./)
        expect(display_answered_questions_summary(subsection, lettings_log, current_user))
          .not_to match(/href/)
      end
    end
  end

  describe "#get_answer_label" do
    context "when unanswered and bulk upload" do
      let(:question) { log.form.questions.sample }
      let(:bulk_upload) { create(:bulk_upload) }
      let(:log) { build(:sales_log, creation_method: "bulk upload", bulk_upload:) }

      it "is red" do
        expect(get_answer_label(question, log)).to include("red")
      end
    end
  end
end
