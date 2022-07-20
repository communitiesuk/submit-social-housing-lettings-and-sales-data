require "rails_helper"

RSpec.describe LocationsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :support) }
  let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

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

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Add a location to this scheme")
      end

      context "when trying to new location to a scheme that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/new"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when signed in as a support user" do
      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        get "/schemes/#{scheme.id}/locations/new"
      end

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Add a location to this scheme")
      end
    end
  end

  describe "#create" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        post "/schemes/1/locations"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        post "/schemes/1/locations"
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let(:startdate) { Time.utc(2022, 2, 2) }
      let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ", startdate: } } }

      before do
        sign_in user
        post "/schemes/#{scheme.id}/locations", params: params
      end

      it "creates a new location for scheme with valid params and redirects to correct page" do
        expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your answers before creating this scheme")
      end

      it "creates a new location for scheme with valid params" do
        expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
        expect(Location.last.name).to eq("Test")
        expect(Location.last.postcode).to eq("ZZ11ZZ")
        expect(Location.last.units).to eq(5)
        expect(Location.last.type_of_unit).to eq("Bungalow")
        expect(Location.last.wheelchair_adaptation).to eq("No")
        expect(Location.last.startdate).to eq(startdate)
      end

      context "when postcode is submitted with lower case" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "zz1 1zz" } } }

        it "creates a new location for scheme with postcode " do
          expect(Location.last.postcode).to eq("ZZ11ZZ")
        end
      end

      context "when trying to add location to a scheme that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ" } } }

        it "displays the new page with an error message" do
          post "/schemes/#{another_scheme.id}/locations", params: params
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when do you want to add another location is selected as yes" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "Yes", postcode: "ZZ1 1ZZ" } } }

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Add a location to this scheme")
        end

        it "creates a new location for scheme with valid params" do
          expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is selected as no" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ" } } }

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "creates a new location for scheme with valid params" do
          expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is not selected" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", postcode: "ZZ1 1ZZ" } } }

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "creates a new location for scheme with valid params" do
          expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when required param are missing" do
        let(:params) { { location: { postcode: "", name: "Test", units: "", type_of_unit: "", wheelchair_adaptation: "No", add_another_location: "No" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.units.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.type_of_unit.blank"))
        end
      end

      context "when invalid time is supplied" do
        let(:params) do
          { location: {
            name: "Test",
            units: "5",
            type_of_unit: "Bungalow",
            wheelchair_adaptation: "No",
            add_another_location: "No",
            postcode: "ZZ1 1ZZ",
            "startdate(3i)" => "1",
            "startdate(2i)" => "1",
            "startdate(1i)" => "w",
          } }
        end

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.date.invalid_date"))
        end
      end

      context "when invalid time is supplied" do
        let(:params) do
          { location: {
            name: "Test",
            units: "5",
            type_of_unit: "Bungalow",
            wheelchair_adaptation: "No",
            add_another_location: "No",
            postcode: "ZZ1 1ZZ",
            "startdate(3i)" => "1",
            "startdate(2i)" => "1",
            "startdate(1i)" => "w",
          } }
        end

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.date.invalid_date"))
        end
      end

      context "when no startdate is supplied" do
        let(:params) do
          { location: {
            name: "Test",
            units: "5",
            type_of_unit: "Bungalow",
            wheelchair_adaptation: "No",
            add_another_location: "No",
            postcode: "ZZ1 1ZZ",
            "startdate(3i)" => "",
            "startdate(2i)" => "",
            "startdate(1i)" => "",
          } }
        end

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your answers before creating this scheme")
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:scheme) { FactoryBot.create(:scheme) }
      let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ" } } }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        post "/schemes/#{scheme.id}/locations", params: params
      end

      it "creates a new location for scheme with valid params and redirects to correct page" do
        expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your answers before creating this scheme")
      end

      it "creates a new location for scheme with valid params" do
        expect(Location.last.name).to eq("Test")
        expect(Location.last.postcode).to eq("ZZ11ZZ")
        expect(Location.last.units).to eq(5)
        expect(Location.last.type_of_unit).to eq("Bungalow")
        expect(Location.last.wheelchair_adaptation).to eq("No")
      end

      context "when postcode is submitted with lower case" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "zz1 1zz" } } }

        it "creates a new location for scheme with postcode " do
          expect(Location.last.postcode).to eq("ZZ11ZZ")
        end
      end

      context "when required postcode param is missing" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No" } } }

        it "displays the new page with an error message" do
          post "/schemes/#{scheme.id}/locations", params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
        end
      end

      context "when do you want to add another location is selected as yes" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "Yes", postcode: "ZZ1 1ZZ" } } }

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Add a location to this scheme")
        end

        it "creates a new location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is selected as no" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ" } } }

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "creates a new location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is not selected" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", postcode: "ZZ1 1ZZ" } } }

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "creates a new location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when required param are missing" do
        let(:params) { { location: { postcode: "", name: "Test", units: "", type_of_unit: "", wheelchair_adaptation: "No", add_another_location: "No" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.units.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.type_of_unit.blank"))
        end
      end

      context "when invalid time is supplied" do
        let(:params) do
          { location: {
            name: "Test",
            units: "5",
            type_of_unit: "Bungalow",
            wheelchair_adaptation: "No",
            add_another_location: "No",
            postcode: "ZZ1 1ZZ",
            "startdate(3i)" => "1",
            "startdate(2i)" => "1",
            "startdate(1i)" => "w",
          } }
        end

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.date.invalid_date"))
        end
      end

      context "when no startdate is supplied" do
        let(:params) do
          { location: {
            name: "Test",
            units: "5",
            type_of_unit: "Bungalow",
            wheelchair_adaptation: "No",
            add_another_location: "No",
            postcode: "ZZ1 1ZZ",
            "startdate(3i)" => "",
            "startdate(2i)" => "",
            "startdate(1i)" => "",
          } }
        end

        it "creates a new location for scheme with valid params and redirects to correct page" do
          expect { post "/schemes/#{scheme.id}/locations", params: }.to change(Location, :count).by(1)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your answers before creating this scheme")
        end
      end
    end
  end

  describe "#edit" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/edit"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/edit"
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
        get "/schemes/#{scheme.id}/locations/#{location.id}/edit"
      end

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Add a location to this scheme")
      end

      context "when trying to new location to a scheme that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/edit"
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
        get "/schemes/#{scheme.id}/locations/#{location.id}/edit"
      end

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Add a location to this scheme")
      end
    end
  end

  describe "#update" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        patch "/schemes/1/locations/1"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        patch "/schemes/1/locations/1"
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
      let(:startdate) { Time.utc(2021, 1, 2) }
      let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ", startdate:, page: "edit" } } }

      before do
        sign_in user
        patch "/schemes/#{scheme.id}/locations/#{location.id}", params: params
      end

      it "updates existing location for scheme with valid params and redirects to correct page" do
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your answers before creating this scheme")
      end

      it "updates existing location for scheme with valid params" do
        expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
        expect(Location.last.name).to eq("Test")
        expect(Location.last.postcode).to eq("ZZ11ZZ")
        expect(Location.last.units).to eq(5)
        expect(Location.last.type_of_unit).to eq("Bungalow")
        expect(Location.last.wheelchair_adaptation).to eq("No")
        expect(Location.last.startdate).to eq(startdate)
      end

      context "when updating from edit-name page" do
        let(:params) { { location: { name: "Test", page: "edit-name" } } }

        it "updates existing location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Locations")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
        end
      end

      context "when postcode is submitted with lower case" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "zz1 1zz", page: "edit" } } }

        it "updates existing location for scheme with postcode " do
          expect(Location.last.postcode).to eq("ZZ11ZZ")
        end
      end

      context "when trying to update location for a scheme that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location) { FactoryBot.create(:location) }
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "displays the new page with an error message" do
          patch "/schemes/#{another_scheme.id}/locations/#{another_location.id}", params: params
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when required postcode param is invalid" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "invalid", page: "edit" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
        end
      end

      context "when do you want to add another location is selected as yes" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "Yes", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "updates existing location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Add a location to this scheme")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is selected as no" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "updates existing location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is not selected" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "updates existing location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.scheme.owning_organisation_id).to eq(user.organisation_id)
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when required param are missing" do
        let(:params) { { location: { postcode: "", name: "Test", units: "", type_of_unit: "", wheelchair_adaptation: "No", add_another_location: "No" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.units.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.type_of_unit.blank"))
        end
      end
    end

    context "when signed in as a support user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }
      let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:location)  { FactoryBot.create(:location, scheme:) }
      let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ", page: "edit" } } }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
        patch "/schemes/#{scheme.id}/locations/#{location.id}", params: params
      end

      it "updates a location for scheme with valid params and redirects to correct page" do
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Check your answers before creating this scheme")
      end

      it "updates existing location for scheme with valid params" do
        expect(Location.last.name).to eq("Test")
        expect(Location.last.postcode).to eq("ZZ11ZZ")
        expect(Location.last.units).to eq(5)
        expect(Location.last.type_of_unit).to eq("Bungalow")
        expect(Location.last.wheelchair_adaptation).to eq("No")
      end

      context "when updating from edit-name page" do
        let(:params) { { location: { name: "Test", page: "edit-name" } } }

        it "updates existing location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Locations")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
        end
      end

      context "when postcode is submitted with lower case" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "zz1 1zz", page: "edit" } } }

        it "updates a location for scheme with postcode " do
          expect(Location.last.postcode).to eq("ZZ11ZZ")
        end
      end

      context "when required postcode param is missing" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "invalid", page: "edit" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
        end
      end

      context "when do you want to add another location is selected as yes" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "Yes", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "updates location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Add a location to this scheme")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is selected as no" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", add_another_location: "No", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "updates a location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "updates existing location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when do you want to add another location is not selected" do
        let(:params) { { location: { name: "Test", units: "5", type_of_unit: "Bungalow", wheelchair_adaptation: "No", postcode: "ZZ1 1ZZ", page: "edit" } } }

        it "updates a location for scheme with valid params and redirects to correct page" do
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(page).to have_content("Check your changes before creating this scheme")
        end

        it "updates a location for scheme with valid params" do
          expect(Location.last.name).to eq("Test")
          expect(Location.last.units).to eq(5)
          expect(Location.last.type_of_unit).to eq("Bungalow")
          expect(Location.last.wheelchair_adaptation).to eq("No")
        end
      end

      context "when required param are missing" do
        let(:params) { { location: { postcode: "", name: "Test", units: "", type_of_unit: "", wheelchair_adaptation: "No", add_another_location: "No" } } }

        it "displays the new page with an error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.postcode"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.units.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.location.attributes.type_of_unit.blank"))
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
      let!(:locations) { FactoryBot.create_list(:location, 3, scheme:) }

      before do
        sign_in user
        get "/schemes/#{scheme.id}/locations"
      end

      context "when coordinator attempts to see scheme belonging to a different organisation" do
        let!(:another_scheme) { FactoryBot.create(:scheme) }

        before do
          FactoryBot.create(:location, scheme:)
        end

        it "returns 404 not found" do
          get "/schemes/#{another_scheme.id}/locations"
          expect(response).to have_http_status(:not_found)
        end
      end

      it "shows scheme" do
        locations.each do |location|
          expect(page).to have_content(location.id)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.type_of_unit)
          expect(page).to have_content(location.wheelchair_adaptation)
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
          expect(page).to have_content(location.id)
          expect(page).to have_content(location.postcode)
          expect(page).to have_content(location.type_of_unit)
          expect(page).to have_content(location.wheelchair_adaptation)
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

  describe "#edit-name" do
    context "when not signed in" do
      it "redirects to the sign in page" do
        get "/schemes/1/locations/1/edit-name"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    context "when signed in as a data provider" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        get "/schemes/1/locations/1/edit-name"
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
        get "/schemes/#{scheme.id}/locations/#{location.id}/edit-name"
      end

      it "returns a template for a edit-name" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Location name for #{location.postcode}")
      end

      context "when trying to edit location name of location that belongs to another organisation" do
        let(:another_scheme)  { FactoryBot.create(:scheme) }
        let(:another_location)  { FactoryBot.create(:location, scheme: another_scheme) }

        it "displays the new page with an error message" do
          get "/schemes/#{another_scheme.id}/locations/#{another_location.id}/edit-name"
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
        get "/schemes/#{scheme.id}/locations/#{location.id}/edit-name"
      end

      it "returns a template for a new location" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Location name for #{location.postcode}")
      end
    end
  end
end
