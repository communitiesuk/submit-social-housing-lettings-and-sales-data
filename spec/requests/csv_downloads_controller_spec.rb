require "rails_helper"

RSpec.describe CsvDownloadsController, type: :request do
  describe "GET #show" do
    let(:page) { Capybara::Node::Simple.new(response.body) }
    let(:csv_user) { create(:user) }
    let(:csv_download) { create(:csv_download, user: csv_user, organisation: csv_user.organisation) }
    let(:get_file_io) do
      io = StringIO.new
      io.write("hello")
      io.rewind
      io
    end
    let(:mock_storage_service) { instance_double(Storage::S3Service, get_file_io:, get_presigned_url: "https://example.com") }

    before do
      allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        get "/csv-downloads/#{csv_download.id}"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      context "and the user is from a different organisation" do
        let(:user) { create(:user) }

        before do
          get "/csv-downloads/#{csv_download.id}"
        end

        it "returns page not found" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "and is the user who generated the csv" do
        let(:user) { csv_user }

        before do
          get "/csv-downloads/#{csv_download.id}"
        end

        it "allows downloading the csv" do
          expect(response).to have_http_status(:ok)
          expect(page).to have_link("Download CSV", href: "/csv-downloads/#{csv_download.id}/download")
        end
      end

      context "and is the user is from the same organisation" do
        let(:user) { create(:user, organisation: csv_user.organisation) }

        before do
          get "/csv-downloads/#{csv_download.id}"
        end

        it "allows downloading the csv" do
          expect(response).to have_http_status(:ok)
          expect(page).to have_link("Download CSV", href: "/csv-downloads/#{csv_download.id}/download")
        end
      end
    end
  end

  describe "GET #download" do
    let(:csv_user) { create(:user) }
    let(:csv_download) { create(:csv_download, user: csv_user, organisation: csv_user.organisation) }
    let(:get_file_io) do
      io = StringIO.new
      io.write("hello")
      io.rewind
      io
    end
    let(:mock_storage_service) { instance_double(Storage::S3Service, get_file_io:, get_presigned_url: "https://example.com") }

    before do
      allow(Storage::S3Service).to receive(:new).and_return(mock_storage_service)
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        get "/csv-downloads/#{csv_download.id}/download"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      context "and the user is from a different organisation" do
        let(:user) { create(:user) }

        before do
          get "/csv-downloads/#{csv_download.id}/download"
        end

        it "returns page not found" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "and is the user who generated the csv" do
        let(:user) { csv_user }

        before do
          get "/csv-downloads/#{csv_download.id}/download"
        end

        it "allows downloading the csv" do
          expect(response).to have_http_status(:found)
        end
      end

      context "and is the user is from the same organisation" do
        let(:user) { create(:user, organisation: csv_user.organisation) }

        before do
          get "/csv-downloads/#{csv_download.id}/download"
        end

        it "allows downloading the csv" do
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
