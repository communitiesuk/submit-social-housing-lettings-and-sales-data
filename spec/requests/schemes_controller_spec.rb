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

      context "when params scheme_id is present" do
        it "shows a success banner" do
          get "/schemes", params: { scheme_id: schemes.first.id }
          follow_redirect!
          expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
        end
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
          expect(page).to have_content(scheme.id_to_display)
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

      context "when params scheme_id is present" do
        it "shows a success banner" do
          get "/schemes", params: { scheme_id: schemes.first.id }
          expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
        end
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
        let(:search_param) { searched_scheme.id_to_display }

        before do
          FactoryBot.create(:location, scheme: searched_scheme)
          get "/schemes?search=#{search_param}"
        end

        it "returns matching results" do
          expect(page).to have_content(searched_scheme.id_to_display)
          schemes.each do |scheme|
            expect(page).not_to have_content(scheme.id_to_display)
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
      let!(:specific_scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

      before do
        sign_in user
      end

      it "has page heading" do
        get "/schemes/#{specific_scheme.id}"
        expect(page).to have_content(specific_scheme.id_to_display)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.id_to_display)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.scheme_type)
        expect(page).to have_content(specific_scheme.registered_under_care_act)
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
        expect(page).to have_content(specific_scheme.id_to_display)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.owning_organisation.name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.id_to_display)
        expect(page).to have_content(specific_scheme.service_name)
        expect(page).to have_content(specific_scheme.sensitive)
        expect(page).to have_content(specific_scheme.scheme_type)
        expect(page).to have_content(specific_scheme.registered_under_care_act)
        expect(page).to have_content(specific_scheme.primary_client_group)
        expect(page).to have_content(specific_scheme.secondary_client_group)
        expect(page).to have_content(specific_scheme.support_type)
        expect(page).to have_content(specific_scheme.intended_stay)
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
      let(:params) do
        { scheme: { service_name: "testy",
                    sensitive: "1",
                    scheme_type: "Foyer",
                    registered_under_care_act: "No",
                    arrangement_type: "D" } }
      end

      before do
        sign_in user
      end

      it "creates a new scheme for user organisation with valid params and renders correct page" do
        expect { post "/schemes", params: }.to change(Scheme, :count).by(1)
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What client group is this scheme intended for?")
      end

      it "creates a new scheme for user organisation with valid params" do
        post "/schemes", params: params

        expect(Scheme.last.owning_organisation_id).to eq(user.organisation_id)
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
        expect(Scheme.last.id_to_display).to match(/S*/)
      end

      context "when support services provider is selected" do
        let(:params) do
          { scheme: { service_name: "testy",
                      sensitive: "1",
                      scheme_type: "Foyer",
                      registered_under_care_act: "No",
                      arrangement_type: "R" } }
        end

        it "creates a new scheme for user organisation with valid params and renders correct page" do
          expect { post "/schemes", params: }.to change(Scheme, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Which organisation provides the support services used by this scheme?")
        end

        it "creates a new scheme for user organisation with valid params" do
          post "/schemes", params: params

          expect(Scheme.last.owning_organisation_id).to eq(user.organisation_id)
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
          expect(Scheme.last.id_to_display).to match(/S*/)
        end
      end

      context "when missing required scheme params" do
        let(:params) do
          { scheme: { service_name: "",
                      scheme_type: "",
                      registered_under_care_act: "",
                      arrangement_type: "" } }
        end

        it "renders the same page with error message" do
          post "/schemes", params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content("Create a new supported housing scheme")
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.scheme_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.registered_under_care_act.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.arrangement_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.service_name.invalid"))
        end
      end
    end

    context "when signed in as a support user" do
      let(:organisation) { FactoryBot.create(:organisation) }
      let(:user) { FactoryBot.create(:user, :support) }
      let(:params) do
        { scheme: { service_name: "testy",
                    sensitive: "1",
                    scheme_type: "Foyer",
                    registered_under_care_act: "No",
                    owning_organisation_id: organisation.id,
                    arrangement_type: "D" } }
      end

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "creates a new scheme for user organisation with valid params and renders correct page" do
        expect { post "/schemes", params: }.to change(Scheme, :count).by(1)
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What client group is this scheme intended for?")
      end

      it "creates a new scheme for user organisation with valid params" do
        post "/schemes", params: params

        expect(Scheme.last.owning_organisation_id).to eq(organisation.id)
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
        expect(Scheme.last.id_to_display).to match(/S*/)
      end

      context "when support services provider is selected" do
        let(:params) do
          { scheme: { service_name: "testy",
                      sensitive: "1",
                      scheme_type: "Foyer",
                      registered_under_care_act: "No",
                      owning_organisation_id: organisation.id,
                      support_services_provider_before_type_cast: "1" } }
        end

        it "creates a new scheme for user organisation with valid params and renders correct page" do
          expect { post "/schemes", params: }.to change(Scheme, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Which organisation provides the support services used by this scheme?")
        end

        it "creates a new scheme for user organisation with valid params" do
          post "/schemes", params: params
          expect(Scheme.last.owning_organisation_id).to eq(organisation.id)
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
          expect(Scheme.last.id_to_display).to match(/S*/)
        end
      end

      context "when missing required scheme params" do
        let(:params) do
          { scheme: { service_name: "",
                      scheme_type: "",
                      registered_under_care_act: "",
                      arrangement_type: "" } }
        end

        it "renders the same page with error message" do
          post "/schemes", params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content("Create a new supported housing scheme")
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.scheme_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.registered_under_care_act.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.arrangement_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.service_name.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.owning_organisation_id.invalid"))
        end
      end

      context "when required organisation id param is missing" do
        let(:params) { { "scheme" => { "service_name" => "qweqwer", "sensitive" => "Yes", "owning_organisation_id" => "", "scheme_type" => "Foyer", "registered_under_care_act" => "Yes – part registered as a care home" } } }

        it "displays the new page with an error message" do
          post "/schemes", params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.owning_organisation_id.invalid"))
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
      let(:scheme_to_update) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

      before do
        sign_in user
        patch "/schemes/#{scheme_to_update.id}", params:
      end

      context "when params are missing" do
        let(:params) do
          { scheme: {
            service_name: "",
            managing_organisation_id: "",
            owning_organisation_id: "",
            primary_client_group: "",
            secondary_client_group: "",
            scheme_type: "",
            registered_under_care_act: "",
            support_type: "",
            intended_stay: "",
            arrangement_type: "",
            has_other_client_group: "",
            page: "details",
          } }
        end

        it "renders primary client group after successful update" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content("Create a new supported housing scheme")
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.service_name.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.scheme_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.registered_under_care_act.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.primary_client_group.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.secondary_client_group.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.support_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.intended_stay.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.has_other_client_group.invalid"))
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating support services provider" do
        let(:params) { { scheme: { managing_organisation_id: organisation.id, page: "support-services-provider" } } }

        it "renders primary client group after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("What client group is this scheme intended for?")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.managing_organisation_id).to eq(organisation.id)
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating primary client group" do
        let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group" } } }

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
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating confirm secondary client group" do
        let(:params) { { scheme: { has_other_client_group: "Yes", page: "confirm-secondary" } } }

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
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.has_other_client_group).to eq("No")
          end
        end
      end

      context "when updating secondary client group" do
        let(:params) { { scheme: { secondary_client_group: "Homeless families with support needs", page: "secondary-client-group" } } }

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
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.secondary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating support" do
        let(:params) { { scheme: { intended_stay: "Medium stay", support_type: "Low level", page: "support" } } }

        it "renders add location to this scheme successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Add a location to this scheme")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.intended_stay).to eq("Medium stay")
          expect(scheme_to_update.reload.support_type).to eq("Low level")
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { intended_stay: "Medium stay", support_type: "Low level", page: "support", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.intended_stay).to eq("Medium stay")
            expect(scheme_to_update.reload.support_type).to eq("Low level")
          end
        end
      end

      context "when updating details" do
        let(:params) do
          { scheme: { service_name: "testy",
                      sensitive: "1",
                      scheme_type: "Foyer",
                      registered_under_care_act: "No",
                      page: "details",
                      owning_organisation_id: organisation.id,
                      arrangement_type: "D" } }
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
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { service_name: "testy", sensitive: "1", scheme_type: "Foyer", registered_under_care_act: "No", page: "details", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.service_name).to eq("testy")
            expect(scheme_to_update.reload.scheme_type).to eq("Foyer")
            expect(scheme_to_update.reload.sensitive).to eq("Yes")
            expect(scheme_to_update.reload.registered_under_care_act).to eq("No")
          end
        end
      end

      context "when editing scheme name details" do
        let(:params) { { scheme: { service_name: "testy", sensitive: "1", page: "edit-name" } } }

        it "renders scheme show page after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content(scheme_to_update.reload.service_name)
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.service_name).to eq("testy")
          expect(scheme_to_update.reload.sensitive).to eq("Yes")
        end
      end
    end

    context "when signed in as a support" do
      let(:user) { FactoryBot.create(:user, :support) }
      let(:scheme_to_update) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        patch "/schemes/#{scheme_to_update.id}", params:
      end

      context "when params are missing" do
        let(:params) do
          { scheme: {
            service_name: "",
            managing_organisation_id: "",
            owning_organisation_id: "",
            primary_client_group: "",
            secondary_client_group: "",
            scheme_type: "",
            registered_under_care_act: "",
            support_type: "",
            intended_stay: "",
            arrangement_type: "",
            has_other_client_group: "",
            page: "details",
          } }
        end

        it "renders primary client group after successful update" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content("Create a new supported housing scheme")
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.owning_organisation_id.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.service_name.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.scheme_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.registered_under_care_act.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.primary_client_group.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.secondary_client_group.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.support_type.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.intended_stay.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.has_other_client_group.invalid"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.scheme.attributes.arrangement_type.invalid"))
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating primary client group" do
        let(:params) { { scheme: { primary_client_group: "Homeless families with support needs", page: "primary-client-group" } } }

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
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.primary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating confirm secondary client group" do
        let(:params) { { scheme: { has_other_client_group: "Yes", page: "confirm-secondary" } } }

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
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.has_other_client_group).to eq("No")
          end
        end
      end

      context "when updating secondary client group" do
        let(:params) { { scheme: { secondary_client_group: "Homeless families with support needs", page: "secondary-client-group" } } }

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
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.secondary_client_group).to eq("Homeless families with support needs")
          end
        end
      end

      context "when updating support" do
        let(:params) { { scheme: { intended_stay: "Medium stay", support_type: "Low level", page: "support" } } }

        it "renders confirm secondary group after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Add a location to this scheme")
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.intended_stay).to eq("Medium stay")
          expect(scheme_to_update.reload.support_type).to eq("Low level")
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { intended_stay: "Medium stay", support_type: "Low level", page: "support", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.intended_stay).to eq("Medium stay")
            expect(scheme_to_update.reload.support_type).to eq("Low level")
          end
        end
      end

      context "when updating details" do
        let(:another_organisation) { FactoryBot.create(:organisation) }
        let(:params) do
          { scheme: { service_name: "testy",
                      sensitive: "1",
                      scheme_type: "Foyer",
                      registered_under_care_act: "No",
                      page: "details",
                      arrangement_type: "D",
                      owning_organisation_id: another_organisation.id } }
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
          expect(scheme_to_update.reload.owning_organisation_id).to eq(another_organisation.id)
          expect(scheme_to_update.reload.managing_organisation_id).to eq(another_organisation.id)
        end

        context "when updating from check answers page" do
          let(:params) { { scheme: { service_name: "testy", sensitive: "1", scheme_type: "Foyer", registered_under_care_act: "No", page: "details", check_answers: "true" } } }

          it "renders check answers page after successful update" do
            follow_redirect!
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("Check your changes before creating this scheme")
          end

          it "updates a scheme with valid params" do
            follow_redirect!
            expect(scheme_to_update.reload.service_name).to eq("testy")
            expect(scheme_to_update.reload.scheme_type).to eq("Foyer")
            expect(scheme_to_update.reload.sensitive).to eq("Yes")
            expect(scheme_to_update.reload.registered_under_care_act).to eq("No")
          end
        end
      end

      context "when editing scheme name details" do
        let(:another_organisation) { FactoryBot.create(:organisation) }
        let(:params) do
          { scheme: { service_name: "testy",
                      sensitive: "1",
                      page: "edit-name",
                      owning_organisation_id: another_organisation.id } }
        end

        it "renders scheme show page after successful update" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content(scheme_to_update.reload.service_name)
          expect(scheme_to_update.reload.owning_organisation_id).to eq(another_organisation.id)
        end

        it "updates a scheme with valid params" do
          follow_redirect!
          expect(scheme_to_update.reload.service_name).to eq("testy")
          expect(scheme_to_update.reload.sensitive).to eq("Yes")
        end
      end
    end
  end

  describe "#primary_client_group" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/primary-client-group"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/primary-client-group"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/primary-client-group"
      end

      it "returns a template for a primary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What client group is this scheme intended for?")
      end

      context "when attempting to access primary-client-group scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/primary-client-group"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/primary-client-group"
      end

      it "returns a template for a primary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What client group is this scheme intended for?")
      end
    end
  end

  describe "#confirm_secondary_client_group" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/confirm-secondary-client-group"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/confirm-secondary-client-group"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/confirm-secondary-client-group"
      end

      it "returns a template for a confirm-secondary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Does this scheme provide for another client group?")
      end

      context "when attempting to access confirm-secondary-client-group scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/confirm-secondary-client-group"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/confirm-secondary-client-group"
      end

      it "returns a template for a confirm-secondary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Does this scheme provide for another client group?")
      end
    end
  end

  describe "#secondary_client_group" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/secondary-client-group"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/secondary-client-group"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/secondary-client-group"
      end

      it "returns a template for a secondary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the other client group?")
      end

      context "when attempting to access secondary-client-group scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/secondary-client-group"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/secondary-client-group"
      end

      it "returns a template for a secondary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What is the other client group?")
      end
    end
  end

  describe "#support" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/support"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/support"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/support"
      end

      it "returns a template for a support" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What support does this scheme provide?")
      end

      context "when attempting to access secondary-client-group scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/support"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/support"
      end

      it "returns a template for a support" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("What support does this scheme provide?")
      end
    end
  end

  describe "#check-answers" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/check-answers"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/check-answers"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/check-answers"
      end

      it "returns a template for a support" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your changes before creating this scheme")
      end

      context "when attempting to access check-answers scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/check-answers"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/check-answers"
      end

      it "returns a template for a support" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your changes before creating this scheme")
      end
    end
  end

  describe "#details" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/details"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/details"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/details"
      end

      it "returns a template for a support" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Create a new supported housing scheme")
      end

      context "when attempting to access check-answers scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/details"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/details"
      end

      it "returns a template for a support" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Create a new supported housing scheme")
      end
    end
  end

  describe "#edit_name" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/edit-name"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/edit-name"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:another_scheme) { FactoryBot.create(:scheme) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/edit-name"
      end

      it "returns a template for a edit-name" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Scheme details")
        expect(page).to have_content("This scheme contains confidential information")
        expect(page).not_to have_content("Which organisation owns the housing stock for this scheme?")
      end

      context "when attempting to access secondary-client-group scheme page for another organisation" do
        before do
          get "/schemes/#{another_scheme.id}/edit-name"
        end

        it "returns 404 not_found" do
          request
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/edit-name"
      end

      it "returns a template for a secondary-client-group" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Scheme details")
        expect(page).to have_content("This scheme contains confidential information")
        expect(page).to have_content("Which organisation owns the housing stock for this scheme?")
      end
    end
  end
end
