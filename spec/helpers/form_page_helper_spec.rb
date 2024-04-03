require "rails_helper"

RSpec.describe FormPageHelper do
  describe "#action_href" do
    let(:lettings_log) { FactoryBot.create(:lettings_log) }
    let(:sales_log) { FactoryBot.create(:sales_log) }

    context "with a lettings log" do
      let(:question) { lettings_log.form.questions.detect { |q| q.id == "needstype" } }

      it "answer link href helper does not attach referrer when question not answered" do
        expect(check_answers_href(question, lettings_log)).to eq("/lettings-logs/#{lettings_log.id}/needs-type")
      end

      it "answer link href helper attaches referrer when question already answered" do
        lettings_log[question.id] = 1
        expect(check_answers_href(question, lettings_log)).to eq("/lettings-logs/#{lettings_log.id}/needs-type?referrer=check_answers")
      end

      it "has an action href helper" do
        expect(action_href(lettings_log, "net_income", "interruption_screen")).to eq("/lettings-logs/#{lettings_log.id}/net-income?referrer=interruption_screen")
      end
    end

    context "with a sales log" do
      let(:question) { sales_log.form.questions.detect { |q| q.id == "ownershipsch" } }

      it "answer link href helper does not attach referrer when question not answered" do
        expect(check_answers_href(question, sales_log)).to eq("/sales-logs/#{sales_log.id}/ownership-scheme")
      end

      it "answer link href helper attaches referrer when question already answered" do
        sales_log[question.id] = 1
        expect(check_answers_href(question, sales_log)).to eq("/sales-logs/#{sales_log.id}/ownership-scheme?referrer=check_answers")
      end

      it "has an action href helper" do
        expect(action_href(sales_log, "buyer_1_age", "interruption_screen")).to eq("/sales-logs/#{sales_log.id}/buyer-1-age?referrer=interruption_screen")
      end
    end
  end
end
