require "rails_helper"

RSpec.describe SalesLogSummaryComponent, type: :component do
  let(:support_user) { build(:user, :support) }
  let(:coordinator_user) { build(:user) }
  let(:purchid) { "62863" }
  let(:ownershipsch) { "0" }
  let(:saledate) {  Time.zone.today }
  let(:sales_log) { build(:sales_log, ownershipsch:, purchid:, saledate:) }

  before do
    allow(sales_log).to receive(:id).and_return 1
  end

  context "when rendering sales log for a support user" do
    it "shows the log summary with organisational relationships" do
      result = render_inline(described_class.new(current_user: support_user, log: sales_log))

      expect(result).to have_content("Owned by\n              MHCLG")
      expect(result).not_to have_content("Managed by")
    end
  end

  context "when rendering sales log for a data coordinator user" do
    it "does not show the user who the log is owned and managed by" do
      result = render_inline(described_class.new(current_user: coordinator_user, log: sales_log))

      expect(result).not_to have_content("Owned by")
      expect(result).not_to have_content("Managed by")
    end
  end

  describe "what is shown in regards to sale completion" do
    context "when a sale is completed" do
      let(:saledate) { Time.zone.today }

      it "shows the sale completion date" do
        result = render_inline(described_class.new(current_user: coordinator_user, log: sales_log))

        expect(result).to have_content("Sale completed")
      end
    end

    context "when a sale is completed and a purchaser id is provided" do
      let(:purchid) { "62863" }
      let(:saledate) { Time.zone.today }

      it "shows the purchaser id" do
        result = render_inline(described_class.new(current_user: coordinator_user, log: sales_log))

        expect(result).to have_content(purchid)
      end
    end

    context "when the sale is not completed" do
      let(:saledate) {  nil }

      it "does not show a sale completed date" do
        result = render_inline(described_class.new(current_user: coordinator_user, log: sales_log))

        expect(result).not_to have_content("Sale completed")
      end
    end
  end

  describe "what is shown dependant on ownership type" do
    context "when the ownership scheme is shared ownership" do
      let(:ownershipsch) { "1" }

      it "displayed the correct ownership type" do
        result = render_inline(described_class.new(current_user: support_user, log: sales_log))

        expect(result).to have_content("Shared ownership")
        expect(result).not_to have_content("Discounted ownership")
        expect(result).not_to have_content("Outright or other sale")
      end
    end

    context "when the ownership scheme is discounted ownership" do
      let(:ownershipsch) { "2" }

      it "displayed the correct ownership type" do
        result = render_inline(described_class.new(current_user: support_user, log: sales_log))

        expect(result).not_to have_content("Shared ownership")
        expect(result).to have_content("Discounted ownership")
        expect(result).not_to have_content("Outright or other sale")
      end
    end

    context "when the ownership scheme is outright or other sale" do
      let(:ownershipsch) { "3" }

      it "displayed the correct ownership type" do
        result = render_inline(described_class.new(current_user: support_user, log: sales_log))

        expect(result).not_to have_content("Shared ownership")
        expect(result).not_to have_content("Discounted ownership")
        expect(result).to have_content("Outright or other sale")
      end
    end
  end
end
