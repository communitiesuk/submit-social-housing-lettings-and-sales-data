require "rails_helper"

RSpec.describe FormPageErrorHelper do
  describe "#remove_other_page_errors" do
    context "when non base other questions are removed" do
      let!(:lettings_log) { FactoryBot.create(:lettings_log, :in_progress) }
      let!(:form) { lettings_log.form }

      before do
        lettings_log.errors.add :layear, "error"
        lettings_log.errors.add :period, "error_one"
        lettings_log.errors.add :base, "error_too"
      end

      it "returns details and user tabs" do
        page = form.get_question("period", lettings_log).page
        remove_other_page_errors(lettings_log, page)
        expect(lettings_log.errors.count).to eq(2)
        expect(lettings_log.errors.map(&:attribute)).to include(:period)
        expect(lettings_log.errors.map(&:attribute)).to include(:base)
      end
    end
  end

  describe "#remove_duplicate_page_errors" do
    context "when non base other questions are removed" do
      let!(:lettings_log) { FactoryBot.create(:lettings_log, :in_progress) }

      before do
        lettings_log.errors.add :layear, "error"
        lettings_log.errors.add :period, "error_one"
        lettings_log.errors.add :base, "error_one"
      end

      it "returns details and user tabs" do
        remove_duplicate_page_errors(lettings_log)
        expect(lettings_log.errors.count).to eq(2)
        expect(lettings_log.errors.map(&:message)).to match_array(%w[error_one error])
      end
    end
  end
end
