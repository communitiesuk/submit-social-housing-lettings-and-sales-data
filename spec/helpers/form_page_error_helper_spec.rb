require "rails_helper"

RSpec.describe FormPageErrorHelper do
  describe "#remove_other_page_errors" do
    context "when non base other questions are removed" do
      around do |example|
        Timecop.freeze(Time.zone.local(2022, 1, 1)) do
          Singleton.__init__(FormHandler)
          example.run
        end
        Timecop.return
        Singleton.__init__(FormHandler)
      end

      let!(:lettings_log) { FactoryBot.create(:lettings_log, :in_progress) }
      let!(:form) { lettings_log.form }

      before do
        lettings_log.errors.add :layear, "error"
        lettings_log.errors.add :period, "error_one"
        lettings_log.errors.add :base, "error_too"
      end

      it "returns details and user tabs" do
        page = form.get_page("rent")
        remove_other_page_errors(lettings_log, page)
        expect(lettings_log.errors.count).to eq(2)
        expect(lettings_log.errors.map(&:attribute)).to include(:period)
        expect(lettings_log.errors.map(&:attribute)).to include(:base)
      end
    end
  end
end
