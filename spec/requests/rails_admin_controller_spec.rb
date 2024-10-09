require "rails_helper"

RSpec.describe "RailsAdmin", type: :request do
  let(:user) { create(:user) }
  let(:support_user) { create(:user, :support) }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:storage_service) { instance_double(Storage::S3Service) }

  before do
    allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  describe "GET /admin" do
    context "when the user is not signed in" do
      it "routes user to the sign in page" do
        get rails_admin_path
        follow_redirect!
        expect(path).to eq("/account/sign-in")
        expect(page).to have_content("Sign in to your account")
      end
    end

    context "when the user is signed in as a non support user" do
      before do
        sign_in user
      end

      it "routes user to the home page" do
        get rails_admin_path
        follow_redirect!
        expect(path).to eq("/")
        expect(page).to have_content("Welcome back")
      end
    end

    context "when the user is signed in as a support user" do
      before do
        sign_in support_user
      end

      it "routes user to the admin page" do
        get rails_admin_path
        expect(page).to have_content("Site Administration")
      end
    end
  end
end
