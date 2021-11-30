require "rails_helper"

RSpec.describe CaseLogsController, type: :controller do
  let(:valid_session) { {} }
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { case_log.id }

  before do
    sign_in user
  end

  context "Collection routes" do
    describe "GET #index" do
      it "returns a success response" do
        get :index, params: {}, session: valid_session
        expect(response).to be_successful
      end
    end

    describe "Post #create" do
      let(:owning_organisation) { FactoryBot.create(:organisation) }
      let(:managing_organisation) { owning_organisation }
      let(:params) do
        {
          "owning_organisation_id": owning_organisation.id,
          "managing_organisation_id": managing_organisation.id,
        }
      end

      it "creates a new case log record" do
        expect {
          post :create, params: params, session: valid_session
        }.to change(CaseLog, :count).by(1)
      end

      it "redirects to that case log" do
        post :create, params: params, session: valid_session
        expect(response.status).to eq(302)
      end
    end
  end

  context "Instance routes" do
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
        [
          Form::Question.new(
            "accessibility_requirements",
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
            }, nil
          ),
          Form::Question.new("tenant_code", { "type" => "text" }, nil),
        ]
      end

      it "updates both question fields" do
        allow_any_instance_of(Form::Page).to receive(:expected_responses).and_return(questions_for_page)
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
        allow_any_instance_of(CaseLogValidator).to receive(:validate_pregnancy).and_return(true)
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
end
