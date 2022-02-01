require "rails_helper"
require_relative "../request_helper"

RSpec.describe FormPageErrorHelper do
  before do
    RequestHelper.stub_http_requests
  end

  describe "#remove_other_page_errors" do
    context "when non base other questions are removed" do
      let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
      let!(:form) { case_log.form }

      before do
        case_log.errors.add :layear, "error"
        case_log.errors.add :period, "error_one"
        case_log.errors.add :base, "error_too"
      end

      it "returns details and user tabs" do
        page = form.get_page("rent")
        remove_other_page_errors(case_log, page)
        expect(case_log.errors.count).to eq(2)
        expect(case_log.errors.map(&:attribute)).to include(:period)
        expect(case_log.errors.map(&:attribute)).to include(:base)
      end
    end
  end
end
