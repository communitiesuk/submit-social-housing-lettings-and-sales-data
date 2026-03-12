require "rails_helper"

RSpec.describe Form::Sales::Questions::Mortgageused, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:stairowned) { nil }
  let(:staircase) { nil }
  let(:saledate) { Time.zone.today }
  let(:log) { build(:sales_log, :in_progress, ownershipsch:, stairowned:, staircase:) }
  let(:start_year_2024_or_later?) { true }
  let(:start_year_2025_or_later?) { true }
  let(:start_year_2026_or_later?) { true }
  let(:subsection_id) { "shared_ownership_initial_purchase" }
  let(:form) { instance_double(Form, start_date: saledate, start_year_2024_or_later?: start_year_2024_or_later?, start_year_2025_or_later?: start_year_2025_or_later?, start_year_2026_or_later?: start_year_2026_or_later?) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form:, id: subsection_id)) }

  context "when it is a shared ownership scheme" do
    let(:ownershipsch) { 1 }

    it "has the correct top_guidance_partial" do
      expect(question.top_guidance_partial).to eq("financial_calculations_shared_ownership")
    end
  end

  context "when it is a discounted ownership sale" do
    let(:ownershipsch) { 2 }

    it "has the correct top_guidance_partial" do
      expect(question.top_guidance_partial).to eq("financial_calculations_discounted_ownership")
    end
  end

  context "when it is an outright sale" do
    let(:ownershipsch) { 3 }

    it "has the correct top_guidance_partial" do
      expect(question.top_guidance_partial).to eq("financial_calculations_outright_sale")
    end
  end

  context "when the form start year is 2024", metadata: { year: 24 } do
    let(:saledate) { collection_start_date_for_year(2024) }
    let(:start_year_2025_or_later?) { false }
    let(:start_year_2026_or_later?) { false }

    context "when it is a discounted ownership sale" do
      let(:ownershipsch) { 2 }

      it "shows the correct question number" do
        expect(question.question_number).to eq 104
      end

      it "does not show the don't know option" do
        expect_the_question_not_to_show_dont_know
      end
    end

    context "when it is an outright sale" do
      let(:ownershipsch) { 3 }

      it "shows the correct question number" do
        expect(question.question_number).to eq 112
      end

      it "shows the don't know option" do
        expect_the_question_to_show_dont_know
      end
    end

    context "when it is a shared ownership scheme" do
      let(:ownershipsch) { 1 }

      it "shows the correct question number" do
        expect(question.question_number).to eq 91
      end

      context "and it is a staircasing transaction" do
        let(:staircase) { 1 }

        context "and stairowned is less that 100" do
          let(:stairowned) { 50 }

          it "does not show the don't know option" do
            expect_the_question_not_to_show_dont_know
          end
        end

        context "and stairowned is 100" do
          let(:stairowned) { 100 }

          it "shows the don't know option" do
            expect_the_question_to_show_dont_know
          end
        end
      end

      context "and it is not a staircasing transaction" do
        let(:staircase) { 2 }

        it "does not show the don't know option" do
          expect_the_question_not_to_show_dont_know
        end
      end
    end
  end

  context "when the form start year is 2025", metadata: { year: 25 } do
    let(:saledate) { collection_start_date_for_year(2025) }
    let(:start_year_2026_or_later?) { false }

    context "when it is a discounted ownership sale" do
      let(:ownershipsch) { 2 }
      let(:subsection_id) { "discounted_ownership_scheme" }

      it "shows the correct question number" do
        expect(question.question_number).to eq 106
      end

      it "does not show the don't know option" do
        expect_the_question_not_to_show_dont_know
      end
    end

    context "when it is a shared ownership scheme" do
      let(:ownershipsch) { 1 }

      it "shows the correct question number" do
        expect(question.question_number).to eq 82
      end

      context "and it is a staircasing transaction" do
        let(:staircase) { 1 }

        it "shows the don't know option" do
          expect_the_question_to_show_dont_know
        end

        context "and stairowned is 100" do
          let(:stairowned) { 100 }

          it "shows the don't know option" do
            expect_the_question_to_show_dont_know
          end
        end
      end

      context "and it is not a staircasing transaction" do
        let(:staircase) { 2 }

        it "does not show the don't know option" do
          expect_the_question_not_to_show_dont_know
        end
      end
    end
  end

  context "when the form start year is 2026", metadata: { year: 26 } do
    let(:saledate) { collection_start_date_for_year(2026) }

    context "when it is a discounted ownership sale" do
      let(:ownershipsch) { 2 }
      let(:subsection_id) { "discounted_ownership_scheme" }

      it "shows the correct question number" do
        expect(question.question_number).to eq 116
      end

      it "shows the don't know option" do
        expect_the_question_to_show_dont_know
      end
    end

    context "when it is a shared ownership scheme" do
      let(:ownershipsch) { 1 }

      context "and it is a staircasing transaction" do
        let(:staircase) { 1 }
        let(:subsection_id) { "shared_ownership_staircasing_transaction" }

        it "shows the correct question number" do
          expect(question.question_number).to eq 107
        end

        it "shows the don't know option" do
          expect_the_question_to_show_dont_know
        end
      end

      context "and it is not a staircasing transaction" do
        let(:staircase) { 2 }
        let(:subsection_id) { "shared_ownership_initial_purchase" }

        it "shows the correct question number" do
          expect(question.question_number).to eq 90
        end

        it "shows the don't know option" do
          expect_the_question_to_show_dont_know
        end
      end
    end
  end

private

  def expect_the_question_not_to_show_dont_know
    expect(question.displayed_answer_options(log)).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    })
  end

  def expect_the_question_to_show_dont_know
    expect(question.displayed_answer_options(log)).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
      "divider" => { "value" => true },
      "3" => { "value" => "Don’t know" },
    })
  end
end
