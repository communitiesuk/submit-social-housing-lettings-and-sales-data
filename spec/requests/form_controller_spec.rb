require "rails_helper"

RSpec.describe FormController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }
  let(:other_organisation) { FactoryBot.create(:organisation) }
  let!(:case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: organisation,
      managing_organisation: organisation,
    )
  end
  let!(:unauthorized_case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: other_organisation,
      managing_organisation: other_organisation,
    )
  end
  let(:headers) { { "Accept" => "text/html" } }

  context "a not signed in user" do
    describe "GET" do
      it "does not let you get case logs pages you don't have access to" do
        get "/logs/#{case_log.id}/person-1-age", headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end

      it "does not let you get case log check answer pages you don't have access to" do
        get "/logs/#{case_log.id}/household-characteristics/check-answers", headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end

    describe "POST" do
      it "does not let you post form answers to case logs you don't have access to" do
        post "/logs/#{case_log.id}/form", params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end
  end

  context "a signed in user" do
    before do
      sign_in user
    end

    describe "GET" do
      context "form pages" do
        context "case logs that are not owned or managed by your organisation" do
          it "does not show form pages for case logs you don't have access to" do
            get "/logs/#{unauthorized_case_log.id}/person-1-age", headers: headers, params: {}
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "check answers pages" do
        context "case logs that are not owned or managed by your organisation" do
          it "does not show a check answers for case logs you don't have access to" do
            get "/logs/#{unauthorized_case_log.id}/household-characteristics/check-answers", headers: headers, params: {}
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    describe "Submit Form" do
      context "a form page" do
        let(:user) { FactoryBot.create(:user) }
        let(:organisation) { user.organisation }
        let(:case_log) do
          FactoryBot.create(
            :case_log,
            owning_organisation: organisation,
            managing_organisation: organisation,
          )
        end
        let(:page_id) { "person_1_age" }
        let(:params) do
          {
            id: case_log.id,
            case_log: {
              page: page_id,
              age1: answer,
            },
          }
        end

        before do
          post "/logs/#{case_log.id}/form", params: params
        end

        context "invalid answers" do
          let(:answer) { 2000 }

          it "re-renders the same page with errors if validation fails" do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "valid answers" do
          let(:answer) { 20 }

          it "re-renders the same page with errors if validation fails" do
            expect(response).to have_http_status(:redirect)
          end

          let(:params) do
            {
              id: case_log.id,
              case_log: {
                page: page_id,
                age1: answer,
                age2: 2000,
              },
            }
          end

          it "only updates answers that apply to the page being submitted" do
            case_log.reload
            expect(case_log.age1).to eq(answer)
            expect(case_log.age2).to be nil
          end
        end
      end

      context "checkbox questions" do
        let(:case_log_form_params) do
          {
            id: case_log.id,
            case_log: {
              page: "accessibility_requirements",
              accessibility_requirements:
                                     %w[housingneeds_b],
            },
          }
        end

        let(:new_case_log_form_params) do
          {
            id: case_log.id,
            case_log: {
              page: "accessibility_requirements",
              accessibility_requirements: %w[housingneeds_c],
            },
          }
        end

        it "sets checked items to true" do
          post "/logs/#{case_log.id}/form", params: case_log_form_params
          case_log.reload

          expect(case_log.housingneeds_b).to eq("Yes")
        end

        it "sets previously submitted items to false when resubmitted with new values" do
          post "/logs/#{case_log.id}/form", params: new_case_log_form_params
          case_log.reload

          expect(case_log.housingneeds_b).to eq("No")
          expect(case_log.housingneeds_c).to eq("Yes")
        end

        context "given a page with checkbox and non-checkbox questions" do
          let(:tenant_code) { "BZ355" }
          let(:case_log_form_params) do
            {
              id: case_log.id,
              case_log: {
                page: "accessibility_requirements",
                accessibility_requirements:
                                       %w[ housingneeds_a
                                           housingneeds_f],
                tenant_code: tenant_code,
              },
            }
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
            post "/logs/#{case_log.id}/form", params: case_log_form_params
            case_log.reload

            expect(case_log.housingneeds_a).to eq("Yes")
            expect(case_log.housingneeds_f).to eq("Yes")
            expect(case_log.tenant_code).to eq(tenant_code)
          end
        end
      end

      context "conditional routing" do
        before do
          allow_any_instance_of(CaseLogValidator).to receive(:validate_pregnancy).and_return(true)
        end

        let(:case_log_form_conditional_question_yes_params) do
          {
            id: case_log.id,
            case_log: {
              page: "conditional_question",
              preg_occ: "Yes",
            },
          }
        end

        let(:case_log_form_conditional_question_no_params) do
          {
            id: case_log.id,
            case_log: {
              page: "conditional_question",
              preg_occ: "No",
            },
          }
        end

        it "routes to the appropriate conditional page based on the question answer of the current page" do
          post "/logs/#{case_log.id}/form", params: case_log_form_conditional_question_yes_params
          expect(response).to redirect_to("/logs/#{case_log.id}/conditional-question-yes-page")

          post "/logs/#{case_log.id}/form", params: case_log_form_conditional_question_no_params
          expect(response).to redirect_to("/logs/#{case_log.id}/conditional-question-no-page")
        end
      end

      context "case logs that are not owned or managed by your organisation" do
        let(:answer) { 25 }
        let(:other_organisation) { FactoryBot.create(:organisation) }
        let(:unauthorized_case_log) do
          FactoryBot.create(
            :case_log,
            owning_organisation: other_organisation,
            managing_organisation: other_organisation,
          )
        end

        before do
          post "/logs/#{unauthorized_case_log.id}/form", params: {}
        end

        it "does not let you post form answers to case logs you don't have access to" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
