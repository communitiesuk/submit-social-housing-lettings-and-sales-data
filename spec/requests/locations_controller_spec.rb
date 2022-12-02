require "rails_helper"

RSpec.describe LocationsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :support) }
  let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  describe "#new" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/new"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/new"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/new"
      end

      it "creates a new location for scheme and redirects to correct page" do
        expect { get "/schemes/#{scheme.id}/locations/new" }.to change(Location, :count).by(1)
      end

      it "redirects to the postcode page" do
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the postcode?")
      end

      it "creates a new location for scheme with the right owning organisation" do
        expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
      end

      context "when trying to add a new location to a scheme that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/new"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/new"
      end

      it "creates a new location for scheme and redirects to correct page" do
        expect { get "/schemes/#{scheme.id}/locations/new" }.to change(Location, :count).by(1)
      end

      it "redirects to the postcode page" do
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the postcode?")
      end

      it "creates a new location for scheme with the right owning organisation" do
        expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
      end

      context "when trying to add a new location to a scheme that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/new"
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#index" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/#{scheme.id}/locations"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:locations) { FactoryBot.create_list(:location, 3, scheme:, startdate: Time.zone.local(2022, 4, 1)) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations"
      end

      context "when coordinator attempts to see scheme belonging to a different organisation" do
        let!(:another_scheme) { FactoryBot.create(:scheme) }

        before do
          FactoryBot.create(:location, scheme:, startdate: Time.zone.local(2022, 4, 1))
        end

        it "returns 404 not found" do
          get "/schemes/#{another_scheme.id}/locations"
          expect(response).to have_http_status(:not_found)
        end
      end

      it "shows locations with correct data wben the new locations layout feature toggle is enabled" do
        locations.each do |location|
          expect(page).to have_content(location.id)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.name)
          expect(page).to have_content(location.status)
        end
      end

      it "shows locations with correct data wben the new locations layout feature toggle is disabled" do
        allow(FeatureToggle).to receive(:location_toggle_enabled?).and_return(false)
        get "/schemes/#{scheme.id}/locations"
        locations.each do |location|
          expect(page).to have_content(location.id)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.type_of_unit)
          expect(page).to have_content(location.mobility_type)
          expect(page).to have_content(location.location_admin_district)
          expect(page).to have_content(location.startdate&.to_formatted_s(:govuk_date))
        end
      end

      it "has page heading" do
        expect(page).to have_content(scheme.service_name)
      end

      it "has correct title" do
        expected_title = CGI.escapeHTML("#{scheme.service_name} - Submit social housing lettings and sales data (CORE) - GOV.UK")
        expect(page).to have_title(expected_title)
      end

      context "when paginating over 20 results" do
        let!(:locations) { FactoryBot.create_list(:location, 25, scheme:) }

        context "when on the first page" do
          before do
            get "/schemes/#{scheme.id}/locations"
          end

          it "shows which schemes are being shown on the current page" do
            expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>#{locations.count}</b> locations")
          end

          it "has correct page 1 of 2 title" do
            expected_title = CGI.escapeHTML("#{scheme.service_name} (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            expect(page).to have_title(expected_title)
          end

          it "has pagination links" do
            expect(page).not_to have_content("Previous")
            expect(page).not_to have_link("Previous")
            expect(page).to have_content("Next")
            expect(page).to have_link("Next")
          end
        end

        context "when on the second page" do
          before do
            get "/schemes/#{scheme.id}/locations?page=2"
          end

          it "shows which schemes are being shown on the current page" do
            expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>25</b> of <b>#{locations.count}</b> locations")
          end

          it "has correct page 2 of 2 title" do
            expected_title = CGI.escapeHTML("#{scheme.service_name} (page 2 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            expect(page).to have_title(expected_title)
          end

          it "has pagination links" do
            expect(page).to have_content("Previous")
            expect(page).to have_link("Previous")
            expect(page).not_to have_content("Next")
            expect(page).not_to have_link("Next")
          end
        end
      end

      context "when searching" do
        let(:searched_location) { locations.first }
        let(:search_param) { searched_location.name }

        before do
          get "/schemes/#{scheme.id}/locations?search=#{search_param}"
        end

        it "returns matching results" do
          expect(page).to have_content(searched_location.name)
          locations[1..].each do |location|
            expect(page).not_to have_content(location.name)
          end
        end

        it "updates the table caption" do
          expect(page).to have_content("1 location found matching ‘#{search_param}’")
        end

        it "has search in the title" do
          expected_title = CGI.escapeHTML("#{scheme.service_name} (1 location matching ‘#{search_param}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
          expect(page).to have_title(expected_title)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }
      let!(:locations) { FactoryBot.create_list(:location, 3, scheme:, startdate: Time.zone.local(2022, 4, 1)) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations"
      end

      it "shows locations with correct data wben the new locations layout feature toggle is enabled" do
        locations.each do |location|
          expect(page).to have_content(location.id)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.name)
          expect(page).to have_content(location.status)
        end
      end

      it "shows locations with correct data wben the new locations layout feature toggle is disabled" do
        allow(FeatureToggle).to receive(:location_toggle_enabled?).and_return(false)
        get "/schemes/#{scheme.id}/locations"
        locations.each do |location|
          expect(page).to have_content(location.id)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.type_of_unit)
          expect(page).to have_content(location.mobility_type)
          expect(page).to have_content(location.location_admin_district)
          expect(page).to have_content(location.startdate&.to_formatted_s(:govuk_date))
        end
      end

      it "has page heading" do
        expect(page).to have_content(scheme.service_name)
      end

      it "has correct title" do
        expected_title = CGI.escapeHTML("#{scheme.service_name} - Submit social housing lettings and sales data (CORE) - GOV.UK")
        expect(page).to have_title(expected_title)
      end

      context "when paginating over 20 results" do
        let!(:locations) { FactoryBot.create_list(:location, 25, scheme:) }

        context "when on the first page" do
          before do
            get "/schemes/#{scheme.id}/locations"
          end

          it "shows which schemes are being shown on the current page" do
            expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>#{locations.count}</b> locations")
          end

          it "has correct page 1 of 2 title" do
            expected_title = CGI.escapeHTML("#{scheme.service_name} (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            expect(page).to have_title(expected_title)
          end

          it "has pagination links" do
            expect(page).not_to have_content("Previous")
            expect(page).not_to have_link("Previous")
            expect(page).to have_content("Next")
            expect(page).to have_link("Next")
          end
        end

        context "when on the second page" do
          before do
            get "/schemes/#{scheme.id}/locations?page=2"
          end

          it "shows which schemes are being shown on the current page" do
            expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>25</b> of <b>#{locations.count}</b> locations")
          end

          it "has correct page 1 of 2 title" do
            expected_title = CGI.escapeHTML("#{scheme.service_name} (page 2 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            expect(page).to have_title(expected_title)
          end

          it "has pagination links" do
            expect(page).to have_content("Previous")
            expect(page).to have_link("Previous")
            expect(page).not_to have_content("Next")
            expect(page).not_to have_link("Next")
          end
        end
      end

      context "when searching" do
        let(:searched_location) { locations.first }
        let(:search_param) { searched_location.name }

        before do
          get "/schemes/#{scheme.id}/locations?search=#{search_param}"
        end

        it "returns matching results" do
          expect(page).to have_content(searched_location.name)
          locations[1..].each do |location|
            expect(page).not_to have_content(location.name)
          end
        end

        it "updates the table caption" do
          expect(page).to have_content("1 location found matching ‘#{search_param}’")
        end

        it "has search in the title" do
          expected_title = CGI.escapeHTML("#{scheme.service_name} (1 location matching ‘#{search_param}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
          expect(page).to have_title(expected_title)
        end
      end
    end
  end

  describe "#postcode" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/postcode"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/postcode"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/postcode"
      end

      it "returns a template for a postcode" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the postcode?")
      end

      context "when postcode is submitted with lower case" do
        let(:params) { { location: { postcode: "zz1 1zz" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/postcode", params:
        end

        it "adds postcode to location" do
          expect(Location.last.postcode).to eq("ZZ1 1ZZ")
        end

        it "redirects correctly when postcodes.io does return a local authority" do
          follow_redirect!
          expect(page).to have_content("What is the name of this location?")
        end
      end

      context "when postcodes.io does not return a local authority" do
        let(:params) { { location: { postcode: "xx1 1xx" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/postcode", params:
        end

        it "adds postcode to location" do
          expect(Location.last.postcode).to eq("XX11XX")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What is the local authority")
        end
      end

      context "when trying to edit postcode of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/postcode"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/postcode"
      end

      it "returns a template for a postcode" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the postcode?")
      end

      context "when postcode is submitted with lower case" do
        let(:params) { { location: { postcode: "zz1 1zz" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/postcode", params:
        end

        it "adds postcode to location" do
          expect(Location.last.postcode).to eq("ZZ1 1ZZ")
        end

        it "redirects correctly when postcodes.io does return a local authority" do
          follow_redirect!
          expect(page).to have_content("What is the name of this location?")
        end
      end

      context "when postcodes.io does not return a local authority" do
        let(:params) { { location: { postcode: "xx1 1xx" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/postcode", params:
        end

        it "adds postcode to location" do
          expect(Location.last.postcode).to eq("XX11XX")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What is the local authority")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#local_authority" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/local-authority"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/local-authority"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/local-authority"
      end

      it "returns a template for a local authority" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the local authority")
      end

      context "when local authority is submitted" do
        let(:params) { { location: { location_admin_district: "Adur" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/local-authority", params:
        end

        it "adds local authority to location " do
          expect(Location.last.location_admin_district).to eq("Adur")
          expect(Location.last.location_code).to eq("E07000223")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What is the name of this location?")
        end
      end

      context "when trying to edit local authority of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/local-authority"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/local-authority"
      end

      it "returns a template for a local authority" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the local authority")
      end

      context "when local authority is submitted" do
        let(:params) { { location: { location_admin_district: "Adur" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/local-authority", params:
        end

        it "adds local authority to location " do
          expect(Location.last.location_admin_district).to eq("Adur")
          expect(Location.last.location_code).to eq("E07000223")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What is the name of this location?")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#name" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/name"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/name"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/name"
      end

      it "returns a template for a name" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the name of this location?")
      end

      context "when name is submitted" do
        let(:params) { { location: { name: "a name" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/name", params:
        end

        it "adds name to location" do
          expect(Location.last.name).to eq("a name")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("How many units are at this location?")
        end
      end

      context "when trying to edit name of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/name"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/name"
      end

      it "returns a template for a name" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the name of this location?")
      end

      context "when name is submitted" do
        let(:params) { { location: { name: "a name" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/name", params:
        end

        it "adds name to location" do
          expect(Location.last.name).to eq("a name")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("How many units are at this location?")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#units" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/units"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/units"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/units"
      end

      it "returns a template for units" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("How many units are at this location?")
      end

      context "when units is submitted" do
        let(:params) { { location: { units: 6 } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/units", params:
        end

        it "adds units to location" do
          expect(Location.last.units).to eq(6)
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What is the most common type of unit at this location?")
        end
      end

      context "when trying to edit units of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/units"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/units"
      end

      it "returns a template for units" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("How many units are at this location?")
      end

      context "when units is submitted" do
        let(:params) { { location: { units: 6 } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/units", params:
        end

        it "adds units to location" do
          expect(Location.last.units).to eq(6)
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What is the most common type of unit at this location?")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#type_of_unit" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/type-of-unit"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/type-of-unit"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/type-of-unit"
      end

      it "returns a template for type of unit" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the most common type of unit at this location?")
      end

      context "when type of unit is submitted" do
        let(:params) { { location: { type_of_unit: "Bungalow" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/type-of-unit", params:
        end

        it "adds type of unit to location" do
          expect(Location.last.type_of_unit).to eq("Bungalow")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What are the mobility standards for the majority of units in this location?")
        end
      end

      context "when trying to edit type_of_unit of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/type-of-unit"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/type-of-unit"
      end

      it "returns a template for type of unit" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the most common type of unit at this location?")
      end

      context "when type of unit is submitted" do
        let(:params) { { location: { type_of_unit: "Bungalow" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/type-of-unit", params:
        end

        it "adds type of unit to location" do
          expect(Location.last.type_of_unit).to eq("Bungalow")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("What are the mobility standards for the majority of units in this location?")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#mobility_standards" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/mobility-standards"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/mobility-standards"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/mobility-standards"
      end

      it "returns a template for mobility standards" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What are the mobility standards for the majority of units in this location?")
      end

      context "when mobility standards is submitted" do
        let(:params) { { location: { mobility_type: "Wheelchair-user standard" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/mobility-standards", params:
        end

        it "adds mobility standards to location" do
          expect(Location.last.mobility_type).to eq("Wheelchair-user standard")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("When did the first property in this location become available under this scheme?")
        end
      end

      context "when trying to edit mobility_standards of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/mobility-standards"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/mobility-standards"
      end

      it "returns a template for mobility standards" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What are the mobility standards for the majority of units in this location?")
      end

      context "when mobility standards is submitted" do
        let(:params) { { location: { mobility_type: "Wheelchair-user standard" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/mobility-standards", params:
        end

        it "adds mobility standards to location" do
          expect(Location.last.mobility_type).to eq("Wheelchair-user standard")
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("When did the first property in this location become available under this scheme?")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#startdate" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/availability"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/availability"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/availability"
      end

      it "returns a template for a startdate" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("When did the first property in this location become available under this scheme?")
      end

      context "when startdate is submitted" do
        let(:params) { { location: { "startdate(1i)": "2000", "startdate(2i)": "1", "startdate(3i)": "2" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/availability", params:
        end

        it "adds startdate to location" do
          expect(Location.last.startdate).to eq(Time.zone.local(2000, 1, 2))
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("Check your answers")
        end
      end

      context "when startdate is submitted with leading zeroes" do
        let(:params) { { location: { "startdate(1i)": "2000", "startdate(2i)": "01", "startdate(3i)": "02" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/availability", params:
        end

        it "adds startdate correctly " do
          expect(Location.last.startdate).to eq(Time.zone.local(2000, 1, 2))
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("Check your answers")
        end
      end

      context "when startdate is missing" do
        let(:params) { { location: { "startdate(1i)": "", "startdate(2i)": "", "startdate(3i)": "" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/availability", params:
        end

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.startdate_blank"))
        end
      end

      context "when trying to edit startdate of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/availability"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/availability"
      end

      it "returns a template for a startdate" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("When did the first property in this location become available under this scheme?")
      end

      context "when startdate is submitted" do
        let(:params) { { location: { "startdate(1i)": "2000", "startdate(2i)": "1", "startdate(3i)": "2" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/availability", params:
        end

        it "adds startdate to location" do
          expect(Location.last.startdate).to eq(Time.zone.local(2000, 1, 2))
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("Check your answers")
        end
      end

      context "when startdate is submitted with leading zeroes" do
        let(:params) { { location: { "startdate(1i)": "2000", "startdate(2i)": "01", "startdate(3i)": "02" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/availability", params:
        end

        it "adds startdate correctly " do
          expect(Location.last.startdate).to eq(Time.zone.local(2000, 1, 2))
        end

        it "redirects correctly" do
          follow_redirect!
          expect(page).to have_content("Check your answers")
        end
      end

      context "when startdate is missing" do
        let(:params) { { location: { "startdate(1i)": "", "startdate(2i)": "", "startdate(3i)": "" } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/availability", params:
        end

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.startdate_blank"))
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#check_answers" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/check-answers"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/check-answers"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/check-answers"
      end

      it "returns the check answers page" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your answers")
      end

      context "when location is confirmed" do
        let(:params) { { location: { confirmed: true } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/check-answers", params:
        end

        it "confirms location" do
          expect(Location.last.confirmed).to eq(true)
        end

        it "redirects correctly and displays success banner" do
          follow_redirect!
          expect(page).to have_content("Success")
          expect(page).to have_content("added to this scheme")
        end
      end

      context "when trying to edit check_answers of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/check-answers"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/#{location.id}/check-answers"
      end

      it "returns the check answers page" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your answers")
      end

      context "when location is confirmed" do
        let(:params) { { location: { confirmed: true } } }

        before do
          patch "/schemes/#{scheme.id}/locations/#{location.id}/check-answers", params:
        end

        it "confirms location" do
          expect(Location.last.confirmed).to eq(true)
        end

        it "redirects correctly and displays success banner" do
          follow_redirect!
          expect(page).to have_content("Success")
          expect(page).to have_content("added to this scheme")
        end
      end

      context "when the requested location does not exist" do
        let(:location) { OpenStruct.new(id: (Location.maximum(:id) || 0) + 1, scheme:) }

        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "#deactivate" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        patch "/schemes/1/locations/1/deactivate"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        patch "/schemes/1/locations/1/deactivate"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:, startdate: nil, created_at: Time.zone.local(2022, 4, 1)) }
      let(:deactivation_date) { Time.utc(2022, 10, 10) }
      let!(:lettings_log) { FactoryBot.create(:lettings_log, :sh, location:, scheme:, startdate:, owning_organisation: user.organisation) }
      let(:startdate) { Time.utc(2022, 10, 11) }
      let(:add_deactivations) { nil }
      let(:setup_locations) { nil }

      before do
        Timecop.freeze(Time.utc(2022, 10, 10))
        sign_in user
        add_deactivations
        setup_locations
        location.save!
        patch "/schemes/#{scheme.id}/locations/#{location.id}/new-deactivation", params:
      end

      after do
        Timecop.unfreeze
      end

      context "with default date" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "default", deactivation_date: } } }

        context "and affected logs" do
          it "redirects to the confirmation page" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("This change will affect 1 logs")
          end
        end

        context "and no affected logs" do
          let(:setup_locations) { location.lettings_logs.update(location: nil) }

          it "redirects to the location page and updates the deactivation period" do
            follow_redirect!
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
            location.reload
            expect(location.location_deactivation_periods.count).to eq(1)
            expect(location.location_deactivation_periods.first.deactivation_date).to eq(Time.zone.local(2022, 4, 1))
          end
        end
      end

      context "with other date" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "10", "deactivation_date(2i)": "10", "deactivation_date(1i)": "2022" } } }

        context "and affected logs" do
          it "redirects to the confirmation page" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("This change will affect #{location.lettings_logs.count} logs")
          end
        end

        context "and no affected logs" do
          let(:setup_locations) { location.lettings_logs.update(location: nil) }

          it "redirects to the location page and updates the deactivation period" do
            follow_redirect!
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
            location.reload
            expect(location.location_deactivation_periods.count).to eq(1)
            expect(location.location_deactivation_periods.first.deactivation_date).to eq(Time.zone.local(2022, 10, 10))
          end
        end
      end

      context "when confirming deactivation" do
        let(:params) { { deactivation_date:, confirm: true, deactivation_date_type: "other" } }

        before do
          Timecop.freeze(Time.utc(2022, 10, 10))
          sign_in user
          patch "/schemes/#{scheme.id}/locations/#{location.id}/deactivate", params:
        end

        after do
          Timecop.unfreeze
        end

        it "updates existing location with valid deactivation date and renders location page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
          location.reload
          expect(location.location_deactivation_periods.count).to eq(1)
          expect(location.location_deactivation_periods.first.deactivation_date).to eq(deactivation_date)
        end

        context "and a log startdate is after location deactivation date" do
          it "clears the location and scheme answers" do
            expect(lettings_log.location).to eq(location)
            expect(lettings_log.scheme).to eq(scheme)
            lettings_log.reload
            expect(lettings_log.location).to eq(nil)
            expect(lettings_log.scheme).to eq(nil)
          end
        end

        context "and a log startdate is before location deactivation date" do
          let(:startdate) { Time.utc(2022, 10, 9) }

          it "does not update the log" do
            expect(lettings_log.location).to eq(location)
            expect(lettings_log.scheme).to eq(scheme)
            lettings_log.reload
            expect(lettings_log.location).to eq(location)
            expect(lettings_log.scheme).to eq(scheme)
          end
        end
      end

      context "when the date is not selected" do
        let(:params) { { location_deactivation_period: { "deactivation_date": "" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.not_selected"))
        end
      end

      context "when invalid date is entered" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "10", "deactivation_date(2i)": "44", "deactivation_date(1i)": "2022" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the date is entered is before the beginning of current collection window" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "10", "deactivation_date(2i)": "4", "deactivation_date(1i)": "2020" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.out_of_range", date: "1 April 2022"))
        end
      end

      context "when the day is not entered" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "", "deactivation_date(2i)": "2", "deactivation_date(1i)": "2022" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the month is not entered" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "2", "deactivation_date(2i)": "", "deactivation_date(1i)": "2022" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the year is not entered" do
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "2", "deactivation_date(2i)": "2", "deactivation_date(1i)": "" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when deactivation date is during a deactivated period" do
        let(:deactivation_date) { Time.zone.local(2022, 10, 10) }
        let(:params) { { location_deactivation_period: { deactivation_date_type: "other", "deactivation_date(3i)": "8", "deactivation_date(2i)": "9", "deactivation_date(1i)": "2022" } } }
        let(:add_deactivations) { FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 10, 12), location:) }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.deactivation.during_deactivated_period"))
        end
      end
    end
  end

  describe "#show" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:, startdate: nil) }
      let(:add_deactivations) { location.location_deactivation_periods << location_deactivation_period }

      before do
        Timecop.freeze(Time.utc(2022, 10, 10))
        sign_in user
        add_deactivations
        location.save!
        get "/schemes/#{scheme.id}/locations/#{location.id}"
      end

      after do
        Timecop.unfreeze
      end

      context "with active location" do
        let(:add_deactivations) {}

        it "renders deactivate this location" do
          expect(response).to have_http_status(:ok)
          expect(page).to have_link("Deactivate this location", href: "/schemes/#{scheme.id}/locations/#{location.id}/new-deactivation")
        end
      end

      context "with deactivated location" do
        let(:location_deactivation_period) { FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 10, 9), location:) }

        it "renders reactivate this location" do
          expect(response).to have_http_status(:ok)
          expect(page).to have_link("Reactivate this location", href: "/schemes/#{scheme.id}/locations/#{location.id}/new-reactivation")
        end
      end

      context "with location that's deactivating soon" do
        let(:location_deactivation_period) { FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 10, 12), location:) }

        it "renders reactivate this location" do
          expect(response).to have_http_status(:ok)
          expect(page).to have_link("Reactivate this location", href: "/schemes/#{scheme.id}/locations/#{location.id}/new-reactivation")
        end
      end

      context "with location that's reactivating soon" do
        let(:location_deactivation_period) { FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 4, 12), reactivation_date: Time.zone.local(2022, 10, 12), location:) }

        it "renders reactivate this location" do
          expect(response).to have_http_status(:ok)
          expect(page).to have_link("Deactivate this location", href: "/schemes/#{scheme.id}/locations/#{location.id}/new-deactivation")
        end
      end
    end
  end

  describe "#reactivate" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        patch "/schemes/1/locations/1/reactivate"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        patch "/schemes/1/locations/1/reactivate"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location) { FactoryBot.create(:location, scheme:, startdate: nil) }
      let(:deactivation_date) { Time.zone.local(2022, 4, 1) }
      let(:startdate) { Time.utc(2022, 10, 11) }

      before do
        Timecop.freeze(Time.utc(2022, 10, 10))
        sign_in user
        FactoryBot.create(:location_deactivation_period, deactivation_date:, location:)
        location.save!
        patch "/schemes/#{scheme.id}/locations/#{location.id}/reactivate", params:
      end

      after do
        Timecop.unfreeze
      end

      context "with default date" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "default" } } }

        it "redirects to the location page and displays a success banner" do
          expect(response).to redirect_to("/schemes/#{scheme.id}/locations/#{location.id}")
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
          expect(page).to have_content("#{location.name} has been reactivated")
        end

        it "updates existing location deactivations with valid reactivation date" do
          follow_redirect!
          location.reload
          expect(location.location_deactivation_periods.count).to eq(1)
          expect(location.location_deactivation_periods.first.reactivation_date).to eq(Time.zone.local(2022, 4, 1))
        end
      end

      context "with other date" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "10", "reactivation_date(2i)": "10", "reactivation_date(1i)": "2022" } } }

        it "redirects to the location page and displays a success banner" do
          expect(response).to redirect_to("/schemes/#{scheme.id}/locations/#{location.id}")
          follow_redirect!
          expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
          expect(page).to have_content("#{location.name} has been reactivated")
        end

        it "updates existing location deactivations with valid reactivation date" do
          follow_redirect!
          location.reload
          expect(location.location_deactivation_periods.count).to eq(1)
          expect(location.location_deactivation_periods.first.reactivation_date).to eq(Time.zone.local(2022, 10, 10))
        end
      end

      context "with other future date" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "14", "reactivation_date(2i)": "12", "reactivation_date(1i)": "2022" } } }

        it "redirects to the location page and displays a success banner" do
          expect(response).to redirect_to("/schemes/#{scheme.id}/locations/#{location.id}")
          follow_redirect!
          expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
          expect(page).to have_content("#{location.name} will reactivate on 14 December 2022")
        end
      end

      context "when the date is not selected" do
        let(:params) { { location_deactivation_period: { "reactivation_date": "" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.not_selected"))
        end
      end

      context "when invalid date is entered" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "10", "reactivation_date(2i)": "44", "reactivation_date(1i)": "2022" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the date is entered is before the beginning of current collection window" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "10", "reactivation_date(2i)": "4", "reactivation_date(1i)": "2020" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.out_of_range", date: "1 April 2022"))
        end
      end

      context "when the day is not entered" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "", "reactivation_date(2i)": "2", "reactivation_date(1i)": "2022" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the month is not entered" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "2", "reactivation_date(2i)": "", "reactivation_date(1i)": "2022" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the year is not entered" do
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "2", "reactivation_date(2i)": "2", "reactivation_date(1i)": "" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.toggle_date.invalid"))
        end
      end

      context "when the reactivation date is before deactivation date" do
        let(:deactivation_date) { Time.zone.local(2022, 10, 10) }
        let(:params) { { location_deactivation_period: { reactivation_date_type: "other", "reactivation_date(3i)": "8", "reactivation_date(2i)": "9", "reactivation_date(1i)": "2022" } } }

        it "displays page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.location.reactivation.before_deactivation", date: "10 October 2022"))
        end
      end
    end
  end
end
