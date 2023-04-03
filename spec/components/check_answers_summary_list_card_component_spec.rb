require "rails_helper"

RSpec.describe CheckAnswersSummaryListCardComponent, type: :component do
  subject(:component) { described_class.new(questions:, log:, user:) }

  let(:rendered) { render_inline(component) }

  context "when before 23/24 collection" do
    before do
      Timecop.freeze(Time.zone.local(2023, 1, 10))
      Singleton.__init__(FormHandler)
    end

    after do
      Timecop.return
    end

    context "when given a set of questions" do
      let(:user) { build(:user) }
      let(:log) { build(:lettings_log, :completed, age2: 99, startdate: Time.zone.local(2021, 5, 1)) }
      let(:subsection_id) { "household_characteristics" }
      let(:subsection) { log.form.get_subsection(subsection_id) }
      let(:questions) { subsection.applicable_questions(log) }

      it "renders a summary list card without question numbers for the answers to those questions" do
        expect(rendered).to have_content(questions.first.answer_label(log))
        expect(rendered).to have_content("Lead tenant’s age")
        expect(rendered).not_to have_content("Q32 - Lead tenant’s age")
      end

      it "applicable questions doesn't return questions that are hidden in check answers" do
        expect(component.applicable_questions.map(&:id).include?("retirement_value_check")).to eq(false)
      end

      it "has the correct answer label for a question" do
        sex1_question = questions[2]
        expect(component.get_answer_label(sex1_question)).to eq("Female")
      end

      context "when log was created via a bulk upload and has an unanswered question" do
        subject(:component) { described_class.new(questions:, log:, user:) }

        let(:bulk_upload) { build(:bulk_upload, :lettings) }
        let(:log) { build(:lettings_log, :in_progress, bulk_upload:, age2: 99, startdate: Time.zone.local(2021, 5, 1)) }

        it "displays tweaked copy in red" do
          expect(rendered).to have_selector("span", class: "app-!-colour-red", text: "You still need to answer this question")
        end
      end

      context "when log was not created via a bulk upload and has an unanswered question" do
        subject(:component) { described_class.new(questions:, log:, user:) }

        let(:log) { build(:lettings_log, :in_progress, age2: 99, startdate: Time.zone.local(2021, 5, 1)) }

        it "displays normal copy with muted colour " do
          expect(rendered).to have_selector("span", class: "app-!-colour-muted", text: "You didn’t answer this question")
        end
      end
    end
  end

  context "when in 23/24 collection" do
    context "when given a set of questions" do
      let(:user) { build(:user) }
      let(:log) { build(:lettings_log, :completed, age2: 99, startdate: Time.zone.local(2023, 5, 1)) }
      let(:subsection_id) { "household_characteristics" }
      let(:subsection) { log.form.get_subsection(subsection_id) }
      let(:questions) { subsection.applicable_questions(log) }

      it "renders a summary list card includinq question numbers for the answers to those questions" do
        expect(rendered).to have_content(questions.first.answer_label(log))
        expect(rendered).to have_content("Q32 - Lead tenant’s age")
      end
    end
  end
end
