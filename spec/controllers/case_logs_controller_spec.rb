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
      { accessibility_requirements:
                             %w[ housingneeds_a
                                 housingneeds_b
                                 housingneeds_c],
        page: "accessibility_requirements" }
    end

    let(:new_case_log_form_params) do
      {
        accessibility_requirements: %w[housingneeds_c],
        page: "accessibility_requirements",
      }
    end

    it "sets checked items to true" do
      post :submit_form, params: { id: id, case_log: case_log_form_params }
      case_log.reload

      expect(case_log.housingneeds_a).to eq("Yes")
      expect(case_log.housingneeds_b).to eq("Yes")
      expect(case_log.housingneeds_c).to eq("Yes")
    end

    it "sets previously submitted items to false when resubmitted with new values" do
      post :submit_form, params: { id: id, case_log: new_case_log_form_params }
      case_log.reload

      expect(case_log.housingneeds_a).to eq("No")
      expect(case_log.housingneeds_b).to eq("No")
      expect(case_log.housingneeds_c).to eq("Yes")
    end

    context "given a page with checkbox and non-checkbox questions" do
      let(:tenant_code) { "BZ355" }
      let(:case_log_form_params) do
        { accessibility_requirements:
                               %w[ housingneeds_a
                                   housingneeds_b
                                   housingneeds_c],
          tenant_code: tenant_code,
          page: "accessibility_requirements" }
      end
      let(:questions_for_page) do
        { "accessibility_requirements" =>
          {
            "type" => "checkbox",
            "answer_options" =>
            { "housingneeds_a" => "Fully wheelchair accessible housing",
              "housingneeds_b" => "Wheelchair access to essential rooms",
              "housingneeds_c" => "Level access housing",
              "housingneeds_f" => "Other disability requirements",
              "housingneeds_g" => "No disability requirements",
              "divider_a" => true,
              "housingneeds_h" => "Do not know",
              "divider_b" => true,
              "accessibility_requirements_prefer_not_to_say" => "Prefer not to say" },
          },
          "tenant_code" =>
          {
            "type" => "text",
          } }
      end

      it "updates both question fields" do
        allow_any_instance_of(Form).to receive(:questions_for_page).and_return(questions_for_page)
        post :submit_form, params: { id: id, case_log: case_log_form_params }
        case_log.reload

        expect(case_log.housingneeds_a).to eq("Yes")
        expect(case_log.housingneeds_b).to eq("Yes")
        expect(case_log.housingneeds_c).to eq("Yes")
        expect(case_log.tenant_code).to eq(tenant_code)
      end
    end

    context "conditional routing" do
      before do
        allow_any_instance_of(CaseLogValidator).to receive(:validate_household_pregnancy).and_return(true)
      end

      let(:case_log_form_conditional_question_yes_params) do
        {
          preg_occ: "Yes",
          page: "conditional_question",
        }
      end

      let(:case_log_form_conditional_question_no_params) do
        {
          preg_occ: "No",
          page: "conditional_question",
        }
      end

      it "routes to the appropriate conditional page based on the question answer of the current page" do
        post :submit_form, params: { id: id, case_log: case_log_form_conditional_question_yes_params }
        expect(response).to redirect_to("/case_logs/#{id}/conditional_question_yes_page")

        post :submit_form, params: { id: id, case_log: case_log_form_conditional_question_no_params }
        expect(response).to redirect_to("/case_logs/#{id}/conditional_question_no_page")
      end
    end
  end

  describe "get_next_page_path" do
    let(:previous_page) { "net_income" }
    let(:last_previous_page) { "housing_benefit" }
    let(:previous_conditional_page) { "conditional_question" }
    let(:form_handler) { FormHandler.instance }
    let(:form) { form_handler.get_form("test_form") }
    let(:case_log_controller) { CaseLogsController.new }

    it "returns a correct page path if there is no conditional routing" do
      expect(case_log_controller.send(:get_next_page_path, form, previous_page)).to eq("case_log_net_income_uc_proportion_path")
    end

    it "returns a check answers page if previous page is the last page" do
      expect(case_log_controller.send(:get_next_page_path, form, last_previous_page)).to eq("case_log_income_and_benefits_check_answers_path")
    end

    it "returns a correct page path if there is conditional routing" do
      responses_for_page = {}
      responses_for_page["preg_occ"] = "No"
      expect(case_log_controller.send(:get_next_page_path, form, previous_conditional_page, responses_for_page)).to eq("case_log_conditional_question_no_page_path")
    end
  end
end
