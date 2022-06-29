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
        get "/schemes"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }

      before do
        sign_in user
        get "/schemes"
      end

      it "redirects to the organisation schemes path" do
        follow_redirect!
        expect(path).to match("/organisations/#{user.organisation.id}/schemes")
      end
    end

    context "when signed in as a support user" do
      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes"
      end

      it "has page heading" do
        expect(page).to have_content("Schemes")
      end

      it "shows all schemes" do
        schemes.each do |scheme|
          expect(page).to have_content(scheme.id)
        end
      end

      it "shows a search bar" do
        expect(page).to have_field("search", type: "search")
      end

      it "has correct title" do
        expect(page).to have_title("Supported housing schemes - Submit social housing lettings and sales data (CORE) - GOV.UK")
      end

      it "shows the total organisations count" do
        expect(CGI.unescape_html(response.body)).to match("<strong>#{schemes.count}</strong> total schemes.")
      end

      it "has hidden accebility field with description" do
        expected_field = "<h2 class=\"govuk-visually-hidden\">Supported housing schemes</h2>"
        expect(CGI.unescape_html(response.body)).to include(expected_field)
      end

      context "when paginating over 20 results" do
        let(:total_schemes_count) { Scheme.count }

        before do
          FactoryBot.create_list(:scheme, 20)
        end

        context "when on the first page" do
          before do
            get "/schemes"
          end

          it "shows the total schemes count" do
            expect(CGI.unescape_html(response.body)).to match("<strong>#{total_schemes_count}</strong> total schemes.")
          end

          it "shows which schemes are being shown on the current page" do
            expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>#{total_schemes_count}</b> schemes")
          end

          it "has correct page 1 of 2 title" do
            expect(page).to have_title("Supported housing schemes (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
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
            get "/schemes?page=2"
          end

          it "shows the total schemes count" do
            expect(CGI.unescape_html(response.body)).to match("<strong>#{total_schemes_count}</strong> total schemes.")
          end

          it "has pagination links" do
            expect(page).to have_content("Previous")
            expect(page).to have_link("Previous")
            expect(page).not_to have_content("Next")
            expect(page).not_to have_link("Next")
          end

          it "shows which schemes are being shown on the current page" do
            expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>25</b> of <b>#{total_schemes_count}</b> schemes")
          end

          it "has correct page 1 of 2 title" do
            expect(page).to have_title("Supported housing schemes (page 2 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end
        end
      end

      context "when searching" do
        let!(:searched_scheme) { FactoryBot.create(:scheme) }
        let(:search_param) { searched_scheme.id }

        before do
          FactoryBot.create(:location, scheme: searched_scheme)
          get "/schemes?search=#{search_param}"
        end

        it "returns matching results" do
          expect(page).to have_content(searched_scheme.id)
          schemes.each do |scheme|
            expect(page).not_to have_content(scheme.id)
          end
        end

        it "updates the table caption" do
          expect(page).to have_content("1 scheme found matching ‘#{search_param}’")
        end

        it "has search in the title" do
          expect(page).to have_title("Supported housing schemes (1 scheme matching ‘#{search_param}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
        end
      end
    end
  end

  describe "#show" do
    let(:specific_scheme) { schemes.first }

    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/#{specific_scheme.id}"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/#{specific_scheme.id}"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:specific_scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }

      before do
        sign_in user
      end

      it "has page heading" do
        get "/schemes/#{specific_scheme.id}"
        expect(page).to have_content(specific_scheme.id)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.organisation.name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.id)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.scheme_type)
        expect(page).to have_content(specific_scheme.registered_under_care_act)
        expect(page).to have_content(specific_scheme.total_units)
        expect(page).to have_content(specific_scheme.primary_client_group)
        expect(page).to have_content(specific_scheme.secondary_client_group)
        expect(page).to have_content(specific_scheme.support_type)
        expect(page).to have_content(specific_scheme.intended_stay)
      end

      context "when coordinator attempts to see scheme belonging to a different organisation" do
        let!(:specific_scheme) { FactoryBot.create(:scheme) }

        it "returns 404 not found" do
          get "/schemes/#{specific_scheme.id}"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{specific_scheme.id}"
      end

      it "has page heading" do
        expect(page).to have_content(specific_scheme.id)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.organisation.name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.id)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.scheme_type)
        expect(page).to have_content(specific_scheme.registered_under_care_act)
        expect(page).to have_content(specific_scheme.total_units)
        expect(page).to have_content(specific_scheme.primary_client_group)
        expect(page).to have_content(specific_scheme.secondary_client_group)
        expect(page).to have_content(specific_scheme.support_type)
        expect(page).to have_content(specific_scheme.intended_stay)
      end
    end
  end

  describe "#locations" do
    let(:specific_scheme) { schemes.first }

    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/#{specific_scheme.id}/locations"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/#{specific_scheme.id}/locations"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }
      let!(:locations) { FactoryBot.create_list(:location, 3, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations"
      end

      context "when coordinator attempts to see scheme belonging to a different organisation" do
        let!(:specific_scheme) { FactoryBot.create(:scheme) }

        before do
          FactoryBot.create(:location, scheme: specific_scheme)
        end

        it "returns 404 not found" do
          get "/schemes/#{specific_scheme.id}/locations"
          expect(response).to have_http_status(:not_found)
        end
      end

      it "shows scheme" do
        locations.each do |location|
          expect(page).to have_content(location.location_code)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.county)
          expect(page).to have_content(location.type_of_unit)
          expect(page).to have_content(location.type_of_building)
          expect(page).to have_content(location.wheelchair_adaptation)
          expect(page).to have_content(location.address_line1)
          expect(page).to have_content(location.address_line2)
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
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }
      let!(:locations) { FactoryBot.create_list(:location, 3, scheme:) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations"
      end

      it "shows scheme" do
        locations.each do |location|
          expect(page).to have_content(location.location_code)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.county)
          expect(page).to have_content(location.type_of_unit)
          expect(page).to have_content(location.type_of_building)
          expect(page).to have_content(location.wheelchair_adaptation)
          expect(page).to have_content(location.address_line1)
          expect(page).to have_content(location.address_line2)
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
    end
  end

  describe "#new" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/new"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/new"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }

      before do
        sign_in user
        get "/schemes/new"
      end

      it "returns a template for a new scheme" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Create a new supported housing scheme")
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/new"
      end

      it "returns a template for a new scheme" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Create a new supported housing scheme")
      end
    end
  end

  describe "#create" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        post "/schemes"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        post "/schemes"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let(:params) { { scheme: { service_name: "testy", sensitive: "1", scheme_type: "Foyer", registered_under_care_act: "No", total_units: "1" } } }

      before do
        sign_in user
      end

      it "creates a new scheme for user organisation with valid params and renders correct page" do
        expect { post "/schemes", params: }.to change(Scheme, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What client group is this scheme intended for?")
      end

      it "creates a new scheme for user organisation with valid params" do
        post "/schemes", params: params

        expect(Scheme.last.organisation_id).to eq(user.organisation_id)
        expect(Scheme.last.service_name).to eq("testy")
        expect(Scheme.last.scheme_type).to eq("Foyer")
        expect(Scheme.last.sensitive).to eq("Yes")
        expect(Scheme.last.registered_under_care_act).to eq("No")
        expect(Scheme.last.id).not_to eq(nil)
        expect(Scheme.last.has_other_client_group).to eq(nil)
        expect(Scheme.last.primary_client_group).to eq(nil)
        expect(Scheme.last.secondary_client_group).to eq(nil)
        expect(Scheme.last.support_type).to eq(nil)
        expect(Scheme.last.intended_stay).to eq(nil)
        expect(Scheme.last.code).to match(/S*/)
      end
    end

    context "when signed in as a support user" do
      let(:organisation) { FactoryBot.create(:organisation) }
      let(:user) { FactoryBot.create(:user, :support) }
      let(:params) { { scheme: { service_name: "testy", sensitive: "1", scheme_type: "Foyer", registered_under_care_act: "No", total_units: "1", organisation_id: organisation.id } } }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "creates a new scheme for user organisation with valid params and renders correct page" do
        expect { post "/schemes", params: }.to change(Scheme, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What client group is this scheme intended for?")
      end

      it "creates a new scheme for user organisation with valid params" do
        post "/schemes", params: params

        expect(Scheme.last.organisation_id).to eq(organisation.id)
        expect(Scheme.last.service_name).to eq("testy")
        expect(Scheme.last.scheme_type).to eq("Foyer")
        expect(Scheme.last.sensitive).to eq("Yes")
        expect(Scheme.last.registered_under_care_act).to eq("No")
        expect(Scheme.last.id).not_to eq(nil)
        expect(Scheme.last.has_other_client_group).to eq(nil)
        expect(Scheme.last.primary_client_group).to eq(nil)
        expect(Scheme.last.secondary_client_group).to eq(nil)
        expect(Scheme.last.support_type).to eq(nil)
        expect(Scheme.last.intended_stay).to eq(nil)
        expect(Scheme.last.code).to match(/S*/)
      end

      context "when required organisation id param is missing" do
        let(:params) { { "scheme" => { "service_name" => "qweqwer", "sensitive" => "Yes", "organisation_id" => "", "scheme_type" => "Foyer", "registered_under_care_act" => "Yes – part registered as a care home", "total_units" => "1" } } }

        it "displays the new page with an error message" do
          post "/schemes", params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.organisation.required"))
        end
      end
    end
  end

  describe "#update" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        patch "/schemes/#{schemes.first.id}"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        patch "/schemes/#{schemes.first.id}"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let(:scheme_to_update) { FactoryBot.create(:scheme, organisation: user.organisation) }

      context "when updating primary client group" do
        let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group" } } }

        before do
          sign_in user
          patch "/schemes/#{scheme_to_update.id}", params:
        end

        it "renders confirm secondary group after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Does this scheme provide for another client group?")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before updating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating confirm secondary client group" do
        let(:params) { { scheme: { has_other_client_group: "Yes", page: "confirm-secondary" } } }

        before do
          sign_in user
          patch "/schemes/#{scheme_to_update.id}", params:
        end

        it "renders secondary client group after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("What is the other client group?")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.has_other_client_group).to eq("Yes")
        end

        context "when updating from check answers page with the answer YES" do
          let(:params) { { scheme: { has_other_client_group: "Yes", page: "confirm-secondary", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("What is the other client group?")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.has_other_client_group).to eq("Yes")
          end
        end

        context "when updating from check answers page with the answer NO" do
          let(:params) { { scheme: { has_other_client_group: "No", page: "confirm-secondary", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before updating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.has_other_client_group).to eq("No")
          end
        end
      end

      context "when updating secondary client group" do
        let(:params) { { scheme: { secondary_client_group: "Homeless families with support needs", page: "secondary-client-group" } } }

        before do
          sign_in user
          patch "/schemes/#{scheme_to_update.id}", params:
        end

        it "renders confirm support page after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("What support does this scheme provide?")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.secondary_client_group).to eq("Homeless families with support needs")
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { secondary_client_group: "Homeless families with support needs", page: "secondary-client-group", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before updating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.secondary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating support" do
        let(:params) { { scheme: { intended_stay: "Medium stay", support_type: "Resettlement support", page: "support" } } }

        before do
          sign_in user
          patch "/schemes/#{scheme_to_update.id}", params:
        end

        it "renders confirm secondary group after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before updating this scheme")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.intended_stay).to eq("Medium stay")
          expect(scheme_to_update.reload.support_type).to eq("Resettlement support")
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { intended_stay: "Medium stay", support_type: "Resettlement support", page: "support", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before updating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.intended_stay).to eq("Medium stay")
            expect(scheme_to_update.reload.support_type).to eq("Resettlement support")
          end
        end
      end

      context "when updating details" do
        let(:params) { { scheme: { service_name: "testy", sensitive: "1", scheme_type: "Foyer", registered_under_care_act: "No", total_units: "1", page: "details" } } }

        before do
          sign_in user
          patch "/schemes/#{scheme_to_update.id}", params:
        end

        it "renders confirm secondary group after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("What client group is this scheme intended for?")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.service_name).to eq("testy")
          expect(scheme_to_update.reload.scheme_type).to eq("Foyer")
          expect(scheme_to_update.reload.sensitive).to eq("Yes")
          expect(scheme_to_update.reload.registered_under_care_act).to eq("No")
          expect(scheme_to_update.reload.total_units).to eq(1)
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { service_name: "testy", sensitive: "1", scheme_type: "Foyer", registered_under_care_act: "No", total_units: "1", page: "details", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before updating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.service_name).to eq("testy")
            expect(scheme_to_update.reload.scheme_type).to eq("Foyer")
            expect(scheme_to_update.reload.sensitive).to eq("Yes")
            expect(scheme_to_update.reload.registered_under_care_act).to eq("No")
            expect(scheme_to_update.reload.total_units).to eq(1)
          end
        end
      end
    end
  end
end
