require "rails_helper"

RSpec.describe CollectionResourcesController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "GET #index" do
    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get collection_resources_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get collection_resources_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get collection_resources_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      before do
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 1, 8))
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get collection_resources_path
      end

      it "displays collection resources" do
        expect(page).to have_content("Lettings 2024 to 2025")
        expect(page).to have_content("Lettings 2025 to 2026")
        expect(page).to have_content("Sales 2024 to 2025")
        expect(page).to have_content("Sales 2025 to 2026")
      end

      it "displays mandatory filed" do
        expect(page).to have_content("Paper form")
        expect(page).to have_content("Bulk upload template")
        expect(page).to have_content("Bulk upload specification")
      end

      context "when files are on S3" do
        it "displays file names with download links" do
          expect(page).to have_link("2024_25_lettings_paper_form.pdf", href: download_24_25_lettings_form_path)
          expect(page).to have_link("bulk-upload-lettings-template-2024-25.xlsx", href: download_24_25_lettings_bulk_upload_template_path)
          expect(page).to have_link("bulk-upload-lettings-specification-2024-25.xlsx", href: download_24_25_lettings_bulk_upload_specification_path)
          expect(page).to have_link("2024_25_sales_paper_form.pdf", href: download_24_25_sales_form_path)
          expect(page).to have_link("bulk-upload-sales-template-2024-25.xlsx", href: download_24_25_sales_bulk_upload_template_path)
          expect(page).to have_link("bulk-upload-sales-specification-2024-25.xlsx", href: download_24_25_sales_bulk_upload_specification_path)

          expect(page).to have_link("2025_26_lettings_paper_form.pdf", href: download_25_26_lettings_form_path)
          expect(page).to have_link("bulk-upload-lettings-template-2025-26.xlsx", href: download_25_26_lettings_bulk_upload_template_path)
          expect(page).to have_link("bulk-upload-lettings-specification-2025-26.xlsx", href: download_25_26_lettings_bulk_upload_specification_path)
          expect(page).to have_link("2025_26_sales_paper_form.pdf", href: download_25_26_sales_form_path)
          expect(page).to have_link("bulk-upload-sales-template-2025-26.xlsx", href: download_25_26_sales_bulk_upload_template_path)
          expect(page).to have_link("bulk-upload-sales-specification-2025-26.xlsx", href: download_25_26_sales_bulk_upload_specification_path)
        end

        it "displays change links" do
          expect(page).to have_selector(:link_or_button, "Change", count: 12)
        end
      end
    end
  end
end
