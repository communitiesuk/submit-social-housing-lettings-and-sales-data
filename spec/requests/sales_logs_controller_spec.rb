require "rails_helper"

RSpec.describe SalesLogsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:owning_organisation) { user.organisation }
  let(:api_username) { "test_user" }
  let(:api_password) { "test_password" }
  let(:basic_credentials) do
    ActionController::HttpAuthentication::Basic
      .encode_credentials(api_username, api_password)
  end

  let(:params) do
    {
      "owning_organisation_id": owning_organisation.id,
      "created_by_id": user.id,
    }
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
    context "when API" do
      before do
        post "/sales-logs", headers:, params: params.to_json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns a serialized sales log" do
        json_response = JSON.parse(response.body)
        expect(json_response.keys).to match_array(SalesLog.new.attributes.keys)
      end

      it "creates a sales log with the values passed" do
        json_response = JSON.parse(response.body)
        expect(json_response["owning_organisation_id"]).to eq(owning_organisation.id)
        expect(json_response["created_by_id"]).to eq(user.id)
      end

      context "with a request containing invalid credentials" do
        let(:basic_credentials) do
          ActionController::HttpAuthentication::Basic.encode_credentials(api_username, "Oops")
        end

        it "returns 401" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "with a request containing invalid json parameters" do
        let(:params) do
          {
            "saledate": Date.new(1, 1, 1),
            "purchid": "1",
            "ownershipsch": 1,
            "type": 2,
            "jointpur": 1,
            "jointmore": 1,
            "beds": 2,
            "proptype": 2,
          }
        end

        before do
          post "/sales-logs", headers:, params: params.to_json
        end

        it "validates sales log parameters" do
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response["errors"]).to match_array([["beds", ["Bedsit bedroom maximum 1"]], ["proptype", ["Bedsit maximum 1 bedroom"]]])
        end
      end
    end

    context "when UI" do
      let(:user) { FactoryBot.create(:user) }
      let(:headers) { { "Accept" => "text/html" } }

      before do
        RequestHelper.stub_http_requests
        sign_in user
        post "/sales-logs", headers:
      end

      it "tracks who created the record" do
        created_id = response.location.match(/[0-9]+/)[0]
        whodunnit_actor = SalesLog.find_by(id: created_id).versions.last.actor
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
    let!(:sales_log) do
      FactoryBot.create(
        :sales_log,
        owning_organisation: organisation,
      )
    end
    let!(:unauthorized_sales_log) do
      FactoryBot.create(
        :sales_log,
        owning_organisation: other_organisation,
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

        it "does have organisation values" do
          get "/sales-logs", headers: headers, params: {}
          expect(page).to have_content("Owned by")
          expect(page).not_to have_content("Managed by")
        end

        it "shows sales logs for all organisations" do
          get "/sales-logs", headers: headers, params: {}
          expect(page).to have_content(organisation.name)
          expect(page).to have_content(other_organisation.name)
        end

        context "when there are no logs in the database" do
          before do
            SalesLog.destroy_all
          end

          it "page has correct title" do
            get "/sales-logs", headers: headers, params: {}
            expect(page).to have_title("Logs - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end
        end

        context "when filtering" do
          context "with status filter" do
            let(:organisation_2) { FactoryBot.create(:organisation) }
            let(:user_2) { FactoryBot.create(:user, organisation: organisation_2) }
            let!(:not_started_sales_log) do
              FactoryBot.create(:sales_log,
                                owning_organisation: organisation,
                                created_by: user)
            end
            let!(:completed_sales_log) do
              FactoryBot.create(:sales_log, :completed,
                                owning_organisation: organisation_2,
                                created_by: user_2)
            end

            it "shows sales logs for multiple selected statuses" do
              get "/sales-logs?status[]=not_started&status[]=completed", headers: headers, params: {}
              expect(page).to have_link(not_started_sales_log.id.to_s)
              expect(page).to have_link(completed_sales_log.id.to_s)
            end

            it "shows sales logs for one selected status" do
              get "/sales-logs?status[]=not_started", headers: headers, params: {}
              expect(page).to have_link(not_started_sales_log.id.to_s)
              expect(page).not_to have_link(completed_sales_log.id.to_s)
            end

            it "filters on organisation" do
              get "/sales-logs?organisation[]=#{organisation_2.id}", headers: headers, params: {}
              expect(page).to have_link(completed_sales_log.id.to_s)
              expect(page).not_to have_link(not_started_sales_log.id.to_s)
            end

            it "does not reset the filters" do
              get "/sales-logs?status[]=not_started", headers: headers, params: {}
              expect(page).to have_link(not_started_sales_log.id.to_s)
              expect(page).not_to have_link(completed_sales_log.id.to_s)

              get "/sales-logs", headers: headers, params: {}
              expect(page).to have_link(not_started_sales_log.id.to_s)
              expect(page).not_to have_link(completed_sales_log.id.to_s)
            end
          end

          context "with year filter" do
            let!(:sales_log_2022) do
              FactoryBot.create(:sales_log, :in_progress,
                                owning_organisation: organisation,
                                saledate: Time.zone.local(2022, 4, 1))
            end
            let!(:sales_log_2023) do
              sales_log = FactoryBot.build(:sales_log, :completed,
                                           owning_organisation: organisation,
                                           saledate: Time.zone.local(2023, 1, 1))
              sales_log.save!(validate: false)
              sales_log
            end

            it "shows sales logs for multiple selected years" do
              get "/sales-logs?years[]=2021&years[]=2022", headers: headers, params: {}
              expect(page).to have_link(sales_log_2022.id.to_s)
              expect(page).to have_link(sales_log_2023.id.to_s)
            end

            it "shows sales logs for one selected year" do
              get "/sales-logs?years[]=2022", headers: headers, params: {}
              expect(page).to have_link(sales_log_2022.id.to_s)
              expect(page).to have_link(sales_log_2023.id.to_s)
            end
          end

          context "with year and status filter" do
            before do
              Timecop.freeze(Time.zone.local(2022, 12, 1))
            end

            after do
              Timecop.unfreeze
            end

            let!(:sales_log_2022) do
              FactoryBot.create(:sales_log, :completed,
                                owning_organisation: organisation,
                                saledate: Time.zone.local(2022, 4, 1),
                                created_by: user)
            end
            let!(:sales_log_2023) do
              FactoryBot.create(:sales_log,
                                owning_organisation: organisation,
                                saledate: Time.zone.local(2023, 1, 1),
                                created_by: user)
            end

            it "shows sales logs for multiple selected statuses and years" do
              get "/sales-logs?years[]=2021&years[]=2022&status[]=in_progress&status[]=completed", headers: headers, params: {}
              expect(page).to have_link(sales_log_2022.id.to_s)
              expect(page).to have_link(sales_log_2023.id.to_s)
            end
          end
        end
      end

      context "when the user is not a customer support user" do
        before do
          sign_in user
        end

        it "does not have organisation columns" do
          get "/sales-logs", headers: headers, params: {}
          expect(page).not_to have_content("Owning organisation")
          expect(page).not_to have_content("Managing organisation")
        end

        context "when using a search query" do
          let(:logs) { FactoryBot.create_list(:sales_log, 3, :completed, owning_organisation: user.organisation, created_by: user) }
          let(:log_to_search) { FactoryBot.create(:sales_log, :completed, owning_organisation: user.organisation, created_by: user) }
          let(:log_total_count) { SalesLog.where(owning_organisation: user.organisation).count }

          it "has search results in the title" do
            get "/sales-logs?search=#{log_to_search.id}", headers: headers, params: {}
            expect(page).to have_title("Logs (1 logs matching ‘#{log_to_search.id}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end

          it "shows sales logs matching the id" do
            get "/sales-logs?search=#{log_to_search.id}", headers: headers, params: {}
            expect(page).to have_link(log_to_search.id.to_s)
            logs.each do |log|
              expect(page).not_to have_link(log.id.to_s)
            end
          end

          context "when search query doesn't match any logs" do
            it "doesn't display any logs" do
              get "/sales-logs?search=foobar", headers:, params: {}
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
              expect(page).not_to have_link(log_to_search.id.to_s)
            end
          end

          context "when search query is empty" do
            it "doesn't display any logs" do
              get "/sales-logs?search=", headers:, params: {}
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
              expect(page).not_to have_link(log_to_search.id.to_s)
            end
          end

          context "when search and filter is present" do
            let(:matching_status) { "completed" }
            let!(:log_matching_filter_and_search) { FactoryBot.create(:sales_log, :completed, owning_organisation: user.organisation, created_by: user) }
            let(:matching_id) { log_matching_filter_and_search.id }

            it "shows only logs matching both search and filters" do
              get "/sales-logs?search=#{matching_id}&status[]=#{matching_status}", headers: headers, params: {}
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
            get "/sales-logs", headers:, params: {}
          end

          it "shows a table of logs" do
            expect(CGI.unescape_html(response.body)).to match(/<article class="app-log-summary">/)
            expect(CGI.unescape_html(response.body)).to match(/logs/)
          end

          it "only shows sales logs for your organisation" do
            expected_case_row_log = "<span class=\"govuk-visually-hidden\">Log </span>#{sales_log.id}"
            unauthorized_case_row_log = "<span class=\"govuk-visually-hidden\">Log </span>#{unauthorized_sales_log.id}"
            expect(CGI.unescape_html(response.body)).to include(expected_case_row_log)
            expect(CGI.unescape_html(response.body)).not_to include(unauthorized_case_row_log)
          end

          it "shows the formatted created at date for each log" do
            formatted_date = sales_log.created_at.to_formatted_s(:govuk_date)
            expect(CGI.unescape_html(response.body)).to include(formatted_date)
          end

          it "shows the log's status" do
            expect(CGI.unescape_html(response.body)).to include(sales_log.status.humanize)
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

          it "does not show the organisation filter" do
            expect(page).not_to have_field("organisation-field")
          end
        end

        context "when there are more than 20 logs" do
          before do
            FactoryBot.create_list(:sales_log, 25, owning_organisation: organisation)
          end

          context "when on the first page" do
            before do
              get "/sales-logs", headers:, params: {}
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
              get "/sales-logs?page=2", headers:, params: {}
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

    context "when you visit the index page" do
      let(:headers) { { "Accept" => "text/html" } }
      let(:user) { FactoryBot.create(:user, :support) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "does not have a button for creating lettings logs" do
        get "/sales-logs", headers:, params: {}
        page.assert_selector(".govuk-button", text: "Create a new sales log", count: 1)
        page.assert_selector(".govuk-button", text: "Create a new lettings log", count: 0)
      end
    end
  end
end
