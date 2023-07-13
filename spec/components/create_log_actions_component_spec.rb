require "rails_helper"

RSpec.describe CreateLogActionsComponent, type: :component do
  include GovukComponentsHelper
  include GovukLinkHelper
  let(:component) { described_class.new(user:, log_type:, bulk_upload:) }
  let(:render) { render_inline(component) }

  let(:log_type) { "lettings" }
  let(:user) { create(:user) }

  context "when bulk upload present" do
    let(:bulk_upload) { true }

    it "does not render actions" do
      expect(component.display_actions?).to eq(false)
    end
  end

  context "when bulk upload nil" do
    let(:bulk_upload) { nil }

    context "when support user" do
      let(:user) { create(:user, :support) }

      it "renders actions" do
        expect(component.display_actions?).to eq(true)
      end

      it "returns create button copy" do
        expect(component.create_button_copy).to eq("Create a new lettings log")
      end

      it "returns create button href" do
        render
        expect(component.create_button_href).to eq("/lettings-logs")
      end

      it "returns upload button copy" do
        expect(component.upload_button_copy).to eq("Upload lettings logs in bulk")
      end

      it "returns upload button href" do
        render
        expect(component.upload_button_href).to eq("/lettings-logs/bulk-upload-logs/start")
      end

      context "when sales log type" do
        let(:log_type) { "sales" }

        it "renders actions" do
          expect(component.display_actions?).to eq(true)
        end

        it "returns create button copy" do
          expect(component.create_button_copy).to eq("Create a new sales log")
        end

        it "returns create button href" do
          render
          expect(component.create_button_href).to eq("/sales-logs")
        end
      end
    end

    context "when not support user" do
      context "without data sharing agreement" do
        let(:user) { create(:user, organisation: create(:organisation, :without_dpc)) }

        it "does not render actions" do
          expect(component).not_to be_display_actions
        end
      end

      context "when has data sharing agremeent" do
        let(:user) { create(:user, :support) }

        it "renders actions" do
          expect(component.display_actions?).to eq(true)
        end

        it "returns create button copy" do
          expect(component.create_button_copy).to eq("Create a new lettings log")
        end

        it "returns create button href" do
          render
          expect(component.create_button_href).to eq("/lettings-logs")
        end

        it "returns upload button copy" do
          expect(component.upload_button_copy).to eq("Upload lettings logs in bulk")
        end

        it "returns upload button href" do
          render
          expect(component.upload_button_href).to eq("/lettings-logs/bulk-upload-logs/start")
        end

        context "when sales log type" do
          let(:log_type) { "sales" }

          it "renders actions" do
            expect(component.display_actions?).to eq(true)
          end

          it "returns create button copy" do
            expect(component.create_button_copy).to eq("Create a new sales log")
          end

          it "returns create button href" do
            render
            expect(component.create_button_href).to eq("/sales-logs")
          end
        end
      end
    end
  end
end
