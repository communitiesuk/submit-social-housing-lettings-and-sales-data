require "rails_helper"

RSpec.describe LogSummaryComponent, type: :component do
  let(:support_user) { FactoryBot.create(:user, :support) }
  let(:coordinator_user) { FactoryBot.create(:user) }
  let!(:log) { FactoryBot.create(:case_log, needstype: 1, startdate: Time.utc(2022, 1, 1)) }

  context "when rendering log for a support user" do
    it "show the log summary with organisational relationships" do
      result = render_inline(described_class.new(current_user: support_user, log:))

      expect(result).to have_link(log.id.to_s)
      expect(result).to have_text(log.tenancycode)
      expect(result).to have_text(log.propcode)
      expect(result).to have_text(log.propcode)
      expect(result).to have_text("General needs")
      expect(result).to have_text("Tenancy starts 1 January 2022")
      expect(result).to have_text("Created 8 February 2022")
      expect(result).to have_text("by Danny Rojas")
      expect(result).to have_content("Owned by\n              DLUHC")
      expect(result).to have_content("Managed by\n              DLUHC")
    end
  end

  context "when rendering log for a data coordinator user" do
    it "show the log summary" do
      result = render_inline(described_class.new(current_user: coordinator_user, log:))

      expect(result).not_to have_content("Owned by\n              DLUHC")
      expect(result).not_to have_content("Managed by\n              DLUHC")
    end
  end
end
