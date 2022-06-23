require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  let(:organisation) { user.organisation }
  let!(:unauthorised_organisation) { FactoryBot.create(:organisation) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { FactoryBot.create(:user, :data_coordinator) }
  let(:new_value) { "Test Name 35" }
  let(:params) { { id: organisation.id, organisation: { name: new_value } } }

  context "when user is not signed in" do
    describe "#show" do
      it "does not let you see organisation details from org route" do
        get "/organisations/#{organisation.id}", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you see organisation details from details route" do
        get "/organisations/#{organisation.id}/details", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you see organisation users" do
        get "/organisations/#{organisation.id}/users", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you see organisations list" do
        get "/organisations", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end

      it "does not let you see schemes list" do
        get "/organisations/#{organisation.id}/schemes", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end
  end

  context "when user is signed in" do
    describe "#schemes" do
      context "when support user" do
        let(:user) { FactoryBot.create(:user, :support) }
        let!(:schemes) { FactoryBot.create_list(:scheme, 5) }
        let!(:same_org_scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }

        before do
          allow(user).to receive(:need_two_factor_authentication?).and_return(false)
          sign_in user
          get "/organisations/#{organisation.id}/schemes", headers:, params: {}
        end

        it "has page heading" do
          expect(page).to have_content("Schemes")
        end

        it "shows a search bar" do
          expect(page).to have_field("search", type: "search")
        end

        it "has hidden accebility field with description" do
          expected_field = "<h2 class=\"govuk-visually-hidden\">Supported housing schemes</h2>"
          expect(CGI.unescape_html(response.body)).to include(expected_field)
        end

        it "shows only schemes belonging to the same organisation" do
          expect(page).to have_content(same_org_scheme.code)
          schemes.each do |scheme|
            expect(page).not_to have_content(scheme.code)
          end
        end

        context "when searching" do
          let!(:searched_scheme) { FactoryBot.create(:scheme, code: "CODE321", organisation: user.organisation) }
          let(:search_param) { "CODE321" }

          before do
            allow(user).to receive(:need_two_factor_authentication?).and_return(false)
            get "/organisations/#{organisation.id}/schemes?search=#{search_param}"
          end

          it "returns matching results" do
            expect(page).to have_content(searched_scheme.code)
            schemes.each do |scheme|
              expect(page).not_to have_content(scheme.code)
            end
          end

          it "updates the table caption" do
            expect(page).to have_content("1 scheme found matching ‘#{search_param}’")
          end

          it "has search in the title" do
            expect(page).to have_title("#{user.organisation.name} (1 scheme matching ‘#{search_param}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
          end
        end
      end

      context "when data coordinator user" do
        let(:user) { FactoryBot.create(:user, :data_coordinator) }
        let!(:schemes) { FactoryBot.create_list(:scheme, 5) }
        let!(:same_org_scheme) { FactoryBot.create(:scheme, organisation: user.organisation) }

        before do
          sign_in user
          get "/organisations/#{organisation.id}/schemes", headers:, params: {}
        end

        it "has page heading" do
          expect(page).to have_content("Schemes")
        end

        it "shows a search bar" do
          expect(page).to have_field("search", type: "search")
        end

        it "has hidden accessibility field with description" do
          expected_field = "<h2 class=\"govuk-visually-hidden\">Supported housing schemes</h2>"
          expect(CGI.unescape_html(response.body)).to include(expected_field)
        end

        it "shows only schemes belonging to the same organisation" do
          expect(page).to have_content(same_org_scheme.code)
          schemes.each do |scheme|
            expect(page).not_to have_content(scheme.code)
          end
        end

        context "with schemes that are not in scope for the user, i.e. that they do not belong to" do
          let!(:unauthorised_organisation) { FactoryBot.create(:organisation) }

          before do
            get "/organisations/#{unauthorised_organisation.id}/schemes", headers:, params: {}
          end

          it "returns not found 404 from org details route" do
            expect(response).to have_http_status(:not_found)
          end
        end

        context "when searching" do
          let!(:searched_scheme) { FactoryBot.create(:scheme, code: "CODE321", organisation: user.organisation) }
          let(:search_param) { "CODE321" }

          before do
            get "/organisations/#{organisation.id}/schemes?search=#{search_param}"
          end

          it "returns matching results" do
            expect(page).to have_content(searched_scheme.code)
            schemes.each do |scheme|
              expect(page).not_to have_content(scheme.code)
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
      context "with an organisation that the user belongs to" do
        before do
          sign_in user
          get "/organisations/#{organisation.id}", headers:, params: {}
        end

        it "redirects to details" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
        before do
          sign_in user
          get "/organisations/#{unauthorised_organisation.id}", headers:, params: {}
        end

        it "returns not found 404 from org route" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end
    end

    context "with a data coordinator user" do
      before do
        sign_in user
      end

      context "when we access the details tab" do
        context "with an organisation that the user belongs to" do
          before do
            get "/organisations/#{organisation.id}/details", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows a summary list of org details" do
            expected_html = "<dl class=\"govuk-summary-list\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(organisation.name)
          end

          it "has a change details link" do
            expected_html = "data-qa=\"change-name\" href=\"/organisations/#{organisation.id}/edit\""
            expect(response.body).to include(expected_html)
          end
        end

        context "with organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/details", headers:, params: {}
          end

          it "returns not found 404 from org details route" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when accessing the users tab" do
        context "with an organisation that the user belongs to" do
          let!(:other_user) { FactoryBot.create(:user, organisation: user.organisation, name: "User 2") }
          let!(:inactive_user) { FactoryBot.create(:user, organisation: user.organisation, active: false, name: "User 3") }
          let!(:other_org_user) { FactoryBot.create(:user, name: "User 4") }

          before do
            get "/organisations/#{organisation.id}/users", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows a new user button" do
            expect(page).to have_link("Invite user")
          end

          it "shows a table of users" do
            expected_html = "<table class=\"govuk-table\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(user.email)
          end

          it "shows hidden accesibility fields only for active users in the current user's organisation" do
            expected_case_row_log = "<span class=\"govuk-visually-hidden\">User </span><span class=\"govuk-!-font-weight-regular app-!-colour-muted\">#{user.email}</span>"
            unauthorized_case_row_log = "<span class=\"govuk-visually-hidden\">User </span><span class=\"govuk-!-font-weight-regular app-!-colour-muted\">#{other_org_user.email}</span>"
            expect(CGI.unescape_html(response.body)).to include(expected_case_row_log)
            expect(CGI.unescape_html(response.body)).not_to include(unauthorized_case_row_log)
          end

          it "shows only active users in the current user's organisation" do
            expect(page).to have_content(user.name)
            expect(page).to have_content(other_user.name)
            expect(page).to have_content(inactive_user.name)
            expect(page).not_to have_content(other_org_user.name)
          end

          it "shows the pagination count" do
            expect(page).to have_content("3 total users")
          end
        end

        context "with an organisation that are not in scope for the user, i.e. that they do not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/users", headers:, params: {}
          end

          it "returns not found 404 from users page" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "#edit" do
        context "with an organisation that the user belongs to" do
          before do
            get "/organisations/#{organisation.id}/edit", headers:, params: {}
          end

          it "shows an edit form" do
            expect(response.body).to include("Change #{organisation.name}’s details")
            expect(page).to have_field("organisation-name-field")
            expect(page).to have_field("organisation-phone-field")
          end
        end

        context "with an organisation that the user does not belong to" do
          before do
            get "/organisations/#{unauthorised_organisation.id}/edit", headers:, params: {}
          end

          it "returns a 404 not found" do
            expect(response).to have_http_status(:not_found)
          end

          it "shows the 404 view" do
            expect(page).to have_content("Page not found")
          end
        end
      end

      describe "#update" do
        context "with an organisation that the user belongs to" do
          before do
            patch "/organisations/#{organisation.id}", headers:, params:
          end

          it "updates the org" do
            organisation.reload
            expect(organisation.name).to eq(new_value)
          end

          it "redirects to the organisation details page" do
            expect(response).to redirect_to("/organisations/#{organisation.id}/details")
          end

          it "shows a success banner" do
            follow_redirect!
            expect(page).to have_css(".govuk-notification-banner.govuk-notification-banner--success")
          end

          it "tracks who updated the record" do
            organisation.reload
            whodunnit_actor = organisation.versions.last.actor
            expect(whodunnit_actor).to be_a(User)
            expect(whodunnit_actor.id).to eq(user.id)
          end
        end

        context "with an organisation that the user does not belong to" do
          before do
            patch "/organisations/#{unauthorised_organisation.id}", headers:, params: {}
          end

          it "returns a 404 not found" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when viewing logs for other organisation" do
        before do
          get "/organisations/#{unauthorised_organisation.id}/logs", headers:, params: {}
        end

        it "returns not found 404 from org details route" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end

      context "when viewing logs for your organisation" do
        before do
          get "/organisations/#{organisation.id}/logs", headers:, params: {}
        end

        it "redirects to /logs page" do
          expect(response).to redirect_to("/logs")
        end
      end

      describe "#index" do
        before do
          get "/organisations", headers:, params:
        end

        it "redirects to the user's organisation" do
          expect(response).to redirect_to("/organisations/#{user.organisation.id}")
        end
      end

      describe "#new" do
        let(:request) { get "/organisations/new", headers:, params: }

        it "returns 401 unauthorized" do
          request
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "#create" do
        let(:params) do
          {
            "organisation": {
              name: "new organisation",
              address_line1: "12 Random Street",
              address_line2: "Manchester",
              postcode: "MD1 5TR",
              phone: "011101101",
              provider_type: "LA",
              holds_own_stock: "true",
              housing_registration_no: "7917937",
            },
          }
        end
        let(:request) { post "/organisations", headers:, params: }

        it "returns 401 unauthorized" do
          request
          expect(response).to have_http_status(:unauthorized)
        end

        it "does not create an organisation" do
          expect { request }.not_to change(Organisation, :count)
        end
      end
    end

    context "with a data provider user" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
      end

      context "when accessing the details tab" do
        context "with an organisation that the user belongs to" do
          before do
            get "/organisations/#{organisation.id}/details", headers:, params: {}
          end

          it "shows the tab navigation" do
            expected_html = "<nav class=\"app-primary-navigation\""
            expect(response.body).to include(expected_html)
          end

          it "shows a summary list of org details" do
            expected_html = "<dl class=\"govuk-summary-list\""
            expect(response.body).to include(expected_html)
            expect(response.body).to include(organisation.name)
          end

          it "does not have a change details link" do
            expected_html = "data-qa=\"change-name\" href=\"/organisations/#{organisation.id}/edit\""
            expect(response.body).not_to include(expected_html)
          end
        end

        context "with an organisation that is not in scope for the user, i.e. that they do not belong to" do
          before do
            sign_in user
            get "/organisations/#{unauthorised_organisation.id}/details", headers:, params: {}
          end

          it "returns not found 404" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when accessing the users tab" do
        before do
          get "/organisations/#{organisation.id}/users", headers:, params: {}
        end

        it "returns 200" do
          expect(response).to have_http_status(:ok)
        end
      end

      describe "#edit" do
        before do
          get "/organisations/#{organisation.id}/edit", headers:, params: {}
        end

        it "redirects to home" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "#update" do
        before do
          patch "/organisations/#{organisation.id}", headers:, params:
        end

        it "redirects to home" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when viewing logs for other organisation" do
        before do
          get "/organisations/#{unauthorised_organisation.id}/logs", headers:, params: {}
        end

        it "returns not found 404 from org details route" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end

      context "when viewing logs for your organisation" do
        before do
          get "/organisations/#{organisation.id}/logs", headers:, params: {}
        end

        it "redirects to /logs page" do
          expect(response).to redirect_to("/logs")
        end
      end
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support) }

      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      describe "#new" do
        let(:request) { get "/organisations/new", headers:, params: }

        it "shows the create organisation form" do
          request
          expect(page).to have_field("organisation[name]")
          expect(page).to have_field("organisation[phone]")
          expect(page).to have_field("organisation[provider_type]")
          expect(page).to have_field("organisation[address_line1]")
          expect(page).to have_field("organisation[address_line2]")
          expect(page).to have_field("organisation[postcode]")
          expect(page).to have_field("organisation[holds_own_stock]")
        end
      end

      describe "#index" do
        before do
          get "/organisations", headers:, params: {}
        end

        it "shows the organisation list" do
          expect(page).to have_content("Organisations")
        end

        it "has a create new organisation button" do
          expect(page).to have_link("Create a new organisation", href: "/organisations/new")
        end

        it "shows all organisations" do
          total_number_of_orgs = Organisation.all.count
          expect(page).to have_link organisation.name, href: "organisations/#{organisation.id}/logs"
          expect(page).to have_link unauthorised_organisation.name, href: "organisations/#{unauthorised_organisation.id}/logs"
          expect(page).to have_content("#{total_number_of_orgs} total organisations")
        end

        it "shows a search bar" do
          expect(page).to have_field("search", type: "search")
        end

        context "when viewing a specific organisation's logs" do
          let(:number_of_org1_case_logs) { 2 }
          let(:number_of_org2_case_logs) { 4 }

          before do
            FactoryBot.create_list(:case_log, number_of_org1_case_logs, owning_organisation_id: organisation.id, managing_organisation_id: organisation.id)
            FactoryBot.create_list(:case_log, number_of_org2_case_logs, owning_organisation_id: unauthorised_organisation.id, managing_organisation_id: unauthorised_organisation.id)

            get "/organisations/#{organisation.id}/logs", headers:, params: {}
          end

          it "only shows logs for that organisation" do
            expect(page).to have_content("#{number_of_org1_case_logs} total logs")
            organisation.case_logs.map(&:id).each do |case_log_id|
              expect(page).to have_link case_log_id.to_s, href: "/logs/#{case_log_id}"
            end

            unauthorised_organisation.case_logs.map(&:id).each do |case_log_id|
              expect(page).not_to have_link case_log_id.to_s, href: "/logs/#{case_log_id}"
            end
          end

          it "has filters" do
            expect(page).to have_content("Filters")
            expect(page).to have_content("Collection year")
          end

          it "does not have specific organisation filter" do
            expect(page).not_to have_content("Specific organisation")
          end

          it "has a sub-navigation with correct tabs" do
            expect(page).to have_css(".app-sub-navigation")
            expect(page).to have_content("About this organisation")
          end

          context "when using a search query" do
            let(:logs) { FactoryBot.create_list(:case_log, 3, :completed, owning_organisation: user.organisation, created_by: user) }
            let(:log_to_search) { FactoryBot.create(:case_log, :completed, owning_organisation: user.organisation, created_by: user) }
            let(:log_total_count) { CaseLog.where(owning_organisation: user.organisation).count }

            it "has search results in the title" do
              get "/organisations/#{organisation.id}/logs?search=#{log_to_search.id}", headers: headers, params: {}
              expect(page).to have_title("#{organisation.name} (1 log matching ‘#{log_to_search.id}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            end

            it "shows case logs matching the id" do
              get "/organisations/#{organisation.id}/logs?search=#{log_to_search.id}", headers: headers, params: {}
              expect(page).to have_link(log_to_search.id.to_s)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end

            it "shows case logs matching the tenant code" do
              get "/organisations/#{organisation.id}/logs?search=#{log_to_search.tenancycode}", headers: headers, params: {}
              expect(page).to have_link(log_to_search.id.to_s)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end

            it "shows case logs matching the property reference" do
              get "/organisations/#{organisation.id}/logs?search=#{log_to_search.propcode}", headers: headers, params: {}
              expect(page).to have_link(log_to_search.id.to_s)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end

            it "shows case logs matching the property postcode" do
              get "/organisations/#{organisation.id}/logs?search=#{log_to_search.postcode_full}", headers: headers, params: {}
              expect(page).to have_link(log_to_search.id.to_s)
              logs.each do |log|
                expect(page).not_to have_link(log.id.to_s)
              end
            end

            context "when more than one results with matching postcode" do
              let!(:matching_postcode_log) { FactoryBot.create(:case_log, :completed, owning_organisation: user.organisation, postcode_full: log_to_search.postcode_full) }

              it "displays all matching logs" do
                get "/organisations/#{organisation.id}/logs?search=#{log_to_search.postcode_full}", headers: headers, params: {}
                expect(page).to have_link(log_to_search.id.to_s)
                expect(page).to have_link(matching_postcode_log.id.to_s)
                logs.each do |log|
                  expect(page).not_to have_link(log.id.to_s)
                end
              end
            end

            context "when there are more than 1 page of search results" do
              let(:postcode) { "XX11YY" }
              let(:logs) { FactoryBot.create_list(:case_log, 30, :completed, owning_organisation: user.organisation, postcode_full: postcode) }
              let(:log_total_count) { CaseLog.where(owning_organisation: user.organisation).count }

              it "has title with pagination details for page 1" do
                get "/organisations/#{organisation.id}/logs?search=#{logs[0].postcode_full}", headers: headers, params: {}
                expect(page).to have_title("#{organisation.name} (#{logs.count} logs matching ‘#{postcode}’) (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
              end

              it "has title with pagination details for page 2" do
                get "/organisations/#{organisation.id}/logs?search=#{logs[0].postcode_full}&page=2", headers: headers, params: {}
                expect(page).to have_title("#{organisation.name} (#{logs.count} logs matching ‘#{postcode}’) (page 2 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
              end
            end

            context "when search query doesn't match any logs" do
              it "doesn't display any logs" do
                get "/organisations/#{organisation.id}/logs?search=foobar", headers:, params: {}
                logs.each do |log|
                  expect(page).not_to have_link(log.id.to_s)
                end
                expect(page).not_to have_link(log_to_search.id.to_s)
              end
            end

            context "when search query is empty" do
              it "doesn't display any logs" do
                get "/organisations/#{organisation.id}/logs?search=", headers:, params: {}
                logs.each do |log|
                  expect(page).not_to have_link(log.id.to_s)
                end
                expect(page).not_to have_link(log_to_search.id.to_s)
              end
            end

            context "when search and filter is present" do
              let(:matching_postcode) { log_to_search.postcode_full }
              let(:matching_status) { "in_progress" }
              let!(:log_matching_filter_and_search) { FactoryBot.create(:case_log, :in_progress, owning_organisation: user.organisation, postcode_full: matching_postcode, created_by: user) }

              it "shows only logs matching both search and filters" do
                get "/organisations/#{organisation.id}/logs?search=#{matching_postcode}&status[]=#{matching_status}", headers: headers, params: {}
                expect(page).to have_link(log_matching_filter_and_search.id.to_s)
                expect(page).not_to have_link(log_to_search.id.to_s)
                logs.each do |log|
                  expect(page).not_to have_link(log.id.to_s)
                end
              end
            end
          end
        end

        context "when viewing a specific organisation's users" do
          let!(:users) { FactoryBot.create_list(:user, 5, organisation:) }
          let!(:different_org_users) { FactoryBot.create_list(:user, 5) }

          before do
            get "/organisations/#{organisation.id}/users", headers:, params: {}
          end

          it "displays the name of the organisation" do
            expect(page).to have_content(organisation.name)
          end

          it "has a sub-navigation with correct tabs" do
            expect(page).to have_css(".app-sub-navigation")
            expect(page).to have_content("Users")
          end

          it "displays users for this organisation" do
            expect(page).to have_content(user.email)
            users.each do |user|
              expect(page).to have_content(user.email)
            end
          end

          it "doesn't display users for other organisations" do
            different_org_users.each do |different_org_user|
              expect(page).not_to have_content(different_org_user.email)
            end
          end

          context "when a search parameter is passed" do
            let!(:matching_user) { FactoryBot.create(:user, organisation:, name: "joe", email: "matching@example.com") }
            let(:org_user_count) { User.where(organisation:).count }

            before do
              get "/organisations/#{user.organisation.id}/users?search=#{search_param}"
            end

            context "when our search string matches case" do
              let(:search_param) { "joe" }

              it "returns only matching results" do
                expect(page).to have_content(matching_user.name)
                expect(page).not_to have_link(user.name)

                different_org_users.each do |different_org_user|
                  expect(page).not_to have_content(different_org_user.email)
                end

                users.each do |org_user|
                  expect(page).not_to have_content(org_user.email)
                end
              end

              it "updates the table caption" do
                expect(page).to have_content("1 user found matching ‘#{search_param}’ of #{org_user_count} total users.")
              end

              context "when we need case insensitive search" do
                let(:search_param) { "Joe" }

                it "returns only matching results" do
                  expect(page).to have_content(matching_user.name)
                  expect(page).not_to have_link(user.name)

                  different_org_users.each do |different_org_user|
                    expect(page).not_to have_content(different_org_user.email)
                  end

                  users.each do |org_user|
                    expect(page).not_to have_content(org_user.email)
                  end
                end

                it "updates the table caption" do
                  expect(page).to have_content("1 user found matching ‘#{search_param}’ of #{org_user_count} total users.")
                end
              end
            end

            context "when our search term matches an email" do
              let(:search_param) { "matching@example.com" }

              it "returns only matching results" do
                expect(page).to have_content(matching_user.name)
                expect(page).not_to have_link(user.name)

                different_org_users.each do |different_org_user|
                  expect(page).not_to have_content(different_org_user.email)
                end

                users.each do |org_user|
                  expect(page).not_to have_content(org_user.email)
                end
              end

              it "updates the table caption" do
                expect(page).to have_content("1 user found matching ‘#{search_param}’ of #{org_user_count} total users.")
              end

              context "when our search term matches an email and a name" do
                let!(:matching_user) { FactoryBot.create(:user, organisation:, name: "Foobar", email: "some@example.com") }
                let!(:another_matching_user) { FactoryBot.create(:user, organisation:, name: "Joe", email: "foobar@example.com") }
                let!(:org_user_count) { User.where(organisation:).count }
                let(:search_param) { "Foobar" }

                before do
                  get "/organisations/#{user.organisation.id}/users?search=#{search_param}"
                end

                it "returns only matching results" do
                  expect(page).to have_link(matching_user.name)
                  expect(page).to have_link(another_matching_user.name)
                  expect(page).not_to have_link(user.name)

                  different_org_users.each do |different_org_user|
                    expect(page).not_to have_content(different_org_user.email)
                  end

                  users.each do |org_user|
                    expect(page).not_to have_content(org_user.email)
                  end
                end

                it "updates the table caption" do
                  expect(page).to have_content("2 users found matching ‘#{search_param}’ of #{org_user_count} total users.")
                end
              end
            end
          end
        end

        context "when viewing a specific organisation's details" do
          before do
            get "/organisations/#{organisation.id}/details", headers:, params: {}
          end

          it "displays the name of the organisation" do
            expect(page).to have_content(organisation.name)
          end

          it "has a sub-navigation with correct tabs" do
            expect(page).to have_css(".app-sub-navigation")
            expect(page).to have_content("About this organisation")
          end

          it "allows to edit the organisation details" do
            expect(page).to have_link("Change", count: 3)
          end
        end

        context "when there are more than 20 organisations" do
          let(:total_organisations_count) { Organisation.all.count }

          before do
            FactoryBot.create_list(:organisation, 25)
            get "/organisations"
          end

          context "when on the first page" do
            it "has pagination links" do
              expect(page).to have_content("Previous")
              expect(page).not_to have_link("Previous")
              expect(page).to have_content("Next")
              expect(page).to have_link("Next")
            end

            it "shows which organisations are being shown on the current page" do
              expect(CGI.unescape_html(response.body)).to match("Showing <b>1</b> to <b>20</b> of <b>#{total_organisations_count}</b> organisations")
            end

            it "has pagination in the title" do
              expect(page).to have_title("Organisations (page 1 of 2)")
            end
          end

          context "when on the second page" do
            before do
              get "/organisations?page=2", headers:, params: {}
            end

            it "shows the total organisations count" do
              expect(CGI.unescape_html(response.body)).to match("<strong>#{total_organisations_count}</strong> total organisations.")
            end

            it "has pagination links" do
              expect(page).to have_content("Previous")
              expect(page).to have_link("Previous")
              expect(page).to have_content("Next")
              expect(page).not_to have_link("Next")
            end

            it "shows which logs are being shown on the current page" do
              expect(CGI.unescape_html(response.body)).to match("Showing <b>21</b> to <b>#{total_organisations_count}</b> of <b>#{total_organisations_count}</b> organisations")
            end

            it "has pagination in the title" do
              expect(page).to have_title("Organisations (page 2 of 2)")
            end
          end

          context "when searching" do
            let!(:searched_organisation) { FactoryBot.create(:organisation, name: "Unusual name") }
            let!(:other_organisation) { FactoryBot.create(:organisation, name: "Some other name") }
            let(:search_param) { "Unusual" }

            before do
              get "/organisations?search=#{search_param}"
            end

            it "returns matching results" do
              expect(page).to have_content(searched_organisation.name)
              expect(page).not_to have_content(other_organisation.name)
            end

            it "updates the table caption" do
              expect(page).to have_content("1 organisation found matching ‘#{search_param}’")
            end

            it "has search in the title" do
              expect(page).to have_title("Organisations (1 organisation matching ‘#{search_param}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
            end

            context "when the search term matches more than 1 result" do
              let(:search_param) { "name" }

              it "returns matching results" do
                expect(page).to have_content(searched_organisation.name)
                expect(page).to have_content(other_organisation.name)
              end

              it "updates the table caption" do
                expect(page).to have_content("2 organisations found matching ‘#{search_param}’")
              end

              it "has search in the title" do
                expect(page).to have_title("Organisations (2 organisations matching ‘#{search_param}’) - Submit social housing lettings and sales data (CORE) - GOV.UK")
              end
            end

            context "when search results require pagination" do
              let(:search_param) { "DLUHC" }

              it "has search and pagination in the title" do
                expect(page).to have_title("Organisations (27 organisations matching ‘#{search_param}’) (page 1 of 2) - Submit social housing lettings and sales data (CORE) - GOV.UK")
              end
            end
          end
        end
      end

      describe "#create" do
        let(:name) { "Unique new org name" }
        let(:address_line1) { "12 Random Street" }
        let(:address_line2) { "Manchester" }
        let(:postcode) { "MD1 5TR" }
        let(:phone) { "011101101" }
        let(:provider_type) { "LA" }
        let(:holds_own_stock) { "true" }
        let(:housing_registration_no) { "7917937" }
        let(:params) do
          {
            "organisation": {
              name:,
              address_line1:,
              address_line2:,
              postcode:,
              phone:,
              provider_type:,
              holds_own_stock:,
              housing_registration_no:,
            },
          }
        end
        let(:request) { post "/organisations", headers:, params: }

        it "creates a new organisation" do
          expect { request }.to change(Organisation, :count).by(1)
        end

        it "sets the organisation attributes correctly" do
          request
          organisation = Organisation.find_by(housing_registration_no:)
          expect(organisation.name).to eq(name)
          expect(organisation.address_line1).to eq(address_line1)
          expect(organisation.address_line2).to eq(address_line2)
          expect(organisation.postcode).to eq(postcode)
          expect(organisation.phone).to eq(phone)
          expect(organisation.holds_own_stock).to be true
        end

        it "redirects to the organisation list" do
          request
          expect(response).to redirect_to("/organisations")
        end

        context "when required params are missing" do
          let(:name) { "" }
          let(:provider_type) { "" }

          it "displays the form with an error message" do
            request
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_content(I18n.t("validations.organisation.name_missing"))
            expect(page).to have_content(I18n.t("validations.organisation.provider_type_missing"))
          end
        end
      end
    end
  end
end
