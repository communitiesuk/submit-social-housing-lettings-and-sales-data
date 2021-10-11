require "rails_helper"

RSpec.describe CaseLogsController, type: :controller do
  let(:valid_session) { {} }

  context "Collection routes" do
    describe "GET #index" do
      it "returns a success response" do
        get :index, params: {}, session: valid_session
        expect(response).to be_successful
      end
    end

    describe "Post #create" do
      it "creates a new case log record" do
        expect {
          post :create, params: {}, session: valid_session
        }.to change(CaseLog, :count).by(1)
      end

      it "redirects to that case log" do
        post :create, params: {}, session: valid_session
        expect(response.status).to eq(302)
      end
    end
  end

  context "Instance routes" do
    let!(:case_log) { FactoryBot.create(:case_log) }
    let(:id) { case_log.id }

    describe "GET #show" do
      it "returns a success response" do
        get :show, params: { id: id }
        expect(response).to be_successful
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        get :edit, params: { id: id }
        expect(response).to be_successful
      end
    end
  end

  describe "submit_form" do
    let!(:case_log) { FactoryBot.create(:case_log) }
    let(:id) { case_log.id }
    let(:case_log_form_params) do
      { "accessibility_requirements" =>
                             %w[ accessibility_requirements_fully_wheelchair_accessible_housing
                                 accessibility_requirements_wheelchair_access_to_essential_rooms
                                 accessibility_requirements_level_access_housing],
        "previous_page" => "accessibility_requirements" }
    end

    it "sets checked items to true" do
      get :submit_form, params: { id: id, case_log: case_log_form_params }
      case_log.reload

      expect(case_log.accessibility_requirements_fully_wheelchair_accessible_housing).to eq(true)
      expect(case_log.accessibility_requirements_wheelchair_access_to_essential_rooms).to eq(true)
      expect(case_log.accessibility_requirements_level_access_housing).to eq(true)
    end

    it "sets previously submitted items to false when resubmitted with new values" do
      post :submit_form, params: { id: id, case_log: case_log_form_params }

      new_case_log_form_params = { "accessibility_requirements" =>
                               %w[accessibility_requirements_level_access_housing],
                                 "previous_page" => "accessibility_requirements" }

      get :submit_form, params: { id: id, case_log: new_case_log_form_params }
      case_log.reload

      expect(case_log.accessibility_requirements_fully_wheelchair_accessible_housing).to eq(false)
      expect(case_log.accessibility_requirements_wheelchair_access_to_essential_rooms).to eq(false)
      expect(case_log.accessibility_requirements_level_access_housing).to eq(true)
    end
  end
end
