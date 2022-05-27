require "rails_helper"

RSpec.describe CaseLogsController, type: :request do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:managing_organisation) { owning_organisation }
  let(:user) { FactoryBot.create(:user) }
  let(:api_username) { "test_user" }
  let(:api_password) { "test_password" }
  let(:basic_credentials) do
    ActionController::HttpAuthentication::Basic
      .encode_credentials(api_username, api_password)
  end

  let(:headers) do
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => basic_credentials,
    }
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("API_USER").and_return(api_username)
    allow(ENV).to receive(:[]).with("API_KEY").and_return(api_password)
  end

  describe "POST #create" do
    let(:tenant_code) { "T365" }
    let(:age1) { 35 }
    let(:offered) { 12 }
    let(:period) { 2 }
    let(:postcode_full) { "SE116TY" }
    let(:in_progress) { "in_progress" }
    let(:completed) { "completed" }

    context "when API" do
      let(:params) do
        {
          "owning_organisation_id": owning_organisation.id,
          "managing_organisation_id": managing_organisation.id,
          "created_by_id": user.id,
          "tenant_code": tenant_code,
          "age1": age1,
          "postcode_full": postcode_full,
          "offered": offered,
          "period": period,
        }
      end

      before do
        post "/logs", headers:, params: params.to_json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized Case Log" do
        json_response = JSON.parse(response.body)
        expect(json_response.keys).to match_array(CaseLog.new.attributes.keys)
      end

      it "creates a case log with the values passed" do
        json_response = JSON.parse(response.body)
        expect(json_response["tenant_code"]).to eq(tenant_code)
        expect(json_response["age1"]).to eq(age1)
        expect(json_response["postcode_full"]).to eq(postcode_full)
      end

      context "with invalid json parameters" do
        let(:age1) { 2000 }
        let(:offered) { 21 }

        it "validates case log parameters" do
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response["errors"]).to match_array([["offered", [I18n.t("validations.property.offered.relet_number")]], ["age1", [I18n.t("validations.numeric.valid", field: "Lead tenant’s age", min: 16, max: 120)]]])
        end
      end

      context "with a partial case log submission" do
        it "marks the record as in_progress" do
          json_response = JSON.parse(response.body)
          expect(json_response["status"]).to eq(in_progress)
        end
      end

      context "with a complete case log submission" do
        let(:org_params) do
          {
            "case_log" => {
              "owning_organisation_id" => owning_organisation.id,
              "managing_organisation_id" => managing_organisation.id,
              "created_by_id" => user.id,
            },
          }
        end
        let(:case_log_params) { JSON.parse(File.open("spec/fixtures/complete_case_log.json").read) }
        let(:params) do
          case_log_params.merge(org_params) { |_k, a_val, b_val| a_val.merge(b_val) }
        end

        it "marks the record as completed" do
          json_response = JSON.parse(response.body)

          expect(json_response).not_to have_key("errors")
          expect(json_response["status"]).to eq(completed)
        end
      end

      context "with a request containing invalid credentials" do
        let(:basic_credentials) do
          ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
        end

        it "returns 401" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "when UI" do
      let(:user) { FactoryBot.create(:user) }
      let(:headers) { { "Accept" => "text/html" } }

      before do
        RequestHelper.stub_http_requests
        sign_in user
        post "/logs", headers:
      end

      it "tracks who created the record" do
        created_id = response.location.match(/[0-9]+/)[0]
        whodunnit_actor = CaseLog.find_by(id: created_id).versions.last.actor
        expect(whodunnit_actor).to be_a(User)
        expect(whodunnit_actor.id).to eq(user.id)
      end
    end
  end

  describe "GET" do
    let(:page) { Capybara::Node::Simple.new(response.body) }
    let(:user) { FactoryBot.create(:user) }
    let(:organisation) { user.organisation }
    let(:other_organisation) { FactoryBot.create(:organisation) }
    let!(:case_log) do
      FactoryBot.create(
        :case_log,
        owning_organisation: organisation,
        managing_organisation: organisation,
        tenant_code: "LC783",
      )
    end
    let!(:unauthorized_case_log) do
      FactoryBot.create(
        :case_log,
        owning_organisation: other_organisation,
        managing_organisation: other_organisation,
        tenant_code: "UA984",
      )
    end

    context "when displaying a collection of logs" do
      let(:headers) { { "Accept" => "text/html" } }

      context "when the user is a customer support user" do
        let(:user) { FactoryBot.create(:user, :support) }

        before do
          allow(user).to receive(:need_two_factor_authentication?).and_return(false)
          sign_in user
        end

        it "does have organisation columns" do
          get "/logs", headers: headers, params: {}
          expect(page).to have_content("Owning organisation")
          expect(page).to have_content("Managing organisation")
        end

        it "shows case logs for all organisations" do
          get "/logs", headers: headers, params: {}
          expect(page).to have_content("LC783")
          expect(page).to have_content("UA984")
        end

        context "when there are no logs in the database" do
          before do
            CaseLog.destroy_all
          end

          it "page has correct title" do
            get "/logs", headers: headers, params: {}
            expect(page).to have_title("Logs - Submit social housing and sales data (CORE) - GOV.UK")
          end
        end

        context "when filtering" do
          context "with status filter" do
            let(:organisation_2) { FactoryBot.create(:organisation) }
            let!(:in_progress_case_log) do
              FactoryBot.create(:case_log, :in_progress,
                                owning_organisation: organisation,
                                managing_organisation: organisation)
            end
            let!(:completed_case_log) do
              FactoryBot.create(:case_log, :completed,
                                owning_organisation: organisation_2,
                                managing_organisation: organisation)
            end

            it "shows case logs for multiple selected statuses" do
              get "/logs?status[]=in_progress&status[]=completed", headers: headers, params: {}
              expect(page).to have_link(in_progress_case_log.id.to_s)
              expect(page).to have_link(completed_case_log.id.to_s)
            end

            it "shows case logs for one selected status" do
              get "/logs?status[]=in_progress", headers: headers, params: {}
              expect(page).to have_link(in_progress_case_log.id.to_s)
              expect(page).not_to have_link(completed_case_log.id.to_s)
            end

            it "filters on organisation" do
              get "/logs?organisation[]=#{organisation_2.id}", headers: headers, params: {}
              expect(page).to have_link(completed_case_log.id.to_s)
              expect(page).not_to have_link(in_progress_case_log.id.to_s)
            end

            it "does not reset the filters" do
              get "/logs?status[]=in_progress", headers: headers, params: {}
              expect(page).to have_link(in_progress_case_log.id.to_s)
              expect(page).not_to have_link(completed_case_log.id.to_s)

              get "/logs", headers: headers, params: {}
              expect(page).to have_link(in_progress_case_log.id.to_s)
              expect(page).not_to have_link(completed_case_log.id.to_s)
            end
          end

          context "with year filter" do
            let!(:case_log_2021) do
              FactoryBot.create(:case_log, :in_progress,
                                owning_organisation: organisation,
                                startdate: Time.zone.local(2022, 3, 1),
                                managing_organisation: organisation)
            end
            let!(:case_log_2022) do
              FactoryBot.create(:case_log, :completed,
                                owning_organisation: organisation,
                                mrcdate: Time.zone.local(2022, 2, 1),
                                startdate: Time.zone.local(2022, 12, 1),
                                tenancy: 6,
                                managing_organisation: organisation)
            end

            it "shows case logs for multiple selected years" do
              get "/logs?years[]=2021&years[]=2022", headers: headers, params: {}
              expect(page).to have_link(case_log_2021.id.to_s)
              expect(page).to have_link(case_log_2022.id.to_s)
            end

            it "shows case logs for one selected year" do
              get "/logs?years[]=2021", headers: headers, params: {}
              expect(page).to have_link(case_log_2021.id.to_s)
              expect(page).not_to have_link(case_log_2022.id.to_s)
            end
          end

          context "with year and status filter" do
            let!(:case_log_2021) do
              FactoryBot.create(:case_log, :in_progress,
                                owning_organisation: organisation,
                                startdate: Time.zone.local(2022, 3, 1),
                                managing_organisation: organisation)
            end
            let!(:case_log_2022) do
              FactoryBot.create(:case_log, :completed,
                                owning_organisation: organisation,
                                mrcdate: Time.zone.local(2022, 2, 1),
                                startdate: Time.zone.local(2022, 12, 1),
                                tenancy: 6,
                                managing_organisation: organisation)
            end
            let!(:case_log_2022_in_progress) do
              FactoryBot.create(:case_log, :in_progress,
                                owning_organisation: organisation,
                                mrcdate: Time.zone.local(2022, 2, 1),
                                startdate: Time.zone.local(2022, 12, 1),
                                tenancy: 6,
                                managing_organisation: organisation)
            end

            it "shows case logs for multiple selected statuses and years" do
              get "/logs?years[]=2021&years[]=2022&status[]=in_progress&status[]=completed", headers: headers, params: {}
              expect(page).to have_link(case_log_2021.id.to_s)
              expect(page).to have_link(case_log_2022.id.to_s)
              expect(page).to have_link(case_log_2022_in_progress.id.to_s)
            end

            it "shows case logs for one selected status" do
              get "/logs?years[]=2022&status[]=in_progress", headers: headers, params: {}
              expect(page).to have_link(case_log_2022_in_progress.id.to_s)
              expect(page).not_to have_link(case_log_2021.id.to_s)
              expect(page).not_to have_link(case_log_2022.id.to_s)
            end
          end
        end
      end

      context "when the user is not a customer support user" do
        before do
          sign_in user
        end

        it "does not have organisation columns" do
          get "/logs", headers: headers, params: {}
          expect(page).not_to have_content("Owning organisation")
          expect(page).not_to have_content("Managing organisation")
        end

        context "when using a search query" do
          let(:logs) { FactoryBot.create_list(:case_log, 3, :completed, owning_organisation: user.organisation) }
          let(:log_to_search) { FactoryBot.create(:case_log, :completed, owning_organisation: user.organisation) }

          it "has search results in the title" do
            get "/logs?search=#{log_to_search.id}", headers: headers, params: {}
            expect(page).to have_content("Logs (search results for ‘#{log_to_search.id}’) - Submit social housing and sales data (CORE) - GOV.UK")
          end

          it "shows case logs matching the id" do
            get "/logs?search=#{log_to_search.id}", headers: headers, params: {}
            expect(page).to have_content(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_content(log.id.to_s)
            end
          end

          it "shows case logs matching the tenant code" do
            get "/logs?search=#{log_to_search.tenant_code}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          it "shows case logs matching the property reference" do
            get "/logs?search=#{log_to_search.propcode}", headers: headers, params: {}
            expect(page).to have_content(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          it "shows case logs matching the property postcode" do
            get "/logs?search=#{log_to_search.postcode_full}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          context "when more than one results with matching postcode" do
            let!(:matching_postcode_log) { FactoryBot.create(:case_log, :completed, owning_organisation: user.organisation, postcode_full: log_to_search.postcode_full) }

            it "displays all matching logs" do
              get "/logs?search=#{log_to_search.postcode_full}", headers: headers, params: {}
              expect(page).to have_link(log_to_search.id.to_s)
              expect(page).to have_content(matching_postcode_log.id)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end
          end

          context "when there are more than 1 page of search results" do
            let(:logs) { FactoryBot.create_list(:case_log, 30, :completed, owning_organisation: user.organisation, postcode_full: "XX1 1YY") }

            it "has title with pagination details for page 1" do
              get "/logs?search=#{logs[0].postcode_full}", headers: headers, params: {}
              expect(page).to have_content("Logs (search results for ‘#{logs[0].postcode_full}’, page 1 of 2) - Submit social housing and sales data (CORE) - GOV.UK")
            end

            it "has title with pagination details for page 2" do
              get "/logs?search=#{logs[0].postcode_full}&page=2", headers: headers, params: {}
              expect(page).to have_content("Logs (search results for ‘#{logs[0].postcode_full}’, page 2 of 2) - Submit social housing and sales data (CORE) - GOV.UK")
            end
          end

          context "when search query doesn't match any logs" do
            it "doesn't display any logs" do
              get "/logs?search=foobar", headers:, params: {}
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
              expect(page).not_to have_link(log_to_search.id.to_s)
            end
          end

          context "when search query is empty" do
            it "doesn't display any logs" do
              get "/logs?search=", headers:, params: {}
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
              expect(page).not_to have_link(log_to_search.id.to_s)
            end
          end

          context "when search and filter is present" do
            let(:matching_postcode) { log_to_search.postcode_full }
            let(:matching_status) { "in_progress" }
            let!(:log_matching_filter_and_search) { FactoryBot.create(:case_log, :in_progress, owning_organisation: user.organisation, postcode_full: matching_postcode) }

            it "shows only logs matching both search and filters" do
              get "/logs?search=#{matching_postcode}&status[]=#{matching_status}", headers: headers, params: {}
              expect(page).to have_link(log_matching_filter_and_search.id.to_s)
              expect(page).not_to have_link(log_to_search.id.to_s)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end
          end
        end

        context "when there are less than 20 logs" do
          before do
            get "/logs", headers:, params: {}
          end

          it "shows a table of logs" do
            expect(CGI.unescape_html(response.body)).to match(/<table class="govuk-table">/)
            expect(CGI.unescape_html(response.body)).to match(/logs/)
          end

          it "only shows case logs for your organisation" do
            expected_case_row_log = "<span class=\"govuk-visually-hidden\">Log </span>#{case_log.id}"
            unauthorized_case_row_log = "<span class=\"govuk-visually-hidden\">Log </span>#{unauthorized_case_log.id}"
            expect(CGI.unescape_html(response.body)).to include(expected_case_row_log)
            expect(CGI.unescape_html(response.body)).not_to include(unauthorized_case_row_log)
          end

          it "shows the formatted created at date for each log" do
            formatted_date = case_log.created_at.to_formatted_s(:govuk_date)
            expect(CGI.unescape_html(response.body)).to include(formatted_date)
          end

          it "shows the log's status" do
            expect(CGI.unescape_html(response.body)).to include(case_log.status.humanize)
          end

          it "shows the total log count" do
            expect(CGI.unescape_html(response.body)).to match("<strong>1</strong> total logs")
          end

          it "does not show the pagination links" do
            expect(page).not_to have_link("Previous")
            expect(page).not_to have_link("Next")
          end

          it "does not show the pagination result line" do
            expect(CGI.unescape_html(response.body)).not_to match("Showing <b>1</b> to <b>20</b> of <b>26</b> logs")
          end

          it "does not have pagination in the title" do
            expect(page).to have_title("Logs - Submit social housing and sales data (CORE) - GOV.UK")
          end

          it "shows the download csv link" do
            expect(page).to have_link("Download (CSV)", href: "/logs.csv")
          end

          it "does not show the organisation filter" do
            expect(page).not_to have_field("organisation-field")
          end
        end

        context "when the user is a customer support user" do
          let(:user) { FactoryBot.create(:user, :support) }
          let(:org_1) { FactoryBot.create(:organisation) }
          let(:org_2) { FactoryBot.create(:organisation) }
          let(:tenant_code_1) { "TC5638" }
          let(:tenant_code_2) { "TC8745" }

          before do
            FactoryBot.create(:case_log, :in_progress, owning_organisation: org_1, tenant_code: tenant_code_1)
            FactoryBot.create(:case_log, :in_progress, owning_organisation: org_2, tenant_code: tenant_code_2)
            allow(user).to receive(:need_two_factor_authentication?).and_return(false)
            sign_in user
          end

          it "does show the organisation filter" do
            get "/logs", headers:, params: {}
            expect(page).to have_field("organisation-field")
          end

          it "shows all logs by default" do
            get "/logs", headers:, params: {}
            expect(page).to have_content(tenant_code_1)
            expect(page).to have_content(tenant_code_2)
          end

          context "when filtering by organisation" do
            it "only show the selected organisations logs" do
              get "/logs?organisation_select=specific_org&organisation=#{org_1.id}", headers:, params: {}
              expect(page).to have_content(tenant_code_1)
              expect(page).not_to have_content(tenant_code_2)
            end
          end

          context "when the support user has filtered by organisation, then switches back to all organisations" do
            it "shows all organisations" do
              get "http://localhost:3000/logs?%5Byears%5D%5B%5D=&%5Bstatus%5D%5B%5D=&user=all&organisation_select=all&organisation=#{org_1.id}", headers:, params: {}
              expect(page).to have_content(tenant_code_1)
              expect(page).to have_content(tenant_code_2)
            end
          end
        end

        context "when there are more than 20 logs" do
          before do
            FactoryBot.create_list(:case_log, 25, owning_organisation: organisation, managing_organisation: organisation)
          end

          context "when on the first page" do
            before do
              get "/logs", headers:, params: {}
            end

            it "has pagination links" do
              expect(page).to have_content("Previous")
              expect(page).not_to have_link("Previous")
              expect(page).to have_content("Next")
              expect(page).to have_link("Next")
            end

            it "shows which logs are being shown on the current page" do
              expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>26</b> logs")
            end

            it "has pagination in the title" do
              expect(page).to have_title("Logs (page 1 of 2) - Submit social housing and sales data (CORE) - GOV.UK")
            end
          end

          context "when on the second page" do
            before do
              get "/logs?page=2", headers:, params: {}
            end

            it "shows the total log count" do
              expect(CGI.unescape_html(response.body)).to match("<strong>26</strong> total logs")
            end

            it "has pagination links" do
              expect(page).to have_content("Previous")
              expect(page).to have_link("Previous")
              expect(page).to have_content("Next")
              expect(page).not_to have_link("Next")
            end

            it "shows which logs are being shown on the current page" do
              expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>26</b> of <b>26</b> logs")
            end

            it "has pagination in the title" do
              expect(page).to have_title("Logs (page 2 of 2) - Submit social housing and sales data (CORE) - GOV.UK")
            end
          end
        end
      end
    end

    context "when requesting a specific case log" do
      let(:completed_case_log) { FactoryBot.create(:case_log, :completed) }
      let(:id) { completed_case_log.id }

      before do
        get "/logs/#{id}", headers:
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized Case Log" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(completed_case_log.status)
      end

      context "when requesting an invalid case log id" do
        let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

        it "returns 404" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when editing a case log" do
        let(:headers) { { "Accept" => "text/html" } }

        context "with a user that is not signed in" do
          it "does not let the user get case log tasklist pages they don't have access to" do
            get "/logs/#{case_log.id}", headers: headers, params: {}
            expect(response).to redirect_to("/account/sign-in")
          end
        end

        context "with a signed in user" do
          context "with case logs that are owned or managed by your organisation" do
            before do
              sign_in user
              get "/logs/#{case_log.id}", headers:, params: {}
            end

            it "shows the tasklist for case logs you have access to" do
              expect(response.body).to match("Log")
              expect(response.body).to match(case_log.id.to_s)
            end

            it "displays a section status for a case log" do
              assert_select ".govuk-tag", text: /Not started/, count: 7
              assert_select ".govuk-tag", text: /In progress/, count: 1
              assert_select ".govuk-tag", text: /Completed/, count: 0
              assert_select ".govuk-tag", text: /Cannot start yet/, count: 1
            end
          end

          context "with a case log with a single section complete" do
            let(:section_completed_case_log) do
              FactoryBot.create(
                :case_log,
                :conditional_section_complete,
                owning_organisation: organisation,
                managing_organisation: organisation,
              )
            end

            before do
              sign_in user
              get "/logs/#{section_completed_case_log.id}", headers:, params: {}
            end

            it "displays a section status for a case log" do
              assert_select ".govuk-tag", text: /Not started/, count: 7
              assert_select ".govuk-tag", text: /Completed/, count: 1
              assert_select ".govuk-tag", text: /Cannot start yet/, count: 1
            end
          end

          context "with case logs that are not owned or managed by your organisation" do
            before do
              sign_in user
              get "/logs/#{unauthorized_case_log.id}", headers:, params: {}
            end

            it "does not show the tasklist for case logs you don't have access to" do
              expect(response).to have_http_status(:not_found)
            end
          end
        end
      end
    end

    context "when accessing the check answers page" do
      let(:postcode_case_log) do
        FactoryBot.create(:case_log,
                          owning_organisation: organisation,
                          managing_organisation: organisation,
                          postcode_known: "No")
      end
      let(:id) { postcode_case_log.id }

      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
        sign_in user
      end

      it "shows the inferred la" do
        case_log = FactoryBot.create(:case_log,
                                     owning_organisation: organisation,
                                     managing_organisation: organisation,
                                     postcode_known: 1,
                                     postcode_full: "PO5 3TE")
        id = case_log.id
        get "/logs/#{id}/property-information/check-answers"
        expected_inferred_answer = "<span class=\"govuk-!-font-weight-regular app-!-colour-muted\">Manchester</span>"
        expect(CGI.unescape_html(response.body)).to include(expected_inferred_answer)
      end

      it "does not show do you know the property postcode question" do
        get "/logs/#{id}/property-information/check-answers"
        expect(CGI.unescape_html(response.body)).not_to include("Do you know the property postcode?")
      end

      it "shows if the postcode is not known" do
        get "/logs/#{id}/property-information/check-answers"
        expect(CGI.unescape_html(response.body)).to include("Not known")
      end

      it "shows `you haven't answered this question` if the question wasn't answered" do
        get "/logs/#{id}/income-and-benefits/check-answers"
        expect(CGI.unescape_html(response.body)).to include("You didn’t answer this question")
      end
    end
  end

  describe "CSV download" do
    let(:headers) { { "Accept" => "text/csv" } }
    let(:user) { FactoryBot.create(:user) }
    let(:organisation) { user.organisation }
    let(:other_organisation) { FactoryBot.create(:organisation) }

    context "when a log exists" do
      let!(:case_log) do
        FactoryBot.create(
          :case_log,
          owning_organisation: organisation,
          managing_organisation: organisation,
          ecstat1: 1,
        )
      end

      before do
        sign_in user
        FactoryBot.create(:case_log)
        FactoryBot.create(:case_log,
                          :completed,
                          owning_organisation: organisation,
                          managing_organisation: organisation)
        get "/logs", headers:, params: {}
      end

      it "downloads a CSV file with headers" do
        csv = CSV.parse(response.body)
        expect(csv.first.first).to eq("id")
        expect(csv.second.first).to eq(case_log.id.to_s)
      end

      it "does not download other orgs logs" do
        csv = CSV.parse(response.body)
        expect(csv.count).to eq(3)
      end

      it "downloads answer labels rather than values" do
        csv = CSV.parse(response.body)
        expect(csv.second[10]).to eq("Full-time – 30 hours or more")
      end

      it "dowloads filtered logs" do
        get "/logs?status[]=completed", headers:, params: {}
        csv = CSV.parse(response.body)
        expect(csv.count).to eq(2)
      end
    end

    context "when there are more than 20 logs" do
      before do
        sign_in user
        FactoryBot.create_list(:case_log, 26, owning_organisation: organisation)
        get "/logs", headers:, params: {}
      end

      it "does not paginate, it downloads all the user's logs" do
        csv = CSV.parse(response.body)
        expect(csv.count).to eq(27)
      end
    end
  end

  describe "PATCH" do
    let(:case_log) do
      FactoryBot.create(:case_log, :in_progress, tenant_code: "Old Value", postcode_full: "M1 1AE")
    end
    let(:params) do
      { tenant_code: "New Value" }
    end
    let(:id) { case_log.id }

    before do
      patch "/logs/#{id}", headers:, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the case log with the given fields and keeps original values where none are passed" do
      case_log.reload
      expect(case_log.tenant_code).to eq("New Value")
      expect(case_log.postcode_full).to eq("M11AE")
    end

    context "with an invalid case log id" do
      let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an invalid case log params" do
      let(:params) { { age1: 200 } }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq({ "age1" => ["Lead tenant’s age must be between 16 and 120"] })
      end
    end

    context "with a request containing invalid credentials" do
      let(:basic_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # We don't really have any meaningful distinction between PUT and PATCH here since you can update some or all
  # fields in both cases, and both route to #Update. Rails generally recommends PATCH as it more closely matches
  # what actually happens to an ActiveRecord object and what we're doing here, but either is allowed.
  describe "PUT" do
    let(:case_log) do
      FactoryBot.create(:case_log, :in_progress, tenant_code: "Old Value", postcode_full: "SW1A 2AA")
    end
    let(:params) do
      { tenant_code: "New Value" }
    end
    let(:id) { case_log.id }

    before do
      put "/logs/#{id}", headers:, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the case log with the given fields and keeps original values where none are passed" do
      case_log.reload
      expect(case_log.tenant_code).to eq("New Value")
      expect(case_log.postcode_full).to eq("SW1A2AA")
    end

    context "with an invalid case log id" do
      let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a request containing invalid credentials" do
      let(:basic_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
      end

      it "returns 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE" do
    let!(:case_log) do
      FactoryBot.create(:case_log, :in_progress)
    end
    let(:id) { case_log.id }

    context "when deleting a case log" do
      before do
        delete "/logs/#{id}", headers:
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "deletes the case log" do
        expect { CaseLog.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "with an invalid case log id" do
        let(:id) { (CaseLog.order(:id).last&.id || 0) + 1 }

        it "returns 404" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "with a request containing invalid credentials" do
        let(:basic_credentials) do
          ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
        end

        it "returns 401" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "when a case log deletion fails" do
      before do
        allow(CaseLog).to receive(:find_by).and_return(case_log)
        allow(case_log).to receive(:delete).and_return(false)
        delete "/logs/#{id}", headers:
      end

      it "returns an unprocessable entity 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
