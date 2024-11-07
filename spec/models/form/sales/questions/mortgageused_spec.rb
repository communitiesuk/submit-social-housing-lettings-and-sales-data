require "rails_helper"

RSpec.describe Form::Sales::Questions::Mortgageused, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch:) }

  let(:ownershipsch) { 1 }
  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form:)) }
  let(:stairowned) { nil }
  let(:staircase) { nil }
  let(:saledate) { Time.zone.today }
  let(:log) { build(:sales_log, :in_progress, ownershipsch:, stairowned:, staircase:) }

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
      "3" => { "value" => "Don’t know" },
    })
  end

  describe "the displayed answer options" do
    context "when it is a discounted ownership sale" do
      let(:ownershipsch) { 2 }

      it "does not show the don't know option" do
        expect_the_question_not_to_show_dont_know
      end
    end

    context "when it is an outright sale" do
      let(:ownershipsch) { 3 }

      context "and the saledate is before 24/25" do
        before do
          allow(form).to receive(:start_year_2024_or_later?).and_return false
        end

        it "does not show the don't know option" do
          expect_the_question_not_to_show_dont_know
        end
      end

      context "and the saledate is 24/25 or after" do
        before do
          allow(form).to receive(:start_year_2024_or_later?).and_return true
        end

        it "shows the don't know option" do
          expect_the_question_to_show_dont_know
        end
      end
    end

    context "when it is a shared ownership scheme" do
      let(:ownershipsch) { 1 }

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
      "3" => { "value" => "Don’t know" },
    })
  end
end
