require "rails_helper"

RSpec.describe CreateLogActionsComponent, type: :component do
  include GovukComponentsHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper
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

      it "does not show the upload button" do
        render_inline(component)
        expect(rendered_content).not_to have_link("Upload lettings logs in bulk", href: "/lettings-logs/bulk-upload-logs/start")
      end

      it "returns view uploads button copy" do
        expect(component.view_uploads_button_copy).to eq("View lettings bulk uploads")
      end

      it "returns view uploads button href" do
        render
        expect(component.view_uploads_button_href).to eq("/lettings-logs/bulk-uploads")
      end

      it "shows the view uploads button" do
        render_inline(component)
        expect(rendered_content).to have_link("View lettings bulk uploads", href: "/lettings-logs/bulk-uploads")
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

        it "does not show the upload button" do
          render_inline(component)
          expect(rendered_content).not_to have_link("Upload sales logs in bulk", href: "/sales-logs/bulk-upload-logs/start")
        end

        it "shows the view uploads button" do
          render_inline(component)
          expect(rendered_content).to have_link("View sales bulk uploads", href: "/sales-logs/bulk-uploads")
        end
      end
    end

    context "when not support user" do
      context "without data sharing agreement" do
        let(:user) { create(:user, organisation: create(:organisation, :without_dpc), with_dsa: false) }

        it "does not render actions" do
          expect(component).not_to be_display_actions
        end
      end

      context "when has data sharing agremeent" do
        let(:user) { create(:user) }

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

        context "when organisation doesn't own stock" do
          before do
            user.organisation.update!(holds_own_stock: false)
          end

          context "and has signed DSA and stock owners have signed DSA" do
            before do
              parent_organisation = create(:organisation)
              create(:organisation_relationship, child_organisation: user.organisation, parent_organisation:)
            end

            it "renders actions" do
              expect(component.display_actions?).to eq(true)
            end
          end

          context "and hasn't signed DSA and and stock owners have signed DSA" do
            before do
              user.organisation.data_protection_confirmation.update!(confirmed: false)
              parent_organisation = create(:organisation)
              create(:organisation_relationship, child_organisation: user.organisation, parent_organisation:)
            end

            it "renders actions" do
              expect(component.display_actions?).to eq(false)
            end
          end

          context "and no stock owners have signed data sharing agreement" do
            before do
              parent_organisation = create(:organisation, :without_dpc)
              create(:organisation_relationship, child_organisation: user.organisation, parent_organisation:)
            end

            it "does not render actions" do
              expect(component.display_actions?).to eq(false)
            end
          end
        end
      end
    end
  end
end
