require "rails_helper"

RSpec.describe LettingsLogsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:owning_organisation) { user.organisation }
  let(:managing_organisation) { owning_organisation }
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
    let(:postcode_full) { "SE11 6TY" }
    let(:in_progress) { "in_progress" }
    let(:completed) { "completed" }

    context "when API" do
      let(:params) do
        {
          "owning_organisation_id": owning_organisation.id,
          "managing_organisation_id": managing_organisation.id,
          "created_by_id": user.id,
          "tenancycode": tenant_code,
          "age1": age1,
          "postcode_full": postcode_full,
          "offered": offered,
          "period": period,
        }
      end

      before do
        Timecop.freeze(Time.utc(2022, 2, 8))
        post "/lettings-logs", headers:, params: params.to_json
      end

      after do
        Timecop.unfreeze
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized lettings log" do
        json_response = JSON.parse(response.body)
        expect(json_response.keys).to match_array(LettingsLog.new.attributes.keys)
      end

      it "creates a lettings log with the values passed" do
        json_response = JSON.parse(response.body)
        expect(json_response["tenancycode"]).to eq(tenant_code)
        expect(json_response["age1"]).to eq(age1)
        expect(json_response["postcode_full"]).to eq(postcode_full)
      end

      context "with invalid json parameters" do
        let(:age1) { 2000 }
        let(:offered) { 21 }

        it "validates lettings log parameters" do
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response["errors"]).to match_array([["offered", [I18n.t("validations.property.offered.relet_number")]], ["age1", [I18n.t("validations.numeric.valid", field: "Lead tenant’s age", min: 16, max: 120)]]])
        end
      end

      context "with a partial lettings log submission" do
        it "marks the record as in_progress" do
          json_response = JSON.parse(response.body)
          expect(json_response["status"]).to eq(in_progress)
        end
      end

      context "with a complete lettings log submission" do
        let(:org_params) do
          {
            "lettings_log" => {
              "owning_organisation_id" => owning_organisation.id,
              "managing_organisation_id" => managing_organisation.id,
              "created_by_id" => user.id,
            },
          }
        end
        let(:lettings_log_params) { JSON.parse(File.open("spec/fixtures/complete_lettings_log.json").read) }
        let(:params) do
          lettings_log_params.merge(org_params) { |_k, a_val, b_val| a_val.merge(b_val) }
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
        post "/lettings-logs", headers:
      end

      it "tracks who created the record" do
        created_id = response.location.match(/[0-9]+/)[0]
        whodunnit_actor = LettingsLog.find_by(id: created_id).versions.last.actor
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
    let!(:lettings_log) do
      FactoryBot.create(
        :lettings_log,
        owning_organisation: organisation,
        managing_organisation: organisation,
        tenancycode: "LC783",
      )
    end
    let!(:unauthorized_lettings_log) do
      FactoryBot.create(
        :lettings_log,
        owning_organisation: other_organisation,
        managing_organisation: other_organisation,
        tenancycode: "UA984",
      )
    end

    context "when displaying a collection of logs" do
      let(:headers) { { "Accept" => "text/html" } }

      context "when you visit the index page" do
        let(:user) { FactoryBot.create(:user, :support) }

        before do
          allow(user).to receive(:need_two_factor_authentication?).and_return(false)
          sign_in user
        end

        it "does not have a button for creating sales logs" do
          get "/lettings-logs", headers:, params: {}
          page.assert_selector(".govuk-button", text: "Create a new sales log", count: 0)
          page.assert_selector(".govuk-button", text: "Create a new lettings log", count: 1)
        end
      end

      context "when the user is a customer support user" do
        let(:user) { FactoryBot.create(:user, :support) }

        before do
          allow(user).to receive(:need_two_factor_authentication?).and_return(false)
          sign_in user
        end

        it "does have organisation values" do
          get "/lettings-logs", headers: headers, params: {}
          expect(page).to have_content("Owned by")
          expect(page).to have_content("Managed by")
        end

        it "shows lettings logs for all organisations" do
          get "/lettings-logs", headers: headers, params: {}
          expect(page).to have_content("LC783")
          expect(page).to have_content("UA984")
        end

        context "when there are no logs in the database" do
          before do
            LettingsLog.destroy_all
          end

          it "page has correct title" do
            get "/lettings-logs", headers: headers, params: {}
            expect(page).to have_title("Logs - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end
        end

        context "when filtering" do
          context "with status filter" do
            let(:organisation_2) { FactoryBot.create(:organisation) }
            let(:user_2) { FactoryBot.create(:user, organisation: organisation_2) }
            let!(:in_progress_lettings_log) do
              FactoryBot.create(:lettings_log, :in_progress,
                                owning_organisation: organisation,
                                managing_organisation: organisation,
                                created_by: user)
            end
            let!(:completed_lettings_log) do
              FactoryBot.create(:lettings_log, :completed,
                                owning_organisation: organisation_2,
                                managing_organisation: organisation,
                                created_by: user_2)
            end

            it "shows lettings logs for multiple selected statuses" do
              get "/lettings-logs?status[]=in_progress&status[]=completed", headers: headers, params: {}
              expect(page).to have_link(in_progress_lettings_log.id.to_s)
              expect(page).to have_link(completed_lettings_log.id.to_s)
            end

            it "shows lettings logs for one selected status" do
              get "/lettings-logs?status[]=in_progress", headers: headers, params: {}
              expect(page).to have_link(in_progress_lettings_log.id.to_s)
              expect(page).not_to have_link(completed_lettings_log.id.to_s)
            end

            it "filters on organisation" do
              get "/lettings-logs?organisation[]=#{organisation_2.id}", headers: headers, params: {}
              expect(page).to have_link(completed_lettings_log.id.to_s)
              expect(page).not_to have_link(in_progress_lettings_log.id.to_s)
            end

            it "does not reset the filters" do
              get "/lettings-logs?status[]=in_progress", headers: headers, params: {}
              expect(page).to have_link(in_progress_lettings_log.id.to_s)
              expect(page).not_to have_link(completed_lettings_log.id.to_s)

              get "/lettings-logs", headers: headers, params: {}
              expect(page).to have_link(in_progress_lettings_log.id.to_s)
              expect(page).not_to have_link(completed_lettings_log.id.to_s)
            end
          end

          context "with year filter" do
            let!(:lettings_log_2021) do
              FactoryBot.create(:lettings_log, :in_progress,
                                owning_organisation: organisation,
                                startdate: Time.zone.local(2022, 3, 1),
                                managing_organisation: organisation)
            end
            let!(:lettings_log_2022) do
              lettings_log = FactoryBot.build(:lettings_log, :completed,
                                              owning_organisation: organisation,
                                              mrcdate: Time.zone.local(2022, 2, 1),
                                              startdate: Time.zone.local(2022, 12, 1),
                                              tenancy: 6,
                                              managing_organisation: organisation)
              lettings_log.save!(validate: false)
              lettings_log
            end

            it "shows lettings logs for multiple selected years" do
              get "/lettings-logs?years[]=2021&years[]=2022", headers: headers, params: {}
              expect(page).to have_link(lettings_log_2021.id.to_s)
              expect(page).to have_link(lettings_log_2022.id.to_s)
            end

            it "shows lettings logs for one selected year" do
              get "/lettings-logs?years[]=2021", headers: headers, params: {}
              expect(page).to have_link(lettings_log_2021.id.to_s)
              expect(page).not_to have_link(lettings_log_2022.id.to_s)
            end
          end

          context "with year and status filter" do
            before do
              Timecop.freeze(Time.zone.local(2022, 12, 1))
            end

            after do
              Timecop.unfreeze
            end

            let!(:lettings_log_2021) do
              FactoryBot.create(:lettings_log, :in_progress,
                                owning_organisation: organisation,
                                startdate: Time.zone.local(2022, 3, 1),
                                managing_organisation: organisation,
                                created_by: user)
            end
            let!(:lettings_log_2022) do
              FactoryBot.create(:lettings_log, :completed,
                                owning_organisation: organisation,
                                mrcdate: Time.zone.local(2022, 2, 1),
                                startdate: Time.zone.local(2022, 12, 1),
                                tenancy: 6,
                                managing_organisation: organisation,
                                created_by: user)
            end
            let!(:lettings_log_2022_in_progress) do
              FactoryBot.build(:lettings_log, :in_progress,
                               owning_organisation: organisation,
                               mrcdate: Time.zone.local(2022, 2, 1),
                               startdate: Time.zone.local(2022, 12, 1),
                               tenancy: 6,
                               managing_organisation: organisation,
                               tenancycode: nil,
                               created_by: user)
            end

            it "shows lettings logs for multiple selected statuses and years" do
              get "/lettings-logs?years[]=2021&years[]=2022&status[]=in_progress&status[]=completed", headers: headers, params: {}
              expect(page).to have_link(lettings_log_2021.id.to_s)
              expect(page).to have_link(lettings_log_2022.id.to_s)
              expect(page).to have_link(lettings_log_2022_in_progress.id.to_s)
            end

            it "shows lettings logs for one selected status" do
              get "/lettings-logs?years[]=2022&status[]=in_progress", headers: headers, params: {}
              expect(page).to have_link(lettings_log_2022_in_progress.id.to_s)
              expect(page).not_to have_link(lettings_log_2021.id.to_s)
              expect(page).not_to have_link(lettings_log_2022.id.to_s)
            end
          end
        end
      end

      context "when the user is not a customer support user" do
        before do
          sign_in user
        end

        it "does not have organisation columns" do
          get "/lettings-logs", headers: headers, params: {}
          expect(page).not_to have_content("Owning organisation")
          expect(page).not_to have_content("Managing organisation")
        end

        context "when using a search query" do
          let(:logs) { FactoryBot.create_list(:lettings_log, 3, :completed, owning_organisation: user.organisation, created_by: user) }
          let(:log_to_search) { FactoryBot.create(:lettings_log, :completed, owning_organisation: user.organisation, created_by: user) }
          let(:log_total_count) { LettingsLog.where(owning_organisation: user.organisation).count }

          it "has search results in the title" do
            get "/lettings-logs?search=#{log_to_search.id}", headers: headers, params: {}
            expect(page).to have_title("Logs (1 log matching ‘#{log_to_search.id}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end

          it "shows lettings logs matching the id" do
            get "/lettings-logs?search=#{log_to_search.id}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          it "shows lettings logs matching the tenant code" do
            get "/lettings-logs?search=#{log_to_search.tenancycode}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          it "shows lettings logs matching the property reference" do
            get "/lettings-logs?search=#{log_to_search.propcode}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          it "shows lettings logs matching the property postcode" do
            get "/lettings-logs?search=#{log_to_search.postcode_full}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          it "includes the search on the CSV link" do
            search_term = "foo"
            get "/lettings-logs?search=#{search_term}", headers: headers, params: {}
            expect(page).to have_link("Download (CSV)", href: "/lettings-logs/csv-download?search=#{search_term}")
          end

          context "when more than one results with matching postcode" do
            let!(:matching_postcode_log) { FactoryBot.create(:lettings_log, :completed, owning_organisation: user.organisation, postcode_full: log_to_search.postcode_full) }

            it "displays all matching logs" do
              get "/lettings-logs?search=#{log_to_search.postcode_full}", headers: headers, params: {}
              expect(page).to have_link(log_to_search.id.to_s)
              expect(page).to have_link(matching_postcode_log.id.to_s)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end
          end

          context "when there are more than 1 page of search results" do
            let(:postcode) { "XX11YY" }
            let(:logs) { FactoryBot.create_list(:lettings_log, 30, :completed, owning_organisation: user.organisation, postcode_full: postcode, created_by: user) }
            let(:log_total_count) { LettingsLog.where(owning_organisation: user.organisation).count }

            it "has title with pagination details for page 1" do
              get "/lettings-logs?search=#{logs[0].postcode_full}", headers: headers, params: {}
              expect(page).to have_title("Logs (#{logs.count} logs matching ‘#{postcode}’) (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            end

            it "has title with pagination details for page 2" do
              get "/lettings-logs?search=#{logs[0].postcode_full}&page=2", headers: headers, params: {}
              expect(page).to have_title("Logs (#{logs.count} logs matching ‘#{postcode}’) (page 2 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            end
          end

          context "when search query doesn't match any logs" do
            it "doesn't display any logs" do
              get "/lettings-logs?search=foobar", headers:, params: {}
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
              expect(page).not_to have_link(log_to_search.id.to_s)
            end
          end

          context "when search query is empty" do
            it "doesn't display any logs" do
              get "/lettings-logs?search=", headers:, params: {}
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
              expect(page).not_to have_link(log_to_search.id.to_s)
            end
          end

          context "when search and filter is present" do
            let(:matching_postcode) { log_to_search.postcode_full }
            let(:matching_status) { "in_progress" }
            let!(:log_matching_filter_and_search) { FactoryBot.create(:lettings_log, :in_progress, owning_organisation: user.organisation, postcode_full: matching_postcode, created_by: user) }

            it "shows only logs matching both search and filters" do
              get "/lettings-logs?search=#{matching_postcode}&status[]=#{matching_status}", headers: headers, params: {}
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
            get "/lettings-logs", headers:, params: {}
          end

          it "shows a table of logs" do
            expect(CGI.unescape_html(response.body)).to match(/<article class="app-log-summary">/)
            expect(CGI.unescape_html(response.body)).to match(/lettings-logs/)
          end

          it "only shows lettings logs for your organisation" do
            expected_case_row_log = "<span class=\"govuk-visually-hidden\">Log </span>#{lettings_log.id}"
            unauthorized_case_row_log = "<span class=\"govuk-visually-hidden\">Log </span>#{unauthorized_lettings_log.id}"
            expect(CGI.unescape_html(response.body)).to include(expected_case_row_log)
            expect(CGI.unescape_html(response.body)).not_to include(unauthorized_case_row_log)
          end

          it "shows the formatted created at date for each log" do
            formatted_date = lettings_log.created_at.to_formatted_s(:govuk_date)
            expect(CGI.unescape_html(response.body)).to include(formatted_date)
          end

          it "shows the log's status" do
            expect(CGI.unescape_html(response.body)).to include(lettings_log.status.humanize)
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
            expect(page).to have_title("Logs - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end

          it "shows the CSV download link" do
            expect(page).to have_link("Download (CSV)", href: "/lettings-logs/csv-download")
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
            FactoryBot.create(:lettings_log, :in_progress, owning_organisation: org_1, tenancycode: tenant_code_1)
            FactoryBot.create(:lettings_log, :in_progress, owning_organisation: org_2, tenancycode: tenant_code_2)
            allow(user).to receive(:need_two_factor_authentication?).and_return(false)
            sign_in user
          end

          it "does show the organisation filter" do
            get "/lettings-logs", headers:, params: {}
            expect(page).to have_field("organisation-field")
          end

          it "shows all logs by default" do
            get "/lettings-logs", headers:, params: {}
            expect(page).to have_content(tenant_code_1)
            expect(page).to have_content(tenant_code_2)
          end

          context "when filtering by organisation" do
            it "only show the selected organisations logs" do
              get "/lettings-logs?organisation_select=specific_org&organisation=#{org_1.id}", headers:, params: {}
              expect(page).to have_content(tenant_code_1)
              expect(page).not_to have_content(tenant_code_2)
            end
          end

          context "when the support user has filtered by organisation, then switches back to all organisations" do
            it "shows all organisations" do
              get "http://localhost:3000/lettings-logs?%5Byears%5D%5B%5D=&%5Bstatus%5D%5B%5D=&user=all&organisation_select=all&organisation=#{org_1.id}", headers:, params: {}
              expect(page).to have_content(tenant_code_1)
              expect(page).to have_content(tenant_code_2)
            end
          end
        end

        context "when there are more than 20 logs" do
          before do
            FactoryBot.create_list(:lettings_log, 25, owning_organisation: organisation, managing_organisation: organisation)
          end

          context "when on the first page" do
            before do
              get "/lettings-logs", headers:, params: {}
            end

            it "has pagination links" do
              expect(page).not_to have_content("Previous")
              expect(page).not_to have_link("Previous")
              expect(page).to have_content("Next")
              expect(page).to have_link("Next")
            end

            it "shows which logs are being shown on the current page" do
              expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>26</b> logs")
            end

            it "has pagination in the title" do
              expect(page).to have_title("Logs (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            end
          end

          context "when on the second page" do
            before do
              get "/lettings-logs?page=2", headers:, params: {}
            end

            it "shows the total log count" do
              expect(CGI.unescape_html(response.body)).to match("<strong>26</strong> total logs")
            end

            it "has pagination links" do
              expect(page).to have_content("Previous")
              expect(page).to have_link("Previous")
              expect(page).not_to have_content("Next")
              expect(page).not_to have_link("Next")
            end

            it "shows which logs are being shown on the current page" do
              expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>26</b> of <b>26</b> logs")
            end

            it "has pagination in the title" do
              expect(page).to have_title("Logs (page 2 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            end
          end
        end
      end
    end

    context "when requesting a specific lettings log" do
      let(:completed_lettings_log) { FactoryBot.create(:lettings_log, :completed) }
      let(:id) { completed_lettings_log.id }

      before do
        get "/lettings-logs/#{id}", headers:
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized lettings log" do
        json_response = JSON.parse(response.body)
        expect(json_response["status"]).to eq(completed_lettings_log.status)
      end

      context "when requesting an invalid lettings log id" do
        let(:id) { (LettingsLog.order(:id).last&.id || 0) + 1 }

        it "returns 404" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when editing a lettings log" do
        let(:headers) { { "Accept" => "text/html" } }

        context "with a user that is not signed in" do
          it "does not let the user get lettings log tasklist pages they don't have access to" do
            get "/lettings-logs/#{lettings_log.id}", headers: headers, params: {}
            expect(response).to redirect_to("/account/sign-in")
          end
        end

        context "with a signed in user" do
          context "with lettings logs that are owned or managed by your organisation" do
            before do
              sign_in user
              get "/lettings-logs/#{lettings_log.id}", headers:, params: {}
            end

            it "shows the tasklist for lettings logs you have access to" do
              expect(response.body).to match("Log")
              expect(response.body).to match(lettings_log.id.to_s)
            end

            it "displays a section status for a lettings log" do
              assert_select ".govuk-tag", text: /Not started/, count: 6
              assert_select ".govuk-tag", text: /In progress/, count: 2
              assert_select ".govuk-tag", text: /Completed/, count: 0
              assert_select ".govuk-tag", text: /Cannot start yet/, count: 1
            end
          end

          context "with a lettings log with a single section complete" do
            let(:section_completed_lettings_log) do
              FactoryBot.create(
                :lettings_log,
                :conditional_section_complete,
                owning_organisation: organisation,
                managing_organisation: organisation,
              )
            end

            before do
              sign_in user
              get "/lettings-logs/#{section_completed_lettings_log.id}", headers:, params: {}
            end

            it "displays a section status for a lettings log" do
              assert_select ".govuk-tag", text: /Not started/, count: 6
              assert_select ".govuk-tag", text: /Completed/, count: 1
              assert_select ".govuk-tag", text: /Cannot start yet/, count: 1
            end
          end

          context "with lettings logs that are not owned or managed by your organisation" do
            before do
              sign_in user
              get "/lettings-logs/#{unauthorized_lettings_log.id}", headers:, params: {}
            end

            it "does not show the tasklist for lettings logs you don't have access to" do
              expect(response).to have_http_status(:not_found)
            end
          end
        end
      end
    end

    context "when accessing the check answers page" do
      let(:postcode_lettings_log) do
        FactoryBot.create(:lettings_log,
                          owning_organisation: organisation,
                          managing_organisation: organisation,
                          postcode_known: "No")
      end
      let(:id) { postcode_lettings_log.id }

      before do
        stub_request(:get, /api.postcodes.io/)
          .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\", \"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
        sign_in user
      end

      it "shows the inferred la" do
        lettings_log = FactoryBot.create(:lettings_log,
                                         owning_organisation: organisation,
                                         managing_organisation: organisation,
                                         postcode_known: 1,
                                         postcode_full: "PO5 3TE")
        id = lettings_log.id
        get "/lettings-logs/#{id}/property-information/check-answers"
        expected_inferred_answer = "<span class=\"govuk-!-font-weight-regular app-!-colour-muted\">Manchester</span>"
        expect(CGI.unescape_html(response.body)).to include(expected_inferred_answer)
      end

      it "does not show do you know the property postcode question" do
        get "/lettings-logs/#{id}/property-information/check-answers"
        expect(CGI.unescape_html(response.body)).not_to include("Do you know the property postcode?")
      end

      it "shows if the postcode is not known" do
        get "/lettings-logs/#{id}/property-information/check-answers"
        expect(CGI.unescape_html(response.body)).to include("Not known")
      end

      it "shows `you haven't answered this question` if the question wasn't answered" do
        get "/lettings-logs/#{id}/income-and-benefits/check-answers"
        expect(CGI.unescape_html(response.body)).to include("You didn’t answer this question")
      end
    end

    context "when requesting CSV download" do
      let(:headers) { { "Accept" => "text/html" } }
      let(:search_term) { "foo" }

      before do
        sign_in user
        get "/lettings-logs/csv-download?search=#{search_term}", headers:
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "shows a confirmation button" do
        expect(page).to have_button("Send email")
      end

      it "includes the search term" do
        expect(page).to have_field("search", type: "hidden", with: search_term)
      end
    end

    context "when confirming the CSV email" do
      let(:headers) { { "Accept" => "text/html" } }

      context "when a log exists" do
        before do
          sign_in user
        end

        it "confirms that the user will receive an email with the requested CSV" do
          get "/lettings-logs/csv-confirmation"
          expect(CGI.unescape_html(response.body)).to include("We're sending you an email")
        end
      end
    end
  end

  describe "PATCH" do
    let(:lettings_log) do
      FactoryBot.create(:lettings_log, :in_progress, tenancycode: "Old Value", postcode_full: "M1 1AE")
    end
    let(:params) do
      { tenancycode: "New Value" }
    end
    let(:id) { lettings_log.id }

    before do
      patch "/lettings-logs/#{id}", headers:, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the lettings log with the given fields and keeps original values where none are passed" do
      lettings_log.reload
      expect(lettings_log.tenancycode).to eq("New Value")
      expect(lettings_log.postcode_full).to eq("M1 1AE")
    end

    context "with an invalid lettings log id" do
      let(:id) { (LettingsLog.order(:id).last&.id || 0) + 1 }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an invalid lettings log params" do
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
    let(:lettings_log) do
      FactoryBot.create(:lettings_log, :in_progress, tenancycode: "Old Value", postcode_full: "SW1A 2AA")
    end
    let(:params) do
      { tenancycode: "New Value" }
    end
    let(:id) { lettings_log.id }

    before do
      put "/lettings-logs/#{id}", headers:, params: params.to_json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the lettings log with the given fields and keeps original values where none are passed" do
      lettings_log.reload
      expect(lettings_log.tenancycode).to eq("New Value")
      expect(lettings_log.postcode_full).to eq("SW1A 2AA")
    end

    context "with an invalid lettings log id" do
      let(:id) { (LettingsLog.order(:id).last&.id || 0) + 1 }

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
    let!(:lettings_log) do
      FactoryBot.create(:lettings_log, :in_progress)
    end
    let(:id) { lettings_log.id }

    context "when deleting a lettings log" do
      before do
        delete "/lettings-logs/#{id}", headers:
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "deletes the lettings log" do
        expect { LettingsLog.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "with an invalid lettings log id" do
        let(:id) { (LettingsLog.order(:id).last&.id || 0) + 1 }

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

    context "when a lettings log deletion fails" do
      before do
        allow(LettingsLog).to receive(:find_by).and_return(lettings_log)
        allow(lettings_log).to receive(:delete).and_return(false)
        delete "/lettings-logs/#{id}", headers:
      end

      it "returns an unprocessable entity 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST #email-csv" do
    let(:other_organisation) { FactoryBot.create(:organisation) }

    context "when a log exists" do
      let!(:lettings_log) do
        FactoryBot.create(
          :lettings_log,
          owning_organisation:,
          managing_organisation: owning_organisation,
          ecstat1: 1,
        )
      end

      before do
        sign_in user
        FactoryBot.create(:lettings_log)
        FactoryBot.create(:lettings_log,
                          :completed,
                          owning_organisation:,
                          managing_organisation: owning_organisation,
                          created_by: user)
      end

      it "creates an E-mail job" do
        expect {
          post "/lettings-logs/email-csv", headers:, params: {}
        }.to enqueue_job(EmailCsvJob).with(user, nil, {}, false)
      end

      it "redirects to the confirmation page" do
        post "/lettings-logs/email-csv", headers:, params: {}
        expect(response).to redirect_to(csv_confirmation_lettings_logs_path)
      end

      it "passes the search term" do
        expect {
          post "/lettings-logs/email-csv?search=#{lettings_log.id}", headers:, params: {}
        }.to enqueue_job(EmailCsvJob).with(user, lettings_log.id.to_s, {}, false)
      end

      it "passes filter parameters" do
        expect {
          post "/lettings-logs/email-csv?status[]=completed", headers:, params: {}
        }.to enqueue_job(EmailCsvJob).with(user, nil, { "status" => %w[completed] }, false)
      end

      it "passes a combination of search term and filter parameters" do
        postcode = "XX1 1TG"

        expect {
          post "/lettings-logs/email-csv?status[]=completed&search=#{postcode}", headers:, params: {}
        }.to enqueue_job(EmailCsvJob).with(user, postcode, { "status" => %w[completed] }, false)
      end
    end
  end
end
