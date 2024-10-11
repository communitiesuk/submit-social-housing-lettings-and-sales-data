require "rails_helper"

RSpec.describe CollectionResourcesController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

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
        allow(storage_service).to receive(:file_exists?).and_return(true)
        sign_in user
      end

      it "displays collection resources" do
        get collection_resources_path

        expect(page).to have_content("Lettings 2024 to 2025")
        expect(page).to have_content("Lettings 2025 to 2026")
        expect(page).to have_content("Sales 2024 to 2025")
        expect(page).to have_content("Sales 2025 to 2026")
      end

      it "displays mandatory files" do
        get collection_resources_path

        expect(page).to have_content("Paper form")
        expect(page).to have_content("Bulk upload template")
        expect(page).to have_content("Bulk upload specification")
      end

      it "allows uploading new resources" do
        get collection_resources_path

        expect(page).to have_link("Add new sales 2024 to 2025 resource", href: new_collection_resource_path(year: 2024, log_type: "sales"))
        expect(page).to have_link("Add new lettings 2024 to 2025 resource", href: new_collection_resource_path(year: 2024, log_type: "lettings"))
        expect(page).to have_link("Add new sales 2025 to 2026 resource", href: new_collection_resource_path(year: 2025, log_type: "sales"))
        expect(page).to have_link("Add new lettings 2025 to 2026 resource", href: new_collection_resource_path(year: 2025, log_type: "lettings"))
      end

      context "when files are on S3" do
        before do
          allow(storage_service).to receive(:file_exists?).and_return(true)
          get collection_resources_path
        end

        it "displays file names with download links" do
          expect(page).to have_link("2024_25_lettings_paper_form.pdf", href: download_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "paper_form"))
          expect(page).to have_link("bulk-upload-lettings-template-2024-25.xlsx", href: download_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "bulk_upload_template"))
          expect(page).to have_link("bulk-upload-lettings-specification-2024-25.xlsx", href: download_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "bulk_upload_specification"))
          expect(page).to have_link("2024_25_sales_paper_form.pdf", href: download_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "paper_form"))
          expect(page).to have_link("bulk-upload-sales-template-2024-25.xlsx", href: download_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template"))
          expect(page).to have_link("bulk-upload-sales-specification-2024-25.xlsx", href: download_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_specification"))

          expect(page).to have_link("2025_26_lettings_paper_form.pdf", href: download_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "paper_form"))
          expect(page).to have_link("bulk-upload-lettings-template-2025-26.xlsx", href: download_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "bulk_upload_template"))
          expect(page).to have_link("bulk-upload-lettings-specification-2025-26.xlsx", href: download_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "bulk_upload_specification"))
          expect(page).to have_link("2025_26_sales_paper_form.pdf", href: download_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "paper_form"))
          expect(page).to have_link("bulk-upload-sales-template-2025-26.xlsx", href: download_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "bulk_upload_template"))
          expect(page).to have_link("bulk-upload-sales-specification-2025-26.xlsx", href: download_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "bulk_upload_specification"))
        end

        it "displays change links" do
          expect(page).to have_selector(:link_or_button, "Change", count: 12)
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "paper_form"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "bulk_upload_specification"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "paper_form"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_specification"))

          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "paper_form"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "bulk_upload_specification"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "paper_form"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Change", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "bulk_upload_specification"))
        end

        it "displays next year banner" do
          expect(page).to have_content("The 2025 to 2026 collection resources are not yet available to users.")
          expect(page).to have_link("Release the 2025 to 2026 collection resources to users", href: confirm_mandatory_collection_resources_release_path(year: 2025))
        end

        context "when there are additional resources" do
          let!(:collection_resource) { create(:collection_resource, :additional, year: 2025, short_display_name: "additional resource", download_filename: "additional.pdf") }

          it "displays change links for additional resources" do
            get collection_resources_path

            expect(page).to have_link("Change", href: collection_resource_edit_path(collection_resource))
          end
        end
      end

      context "when files are not on S3" do
        before do
          allow(storage_service).to receive(:file_exists?).and_return(false)
          get collection_resources_path
        end

        it "displays No file uploaded" do
          expect(page).to have_content("No file uploaded")
        end

        it "displays upload links" do
          expect(page).to have_selector(:link_or_button, "Upload", count: 12)
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "paper_form"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "lettings", resource_type: "bulk_upload_specification"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "paper_form"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_specification"))

          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "paper_form"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "lettings", resource_type: "bulk_upload_specification"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "paper_form"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "bulk_upload_template"))
          expect(page).to have_link("Upload", href: edit_mandatory_collection_resource_path(year: 2025, log_type: "sales", resource_type: "bulk_upload_specification"))
        end

        it "displays next year banner" do
          expect(page).to have_content("The 2025 to 2026 collection resources are not yet available to users.")
          expect(page).to have_content("Once you have uploaded all the required 2025 to 2026 collection resources, you will be able to release them to users.")
        end
      end

      context "when there are additional resources" do
        let!(:collection_resource) { create(:collection_resource, :additional, year: 2025, short_display_name: "additional resource", download_filename: "additional.pdf") }

        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2025])
          # rubocop:enable RSpec/AnyInstance
          create(:collection_resource, :additional, year: 2026, short_display_name: "additional resource 2")
        end

        it "displays additional resources for editable years" do
          get collection_resources_path

          expect(page).to have_content("additional resource")
          expect(page).not_to have_content("additional resource 2")
          expect(page).to have_link("additional.pdf", href: collection_resource_download_path(collection_resource))
          expect(page).to have_link("Delete")
        end
      end
    end
  end

  describe "GET #download_mandatory_collection_resource" do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2025, 2026])
      allow_any_instance_of(CollectionResourcesHelper).to receive(:displayed_collection_resource_years).and_return([2025])
      # rubocop:enable RSpec/AnyInstance
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      context "when the file exists on S3" do
        before do
          allow(storage_service).to receive(:get_file).and_return("file")
          get download_mandatory_collection_resource_path(log_type: "lettings", year: 2025, resource_type: "paper_form")
        end

        it "downloads the file" do
          expect(response.body).to eq("file")
        end
      end

      context "when the file does not exist on S3" do
        before do
          allow(storage_service).to receive(:get_file).and_return(nil)
          get download_mandatory_collection_resource_path(log_type: "lettings", year: 2024, resource_type: "paper_form")
        end

        it "returns page not found" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when resource isn't a mandatory resources" do
        before do
          get download_mandatory_collection_resource_path(log_type: "lettings", year: 2024, resource_type: "invalid_resource")
        end

        it "returns page not found" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when year not in displayed_collection_resource_years" do
        before do
          get download_mandatory_collection_resource_path(log_type: "lettings", year: 2026, resource_type: "paper_form")
        end

        it "returns page not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      context "when year is in editable_collection_resource_years but not in displayed_collection_resource_years" do
        before do
          allow(storage_service).to receive(:get_file).and_return("file")
          get download_mandatory_collection_resource_path(log_type: "lettings", year: 2026, resource_type: "paper_form")
        end

        it "downloads the file" do
          expect(response.status).to eq(200)
          expect(response.body).to eq("file")
        end
      end
    end
  end

  describe "GET #edit_mandatory_collection_resource" do
    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template")
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      before do
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 1, 8))
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      context "and the file exists on S3" do
        before do
          allow(storage_service).to receive(:file_exists?).and_return(true)
        end

        it "displays update collection resources page content" do
          get edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template")

          expect(page).to have_content("Sales 2024 to 2025")
          expect(page).to have_content("Change the bulk upload template")
          expect(page).to have_content("This file will be available for all users to download.")
          expect(page).to have_content("Upload file")
          expect(page).to have_button("Save changes")
          expect(page).to have_link("Back", href: collection_resources_path)
          expect(page).to have_link("Cancel", href: collection_resources_path)
        end
      end

      context "and the file does not exist on S3" do
        before do
          allow(storage_service).to receive(:file_exists?).and_return(false)
        end

        it "displays upload collection resources page content" do
          get edit_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template")

          expect(page).to have_content("Sales 2024 to 2025")
          expect(page).to have_content("Upload the bulk upload template")
          expect(page).to have_content("This file will be available for all users to download.")
          expect(page).to have_content("Upload file")
          expect(page).to have_button("Upload")
          expect(page).to have_link("Back", href: collection_resources_path)
          expect(page).to have_link("Cancel", href: collection_resources_path)
        end
      end
    end
  end

  describe "PATCH #update_mandatory_collection_resource" do
    let(:some_file) { File.open(file_fixture("blank_bulk_upload_sales.csv")) }
    let(:params) { { collection_resource: { year: 2024, log_type: "sales", resource_type: "bulk_upload_template", file: some_file } } }
    let(:collection_resource_service) { instance_double(CollectionResourcesService) }

    before do
      allow(CollectionResourcesService).to receive(:new).and_return(collection_resource_service)
    end

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        patch update_mandatory_collection_resource_path(year: 2024, log_type: "sales", resource_type: "bulk_upload_template", file: some_file)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        patch update_mandatory_collection_resource_path, params: params
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        patch update_mandatory_collection_resource_path, params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #confirm_mandatory_collection_resources_release" do
    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get confirm_mandatory_collection_resources_release_path(year: 2025)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get confirm_mandatory_collection_resources_release_path(year: 2025)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get confirm_mandatory_collection_resources_release_path(year: 2025)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2025])
        # rubocop:enable RSpec/AnyInstance
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "displays correct page content" do
        get confirm_mandatory_collection_resources_release_path(year: 2025)

        expect(page).to have_content("Are you sure you want to release the 2025 to 2026 collection resources?")
        expect(page).to have_content("The files uploaded will immediately become available for users to download.")
        expect(page).to have_content("You will not be able to undo this action.")
        expect(page).to have_button("Release the resources")
        expect(page).to have_link("Cancel", href: collection_resources_path)
        expect(page).to have_link("Back", href: collection_resources_path)
      end
    end
  end

  describe "PATCH #release_mandatory_collection_resources_path" do
    let(:some_file) { File.open(file_fixture("blank_bulk_upload_sales.csv")) }
    let(:collection_resource_service) { instance_double(CollectionResourcesService) }

    before do
      allow(CollectionResourcesService).to receive(:new).and_return(collection_resource_service)
    end

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        patch release_mandatory_collection_resources_path(year: 2024)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        patch release_mandatory_collection_resources_path(year: 2024)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        patch release_mandatory_collection_resources_path(year: 2024)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2025])
        # rubocop:enable RSpec/AnyInstance
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "saves resources as released to users" do
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true).count).to eq(0)

        patch release_mandatory_collection_resources_path(year: 2025)
        expect(CollectionResource.all.count).to eq(6)
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true, log_type: "sales", resource_type: "paper_form").count).to eq(1)
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true, log_type: "sales", resource_type: "bulk_upload_template").count).to eq(1)
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true, log_type: "sales", resource_type: "bulk_upload_specification").count).to eq(1)
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true, log_type: "lettings", resource_type: "paper_form").count).to eq(1)
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true, log_type: "lettings", resource_type: "bulk_upload_template").count).to eq(1)
        expect(CollectionResource.where(year: 2025, mandatory: true, released_to_user: true, log_type: "lettings", resource_type: "bulk_upload_specification").count).to eq(1)
        expect(response).to redirect_to(collection_resources_path)
        expect(flash[:notice]).to eq("The 2025 to 2026 collection resources are now available to users.")
      end
    end
  end

  describe "GET #new_collection_resource" do
    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get new_collection_resource_path(year: 2025, log_type: "sales")
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get new_collection_resource_path(year: 2025, log_type: "sales")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get new_collection_resource_path(year: 2025, log_type: "sales")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2025, 2026])
        # rubocop:enable RSpec/AnyInstance
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "displays new collection resource page content" do
        get new_collection_resource_path(year: 2025, log_type: "sales")

        expect(page).to have_content("Sales 2025 to 2026")
        expect(page).to have_content("Add a new collection resource")
        expect(page).to have_content("Upload file")
        expect(page).to have_button("Add resource")
        expect(page).to have_link("Back", href: collection_resources_path)
        expect(page).to have_link("Cancel", href: collection_resources_path)
      end
    end
  end

  describe "POST #collection_resources" do
    let(:some_file) { File.open(file_fixture("blank_bulk_upload_sales.csv")) }
    let(:params) { { collection_resource: { year: 2025, log_type: "sales", file: some_file, display_name: "some file" } } }

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        post collection_resources_path, params: params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        post collection_resources_path, params: params
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        post collection_resources_path, params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #download_additional_collection_resource" do
    let(:collection_resource) { create(:collection_resource, :additional, year: 2025, short_display_name: "additional resource") }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(CollectionResourcesHelper).to receive(:editable_collection_resource_years).and_return([2025, 2026])
      allow_any_instance_of(CollectionResourcesHelper).to receive(:displayed_collection_resource_years).and_return([2025])
      # rubocop:enable RSpec/AnyInstance
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      context "when the file exists on S3" do
        before do
          allow(storage_service).to receive(:get_file).and_return("file")
          get collection_resource_download_path(collection_resource)
        end

        it "downloads the file" do
          expect(response.body).to eq("file")
        end
      end

      context "when the file does not exist on S3" do
        before do
          allow(storage_service).to receive(:get_file).and_return(nil)
          get collection_resource_download_path(collection_resource)
        end

        it "returns page not found" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when resource id is invalid" do
        before do
          allow(storage_service).to receive(:get_file).and_return(nil)
          get collection_resource_download_path(collection_resource_id: "invalid")
        end

        it "returns page not found" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when year not in displayed_collection_resource_years" do
        let(:collection_resource) { create(:collection_resource, :additional, year: 2026, short_display_name: "additional resource") }

        before do
          get collection_resource_download_path(collection_resource)
        end

        it "returns page not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when user is signed in as a support user" do
      let(:collection_resource) { create(:collection_resource, :additional, year: 2026, short_display_name: "additional resource") }
      let(:user) { create(:user, :support) }

      context "when year is in editable_collection_resource_years but not in displayed_collection_resource_years" do
        before do
          allow(storage_service).to receive(:get_file).and_return("file")
          get collection_resource_download_path(collection_resource)
        end

        it "downloads the file" do
          expect(response.status).to eq(200)
          expect(response.body).to eq("file")
        end
      end
    end
  end

  describe "GET #edit_additional_collection_resource" do
    let(:collection_resource) { create(:collection_resource, :additional, year: 2025, log_type: "sales", short_display_name: "additional resource", download_filename: "additional.pdf") }

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        get collection_resource_edit_path(collection_resource)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get collection_resource_edit_path(collection_resource)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        get collection_resource_edit_path(collection_resource)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a support user" do
      let(:user) { create(:user, :support) }

      before do
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 1, 8))
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      context "and the file exists on S3" do
        before do
          allow(storage_service).to receive(:file_exists?).and_return(true)
        end

        it "displays update collection resources page content" do
          get collection_resource_edit_path(collection_resource)

          expect(page).to have_content("Sales 2025 to 2026")
          expect(page).to have_content("Change the additional resource")
          expect(page).to have_content("This file will be available for all users to download.")
          expect(page).to have_content("Upload file")
          expect(page).to have_button("Save changes")
          expect(page).to have_link("Back", href: collection_resources_path)
          expect(page).to have_link("Cancel", href: collection_resources_path)
        end
      end
    end
  end

  describe "PATCH #update_additional_collection_resource" do
    let(:some_file) { File.open(file_fixture("blank_bulk_upload_sales.csv")) }
    let(:params) { { collection_resource: { short_display_name: "short name", file: some_file } } }
    let(:collection_resource_service) { instance_double(CollectionResourcesService) }
    let(:collection_resource) { create(:collection_resource, :additional, year: 2025, log_type: "sales", short_display_name: "additional resource", download_filename: "additional.pdf") }

    before do
      allow(CollectionResourcesService).to receive(:new).and_return(collection_resource_service)
    end

    context "when user is not signed in" do
      it "redirects to the sign in page" do
        patch collection_resource_update_path(collection_resource), params: params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in as a data coordinator" do
      let(:user) { create(:user, :data_coordinator) }

      before do
        sign_in user
      end

      it "returns page not found" do
        patch collection_resource_update_path(collection_resource), params: params
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is signed in as a data provider" do
      let(:user) { create(:user, :data_provider) }

      before do
        sign_in user
      end

      it "returns page not found" do
        patch collection_resource_update_path(collection_resource), params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
