require "rails_helper"

RSpec.describe SchemesController, type: :request do
  let(:organisation) { user.organisation }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :support) }
  let!(:schemes) { FactoryBot.create_list(:scheme, 5) }

  describe "#index" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/supported-housing"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a support user" do
      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/supported-housing"
      end

      it "has page heading" do
        expect(page).to have_content("Supported housing services")
      end

      it "shows all schemes" do
        schemes.each do |scheme|
          expect(page).to have_content(scheme.code)
        end
      end

      it "shows a search bar" do
        expect(page).to have_field("search", type: "search")
      end

      it "has correct title" do
        expect(page).to have_title("Supported housing services - Submit social housing lettings and sales data (CORE) - GOV.UK")
      end
    end

    context "when signed in as a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:same_org_scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }

      before do
        sign_in user
        get "/supported-housing"
      end

      it "has page heading" do
        expect(page).to have_content("Supported housing services")
      end

      it "shows only schemes belonging to the same organisation" do
        expect(page).to have_content(same_org_scheme.code)
        schemes.each do |scheme|
          expect(page).not_to have_content(scheme.code)
        end
      end

      it "shows a search bar" do
        expect(page).to have_field("search", type: "search")
      end
    end
  end
end
