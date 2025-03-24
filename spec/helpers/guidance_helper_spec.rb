require "rails_helper"

RSpec.describe GuidanceHelper do
  describe "#question_link" do
    context "when question page is routed to" do
      let(:log) { create(:sales_log, :shared_ownership_setup_complete, mortgageused: 2, saledate: Time.zone.local(2024, 5, 3)) }

      it "returns an empty string if question is not routed to" do
        expect(question_link("mortgage", log, log.assigned_to)).to eq("")
      end
    end

    context "when question page is not routed to" do
      let(:log) { create(:sales_log, :shared_ownership_setup_complete, mortgageused: 1, saledate: Time.zone.local(2024, 5, 3)) }

      it "returns a link to the question with correct question number in brakets" do
        expect(question_link("mortgage", log, log.assigned_to)).to eq("(<a class=\"govuk-link\" href=\"/sales-logs/#{log.id}/mortgage-amount-shared-ownership\">Q92</a>)")
      end
    end
  end
end
