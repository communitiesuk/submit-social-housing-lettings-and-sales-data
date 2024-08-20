require "rails_helper"

RSpec.describe UsersController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:new_name) { "new test name" }
  let(:new_email) { "new@example.com" }
  let(:params) { { id: user.id, user: { name: new_name } } }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  context "when user is not signed in" do
    describe "#show" do
      it "does not let you see user details" do
        get "/users/#{user.id}", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#edit" do
      it "does not let you edit user details" do
        get "/users/#{user.id}/edit", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#password" do
      it "does not let you edit user passwords" do
        get "/account/edit/password", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#patch" do
      it "does not let you update user details" do
        patch "/lettings-logs/#{user.id}", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "change password" do
      context "when updating a user password" do
        let(:params) do
          {
            id: user.id, user: { password: new_name, password_confirmation: "something_else" }
          }
        end

        before do
          sign_in user
          put "/account", headers:, params:
        end

        it "renders the user change password view" do
          expect(page).to have_css("h1", class: "govuk-heading-l", text: "Change your password")
        end

        it "shows an error on the same page if passwords don't match" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_css("h1", class: "govuk-heading-l", text: "Change your password")
          expect(page).to have_selector(".govuk-error-summary__title")
          expect(page).to have_content("passwords you entered do not match")
        end
      end
    end

    describe "title link" do
      it "routes user to the home page" do
        sign_in user
        get "/", headers:, params: {}
        expect(path).to eq("/")
        expect(page).to have_content("Welcome back")
        expected_link = "<a class=\"govuk-header__link govuk-header__link--homepage\" href=\"/\">"
        expect(CGI.unescape_html(response.body)).to include(expected_link)
      end
    end

    describe "#deactivate" do
      it "does not let you see deactivate page" do
        get "/users/#{user.id}/deactivate", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#reactivate" do
      it "does not let you see reactivate page" do
        get "/users/#{user.id}/reactivate", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#resend_invite" do
      it "does not allow resending activation emails" do
        get deactivate_user_path(user.id), headers: headers, params: {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#delete-confirmation" do
      it "redirects to the sign in page" do
        get "/users/#{user.id}/delete-confirmation"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#delete" do
      it "redirects to the sign in page" do
        delete "/users/#{user.id}/delete"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#search" do
      it "redirects to the sign in page" do
        get "/users/search"
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#log_reassignment" do
      it "redirects to the sign in page" do
        get "/users/#{user.id}/log-reassignment"
        expect(response).to redirect_to("/account/sign-in")
      end
    end
  end

  context "when user is signed in as a data provider" do
    before do
      sign_in user
    end

    describe "#show" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}", headers:, params: {}
        end

        it "show the user details" do
          expect(page).to have_content("Your account")
        end

        it "allows changing name, email and password" do
          expect(page).to have_link("Change", text: "name")
          expect(page).to have_link("Change", text: "email address")
          expect(page).to have_link("Change", text: "telephone number")
          expect(page).to have_link("Change", text: "password")
          expect(page).not_to have_link("Change", text: "role")
          expect(page).not_to have_link("Change", text: "if data protection officer")
          expect(page).not_to have_link("Change", text: "if a key contact")
          expect(page).not_to have_link("Change", text: "organisation")
        end

        it "does not allow deactivating the user" do
          expect(page).not_to have_link("Deactivate user", href: "/users/#{user.id}/deactivate")
        end

        it "does not allow resending invitation emails" do
          expect(page).not_to have_button("Resend invite link")
        end

        context "when user is deactivated" do
          before do
            user.update!(active: false)
            get "/users/#{user.id}", headers:, params: {}
          end

          it "does not allow reactivating the user" do
            expect(page).not_to have_link("Reactivate user", href: "/users/#{user.id}/reactivate")
          end

          it "does not allow resending invitation emails" do
            expect(page).not_to have_link("Resend invite link")
          end
        end
      end

      context "when the user does not have a role because they are a data protection officer only" do
        let(:user) { create(:user, role: nil) }

        before do
          get "/users/#{user.id}", headers:, params: {}
        end

        it "shows their details" do
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}", headers:, params: {}
        end

        context "when the user is part of the same organisation" do
          let(:other_user) { create(:user, organisation: user.organisation) }

          it "shows their details" do
            expect(response).to have_http_status(:ok)
            expect(page).to have_content("#{other_user.name}’s account")
          end

          it "does not have edit links" do
            expect(page).not_to have_link("Change", text: "name")
            expect(page).not_to have_link("Change", text: "email address")
            expect(page).not_to have_link("Change", text: "telephone number")
            expect(page).not_to have_link("Change", text: "password")
            expect(page).not_to have_link("Change", text: "role")
            expect(page).not_to have_link("Change", text: "if data protection officer")
            expect(page).not_to have_link("Change", text: "if a key contact")
            expect(page).not_to have_link("Change", text: "organisation")
          end

          it "does not allow deactivating the user" do
            expect(page).not_to have_link("Deactivate user", href: "/users/#{other_user.id}/deactivate")
          end

          context "when user is deactivated" do
            before do
              other_user.update!(active: false)
              get "/users/#{other_user.id}", headers:, params: {}
            end

            it "does not allow reactivating the user" do
              expect(page).not_to have_link("Reactivate user", href: "/users/#{other_user.id}/reactivate")
            end

            it "does not allow resending invitation emails" do
              expect(page).not_to have_button("Resend invite link")
            end
          end
        end

        context "when the user is not part of the same organisation" do
          it "returns not found 404" do
            expect(response).to have_http_status(:not_found)
          end

          it "shows the 404 view" do
            expect(page).to have_content("Page not found")
          end
        end
      end
    end

    describe "#edit" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}/edit", headers:, params: {}
        end

        it "show the edit personal details page" do
          expect(page).to have_content("Change your personal details")
        end

        it "has fields for name and email" do
          expect(page).to have_field("user[name]")
          expect(page).to have_field("user[email]")
          expect(page).not_to have_field("user[role]")
          expect(page).not_to have_field("user[is_dpo]")
          expect(page).not_to have_field("user[is_key_contact]")
          expect(page).not_to have_field("user[organisation_id]")
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}/edit", headers:, params: {}
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#edit_password" do
      context "when the current user matches the user ID" do
        before do
          get "/account/edit/password", headers:, params: {}
        end

        it "shows the edit password page" do
          expect(page).to have_content("Change your password")
        end

        it "shows the password requirements hint" do
          expect(page).to have_css("#user-password-hint")
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}/edit", headers:, params: {}
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#update" do
      context "when the current user matches the user ID" do
        before do
          patch "/users/#{user.id}", headers:, params:
        end

        it "updates the user" do
          user.reload
          expect(user.name).to eq(new_name)
        end

        it "tracks who updated the record" do
          user.reload
          whodunnit_actor = user.versions.last.actor
          expect(whodunnit_actor).to be_a(User)
          expect(whodunnit_actor.id).to eq(user.id)
        end

        context "when user changes email, dpo, key_contact" do
          let(:params) { { id: user.id, user: { name: new_name, email: new_email, is_dpo: "true", is_key_contact: "true" } } }

          it "allows changing email but not dpo or key_contact" do
            user.reload
            expect(user.unconfirmed_email).to eq(new_email)
            expect(user.is_data_protection_officer?).to be false
            expect(user.is_key_contact?).to be false
          end
        end
      end

      context "when the update fails to persist" do
        before do
          allow(User).to receive(:find_by).and_return(user)
          allow(user).to receive(:update).and_return(false)
          patch "/users/#{user.id}", headers:, params:
        end

        it "show an error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when the current user does not match the user ID" do
        let(:params) { { id: other_user.id, user: { name: new_name } } }

        before do
          patch "/users/#{other_user.id}", headers:, params:
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when we update the user password" do
        let(:params) do
          {
            id: user.id, user: { password: new_name, password_confirmation: "something_else" }
          }
        end

        before do
          patch "/users/#{user.id}", headers:, params:
        end

        it "shows an error if passwords don't match" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_selector(".govuk-error-summary__title")
        end
      end
    end

    describe "#create" do
      let(:params) do
        {
          "user": {
            name: "new user",
            email: "new_user@example.com",
            role: "data_coordinator",
          },
        }
      end
      let(:request) { post "/users/", headers:, params: }

      it "does not invite a new user" do
        expect { request }.not_to change(User, :count)
      end

      it "returns 401 unauthorized" do
        request
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#delete-confirmation" do
      before do
        get "/users/#{user.id}/delete-confirmation"
      end

      it "returns 401 unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#delete" do
      before do
        delete "/users/#{user.id}/delete"
      end

      it "returns 401 unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#search" do
      let(:parent_relationship) { create(:organisation_relationship, parent_organisation: user.organisation) }
      let(:child_relationship) { create(:organisation_relationship, child_organisation: user.organisation) }
      let!(:org_user) { create(:user, organisation: user.organisation, name: "test_name") }
      let!(:managing_user) { create(:user, organisation: parent_relationship.child_organisation, name: "managing_agent_test_name") }

      before do
        create(:user, organisation: child_relationship.parent_organisation, name: "stock_owner_test_name")
        create(:user, name: "other_organisation_test_name")
      end

      it "only searches within the current user's organisation and managing agents" do
        get "/users/search", headers:, params: { query: "test_name" }
        result = JSON.parse(response.body)
        expect(result.count).to eq(2)
        expect(result.keys).to match_array([org_user.id.to_s, managing_user.id.to_s])
      end
    end

    describe "#log_reassignment" do
      it "returns unauthorized status" do
        get "/users/#{user.id}/log-reassignment"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context "when user is signed in as a data coordinator" do
    let(:user) { create(:user, :data_coordinator, email: "coordinator@example.com", organisation: create(:organisation, :without_dpc)) }
    let!(:other_user) { create(:user, organisation: user.organisation, name: "filter name", email: "filter@example.com", unconfirmed_email: "email@something.com") }

    before do
      sign_in user
    end

    describe "#index" do
      context "when there are no url params" do
        before do
          get "/users", headers:, params: {}
        end

        it "redirects to the organisation user path" do
          follow_redirect!
          expect(path).to match("/organisations/#{user.organisation.id}/users")
        end

        it "does not show the download csv link" do
          expect(page).not_to have_link("Download (CSV)", href: "/users.csv")
        end

        it "shows a search bar" do
          follow_redirect!
          expect(page).to have_field("search", type: "search")
        end
      end

      context "when a search parameter is passed" do
        let!(:other_user_2) { create(:user, organisation: user.organisation, name: "joe", email: "other@example.com") }
        let!(:other_user_3) { create(:user, name: "User 5", organisation: user.organisation, email: "joe@example.com") }
        let!(:other_org_user) { create(:user, name: "User 4", email: "joe@otherexample.com") }

        before do
          get "/organisations/#{user.organisation.id}/users?search=#{search_param}"
        end

        context "when our search string matches case" do
          let(:search_param) { "filter" }

          it "returns only matching results" do
            expect(page).not_to have_content(user.name)
            expect(page).to have_content(other_user.name)
          end

          it "updates the table caption" do
            expect(page).to have_content("1 user matching search")
          end
        end

        context "when we need case insensitive search" do
          let(:search_param) { "Filter" }

          it "returns only matching results" do
            expect(page).not_to have_content(user.name)
            expect(page).to have_content(other_user.name)
          end
        end

        context "when our search term matches an email" do
          let(:search_param) { "other@example.com" }

          it "returns only matching result within the same organisation" do
            expect(page).not_to have_content(user.name)
            expect(page).to have_content(other_user_2.name)
            expect(page).not_to have_content(other_user.name)
            expect(page).not_to have_content(other_user_3.name)
            expect(page).not_to have_content(other_org_user.name)
          end

          context "when our search term matches an email and a name" do
            let(:search_param) { "joe" }

            it "returns any results including joe within the same organisation" do
              expect(page).to have_content(other_user_2.name)
              expect(page).to have_content(other_user_3.name)
              expect(page).not_to have_content(other_user.name)
              expect(page).not_to have_content(other_org_user.name)
              expect(page).not_to have_content(user.name)
            end

            it "updates the table caption" do
              expect(page).to have_content("2 users matching search")
            end
          end
        end
      end

      context "when filtering" do
        context "with status filter" do
          let!(:active_user) { create(:user, name: "active name", active: true, organisation: user.organisation, last_sign_in_at: Time.zone.now) }
          let!(:deactivated_user) { create(:user, active: false, name: "deactivated name", organisation: user.organisation, last_sign_in_at: Time.zone.now) }
          let!(:unconfirmed_user) { create(:user, last_sign_in_at: nil, name: "unconfirmed name", organisation: user.organisation) }

          it "shows users for multiple selected statuses" do
            get "/users?status[]=active&status[]=deactivated", headers:, params: {}
            follow_redirect!
            expect(page).to have_link(active_user.name)
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end

          it "shows filtered active users" do
            get "/users?status[]=active", headers:, params: {}
            follow_redirect!
            expect(page).to have_link(active_user.name)
            expect(page).not_to have_link(deactivated_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end

          it "shows filtered deactivated users" do
            get "/users?status[]=deactivated", headers:, params: {}
            follow_redirect!
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end

          it "shows filtered unconfirmed users" do
            get "/users?status[]=unconfirmed", headers:, params: {}
            follow_redirect!
            expect(page).to have_link(unconfirmed_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(deactivated_user.name)
          end

          it "does not reset the filters" do
            get "/users?status[]=deactivated", headers:, params: {}
            follow_redirect!
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)

            get "/users", headers:, params: {}
            follow_redirect!
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end
        end
      end
    end

    describe "CSV download" do
      let(:headers) { { "Accept" => "text/csv" } }
      let(:user) { create(:user) }

      before do
        get "/users", headers:, params: {}
      end

      it "returns 401 unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#show" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}", headers:, params: {}
        end

        it "show the user details" do
          expect(page).to have_content("Your account")
        end

        it "allows changing name, email, password, role, dpo and key contact" do
          expect(page).to have_link("Change", text: "name")
          expect(page).to have_link("Change", text: "email address")
          expect(page).to have_link("Change", text: "telephone number")
          expect(page).to have_link("Change", text: "password")
          expect(page).to have_link("Change", text: "role")
          expect(page).to have_link("Change", text: "if data protection officer")
          expect(page).to have_link("Change", text: "if a key contact")
          expect(page).not_to have_link("Change", text: "organisation")
        end

        it "does not allow deactivating the user" do
          expect(page).not_to have_link("Deactivate user", href: "/users/#{user.id}/deactivate")
        end

        context "when user is deactivated" do
          before do
            user.update!(active: false)
            get "/users/#{user.id}", headers:, params: {}
          end

          it "does not allow reactivating the user" do
            expect(page).not_to have_link("Reactivate user", href: "/users/#{user.id}/reactivate")
          end

          it "does not allow resending invitation emails" do
            expect(page).not_to have_button("Resend invite link")
          end

          it "does not allow deleting the the user" do
            expect(page).not_to have_link("Delete this user", href: "/users/#{user.id}/delete-confirmation")
          end
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}", headers:, params: {}
        end

        context "when the user is part of the same organisation as the current user" do
          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("#{other_user.name}’s account")
          end

          it "allows changing name, email, role, dpo and key contact" do
            expect(page).to have_link("Change", text: "name")
            expect(page).to have_link("Change", text: "email address")
            expect(page).to have_link("Change", text: "telephone number")
            expect(page).not_to have_link("Change", text: "password")
            expect(page).to have_link("Change", text: "role")
            expect(page).to have_link("Change", text: "if data protection officer")
            expect(page).to have_link("Change", text: "if a key contact")
            expect(page).not_to have_link("Change", text: "organisation")
          end

          it "allows deactivating the user" do
            expect(page).to have_link("Deactivate user", href: "/users/#{other_user.id}/deactivate")
          end

          it "does not allow you to resend invitation emails" do
            expect(page).not_to have_button("Resend invite link")
          end

          context "when user is deactivated" do
            before do
              other_user.update!(active: false)
              get "/users/#{other_user.id}", headers:, params: {}
            end

            it "shows if user is not active" do
              assert_select ".govuk-tag", text: /Deactivated/, count: 1
            end

            it "allows reactivating the user" do
              expect(page).to have_link("Reactivate user", href: "/users/#{other_user.id}/reactivate")
            end

            it "does not allow you to resend invitation emails" do
              expect(page).not_to have_button("Resend invite link")
            end
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { create(:user) }

          it "returns not found 404" do
            expect(response).to have_http_status(:not_found)
          end

          it "shows the 404 view" do
            expect(page).to have_content("Page not found")
          end
        end
      end
    end

    describe "#edit" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}/edit", headers:, params: {}
        end

        it "show the edit personal details page" do
          expect(page).to have_content("Change your personal details")
        end

        it "has fields for name, email, role, dpo and key contact" do
          expect(page).to have_field("user[name]")
          expect(page).to have_field("user[email]")
          expect(page).to have_field("user[role]")
          expect(page).not_to have_field("user[organisation_id]")
        end

        it "does not allow setting the role to `support`" do
          expect(page).not_to have_field("user-role-support-field")
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}/edit", headers:, params: {}
        end

        context "when the user is part of the same organisation as the current user" do
          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("Change #{other_user.name}’s personal details")
          end

          it "has fields for name, email, role, dpo and key contact" do
            expect(page).to have_field("user[name]")
            expect(page).to have_field("user[email]")
            expect(page).to have_field("user[role]")
            expect(page).not_to have_field("user[organisation_id]")
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { create(:user) }

          it "returns not found 404" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    describe "#edit_password" do
      context "when the current user matches the user ID" do
        before do
          get "/account/edit/password", headers:, params: {}
        end

        it "shows the edit password page" do
          expect(page).to have_content("Change your password")
        end

        it "shows the password requirements hint" do
          expect(page).to have_css("#user-password-hint")
        end
      end

      context "when the current user does not match the user ID" do
        it "there is no route" do
          expect {
            get "/users/#{other_user.id}/password/edit", headers:, params: {}
          }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    describe "#update" do
      context "when the current user matches the user ID" do
        before do
          patch "/users/#{user.id}", headers:, params:
        end

        it "updates the user" do
          user.reload
          expect(user.name).to eq(new_name)
        end

        it "tracks who updated the record" do
          user.reload
          whodunnit_actor = user.versions.last.actor
          expect(whodunnit_actor).to be_a(User)
          expect(whodunnit_actor.id).to eq(user.id)
        end

        context "when user changes email and dpo" do
          let(:params) { { id: user.id, user: { name: new_name, email: new_email, is_dpo: "true", is_key_contact: "true" } } }

          it "allows changing email and dpo" do
            user.reload
            expect(user.unconfirmed_email).to eq(new_email)
            expect(user.is_data_protection_officer?).to be true
            expect(user.is_key_contact?).to be true
          end
        end

        context "when we update the user password" do
          let(:params) do
            {
              id: user.id, user: { password: new_name, password_confirmation: "something_else" }
            }
          end

          before do
            patch "/users/#{user.id}", headers:, params:
          end

          it "shows an error if passwords don't match" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_selector(".govuk-error-summary__title")
          end
        end
      end

      context "when the current user does not match the user ID" do
        context "when the user is part of the same organisation as the current user" do
          it "updates the user" do
            expect { patch "/users/#{other_user.id}", headers:, params: }
              .to change { other_user.reload.name }.from(other_user.name).to(new_name)
          end

          it "tracks who updated the record" do
            expect { patch "/users/#{other_user.id}", headers:, params: }
              .to change { other_user.reload.versions.last.actor&.id }.from(nil).to(user.id)
          end

          context "when user changes email, dpo, key_contact" do
            let(:params) { { id: other_user.id, user: { name: new_name, email: new_email, is_dpo: "true", is_key_contact: "true" } } }

            it "allows changing email, dpo, key_contact" do
              patch "/users/#{other_user.id}", headers: headers, params: params
              other_user.reload
              expect(other_user.unconfirmed_email).to eq(new_email)
              expect(other_user.is_data_protection_officer?).to be true
              expect(other_user.is_key_contact?).to be true
            end
          end

          it "does not bypass sign in for the coordinator" do
            patch "/users/#{other_user.id}", headers: headers, params: params
            follow_redirect!
            expect(page).to have_content("#{other_user.reload.name}’s account")
            expect(page).to have_content(other_user.reload.email.to_s)
          end

          context "when the data coordinator tries to update the user’s password" do
            let(:params) do
              {
                id: user.id, user: { password: new_name, password_confirmation: new_name, name: "new name" }
              }
            end

            it "does not update the password" do
              expect { patch "/users/#{other_user.id}", headers:, params: }
                .not_to change(other_user, :encrypted_password)
            end

            it "does update other values" do
              expect { patch "/users/#{other_user.id}", headers:, params: }
                .to change { other_user.reload.name }.from("filter name").to("new name")
            end
          end

          context "when the data coordinator edits the user" do
            let(:params) do
              {
                id: other_user.id, user: { active: value }
              }
            end

            context "and tries to deactivate the user" do
              let(:value) { false }

              it "marks user as deactivated" do
                expect { patch "/users/#{other_user.id}", headers:, params: }
                  .to change { other_user.reload.active }.from(true).to(false)
              end

              it "discards unconfirmed email" do
                expect { patch "/users/#{other_user.id}", headers:, params: }
                  .to change { other_user.reload.unconfirmed_email }.from("email@something.com").to(nil)
              end
            end

            context "and tries to activate deactivated user" do
              let(:value) { true }

              before do
                other_user.update!(active: false)
              end

              it "marks user as active" do
                expect { patch "/users/#{other_user.id}", headers:, params: }
                  .to change { other_user.reload.active }.from(false).to(true)
              end
            end
          end
        end

        context "when the current user does not match the user ID" do
          context "when the user is not part of the same organisation as the current user" do
            let(:other_user) { create(:user) }
            let(:params) { { id: other_user.id, user: { name: new_name } } }

            before do
              patch "/users/#{other_user.id}", headers:, params:
            end

            it "returns not found 404" do
              expect(response).to have_http_status(:not_found)
            end
          end
        end
      end

      context "when the update fails to persist" do
        before do
          allow(User).to receive(:find_by).and_return(user)
          allow(user).to receive(:update).and_return(false)
          patch "/users/#{user.id}", headers:, params:
        end

        it "show an error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when updating telephone numbers" do
        let(:params) do
          {
            "user": {
              phone:,
            },
          }
        end

        before do
          patch "/users/#{user.id}", headers:, params:
        end

        context "when telephone number is not given" do
          let(:phone) { "" }

          it "validates telephone number" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.blank"))
          end
        end

        context "when telephone number is not numeric" do
          let(:phone) { "randomstring" }

          it "validates telephone number" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end

        context "when telephone number is shorter than 11 digits" do
          let(:phone) { "123" }

          it "validates telephone number" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end

        context "when telephone number is in correct format" do
          let(:phone) { "012345678919" }

          it "validates telephone number" do
            expect(page).not_to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end

        context "when telephone number is in correct format and includes +" do
          let(:phone) { "+12345678919" }

          it "validates telephone number" do
            expect(page).not_to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end
      end
    end

    describe "#create" do
      let(:user) { create(:user, :data_coordinator) }
      let(:params) do
        {
          "user": {
            name: "new user ",
            email: "new_user@example.com",
            role: "data_coordinator",
            phone: "12345678910",
            phone_extension: "1234",
          },
        }
      end

      let(:personalisation) do
        {
          name: "new user",
          email: params[:user][:email],
          organisation: user.organisation.name,
          link: include("/account/confirmation?confirmation_token="),
        }
      end
      let(:request) { post "/users/", headers:, params: }

      it "invites a new user" do
        expect { request }.to change(User, :count).by(1)
      end

      it "sends an invitation email" do
        expect(notify_client).to receive(:send_email).with(email_address: params[:user][:email], template_id: User::CONFIRMABLE_TEMPLATE_ID, personalisation:).once
        request
      end

      it "creates a new user for user organisation with valid params" do
        request

        expect(User.last.name).to eq("new user")
        expect(User.last.email).to eq("new_user@example.com")
        expect(User.last.role).to eq("data_coordinator")
        expect(User.last.phone).to eq("12345678910")
        expect(User.last.phone_extension).to eq("1234")
      end

      it "redirects back to organisation users page" do
        request
        expect(response).to redirect_to("/organisations/#{user.organisation.id}/users")
      end

      context "when the email is already taken" do
        before do
          create(:user, email: "new_user@example.com")
        end

        it "shows an error" do
          request
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.email.taken"))
        end
      end

      context "when trying to assign support role" do
        let(:params) do
          {
            "user": {
              name: "new user",
              email: "new_user@example.com",
              role: "support",
            },
          }
        end

        it "shows an error" do
          request
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.role.invalid"))
        end
      end

      context "when validating the required fields" do
        let(:params) do
          {
            "user": {
              name: "",
              email: "",
              role: "",
            },
          }
        end

        it "shows an error" do
          request
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.name.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.email.blank"))
        end
      end

      context "when validating telephone numbers" do
        let(:params) do
          {
            "user": {
              phone:,
            },
          }
        end

        context "when telephone number is not numeric" do
          let(:phone) { "randomstring" }

          it "validates telephone number" do
            request
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end

        context "when telephone number is shorter than 11 digits" do
          let(:phone) { "123" }

          it "validates telephone number" do
            request
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end

        context "when telephone number is in correct format" do
          let(:phone) { "012345678919" }

          it "validates telephone number" do
            request
            expect(page).not_to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end

        context "when telephone number is in correct format and includes +" do
          let(:phone) { "+12345678919" }

          it "validates telephone number" do
            request
            expect(page).not_to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.invalid"))
          end
        end
      end
    end

    describe "#new" do
      it "cannot assign support role to the new user" do
        get "/users/new"
        expect(page).not_to have_field("user-role-support-field")
      end
    end

    describe "#deactivate" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}/deactivate", headers:, params: {}
        end

        it "redirects user to user page" do
          expect(response).to redirect_to("/users/#{user.id}")
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}/deactivate", headers:, params: {}
        end

        it "shows deactivation page with deactivate and cancel buttons for the user" do
          expect(path).to include("/users/#{other_user.id}/deactivate")
          expect(page).to have_content(other_user.name)
          expect(page).to have_content("Are you sure you want to deactivate this user?")
          expect(page).to have_button("I’m sure – deactivate this user")
          expect(page).to have_link("No – I’ve changed my mind", href: "/users/#{other_user.id}")
        end
      end
    end

    describe "#reactivate" do
      context "when the current user does not match the user ID" do
        before do
          other_user.update!(active: false)
          get "/users/#{other_user.id}/reactivate", headers:, params: {}
        end

        it "shows reactivation page with reactivate and cancel buttons for the user" do
          expect(path).to include("/users/#{other_user.id}/reactivate")
          expect(page).to have_content(other_user.name)
          expect(page).to have_content("Are you sure you want to reactivate this user?")
          expect(page).to have_button("I’m sure – reactivate this user")
          expect(page).to have_link("No – I’ve changed my mind", href: "/users/#{other_user.id}")
        end
      end
    end

    describe "#delete-confirmation" do
      before do
        get "/users/#{user.id}/delete-confirmation"
      end

      it "returns 401 unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#delete" do
      before do
        delete "/users/#{user.id}/delete"
      end

      it "returns 401 unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#search" do
      let(:parent_relationship) { create(:organisation_relationship, parent_organisation: user.organisation) }
      let(:child_relationship) { create(:organisation_relationship, child_organisation: user.organisation) }
      let!(:org_user) { create(:user, organisation: user.organisation, email: "test_name@example.com") }
      let!(:managing_user) { create(:user, organisation: parent_relationship.child_organisation, email: "managing_agent_test_name@example.com") }

      before do
        create(:user, email: "other_organisation_test_name@example.com")
        create(:user, organisation: child_relationship.parent_organisation, email: "stock_owner_test_name@example.com")
      end

      it "only searches within the current user's organisation and managing agents" do
        get "/users/search", headers:, params: { query: "test_name" }
        result = JSON.parse(response.body)
        expect(result.count).to eq(2)
        expect(result.keys).to match_array([org_user.id.to_s, managing_user.id.to_s])
      end
    end

    describe "#log_reassignment" do
      it "returns unauthorised status" do
        get "/users/#{user.id}/log-reassignment"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context "when user is signed in as a support user" do
    let(:user) { create(:user, :support, organisation: create(:organisation, :without_dpc)) }
    let(:other_user) { create(:user, organisation: user.organisation, last_sign_in_at: Time.zone.now) }

    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    describe "#index" do
      let!(:other_user) { create(:user, organisation: user.organisation, name: "User 2", email: "other@example.com") }
      let!(:inactive_user) { create(:user, organisation: user.organisation, active: false, name: "User 3", email: "inactive@example.com", last_sign_in_at: Time.zone.local(2022, 10, 10)) }
      let!(:other_org_user) { create(:user, name: "User 4", email: "otherorg@otherexample.com", organisation: create(:organisation, :without_dpc, name: "Other name")) }

      before do
        get "/users", headers:, params: {}
      end

      it "shows all users" do
        expect(page).to have_content(user.name)
        expect(page).to have_content(other_user.name)
        expect(page).to have_content(inactive_user.name)
        expect(page).to have_content(other_org_user.name)
      end

      it "links to user organisations" do
        expect(page).to have_link(user.organisation.name, href: "/organisations/#{user.organisation.id}/lettings-logs", count: 3)
        expect(page).to have_link(other_org_user.organisation.name, href: "/organisations/#{other_org_user.organisation.id}/lettings-logs", count: 1)
      end

      it "shows last logged in date for all users" do
        expect(page).to have_content("10 October 2022")
      end

      it "shows status tag as deactivated for inactive users" do
        expect(page).to have_content("Deactivated")
      end

      it "shows the pagination count" do
        expect(page).to have_content("4 total users")
      end

      it "shows the download csv link" do
        expect(page).to have_link("Download (CSV)", href: "/users.csv")
      end

      it "shows a search bar" do
        expect(page).to have_field("search", type: "search")
      end

      context "when a search parameter is passed" do
        before do
          get "/users?search=#{search_param}"
        end

        context "when our search term matches a name" do
          context "when our search string matches case" do
            let(:search_param) { "Danny" }

            it "returns only matching results" do
              expect(page).to have_content(user.name)
              expect(page).not_to have_content(other_user.name)
              expect(page).not_to have_content(inactive_user.name)
              expect(page).not_to have_content(other_org_user.name)
            end

            it "updates the table caption" do
              expect(page).to have_content("1 user matching search")
            end

            it "includes the search term in the CSV download link" do
              expect(page).to have_link("Download (CSV)", href: "/users.csv?search=#{search_param}")
            end
          end

          context "when we need case insensitive search" do
            let(:search_param) { "danny" }

            it "returns only matching results" do
              expect(page).to have_content(user.name)
              expect(page).not_to have_content(other_user.name)
              expect(page).not_to have_content(inactive_user.name)
              expect(page).not_to have_content(other_org_user.name)
            end
          end

          context "when our search term matches an email" do
            let(:search_param) { "otherorg@otherexample.com" }

            it "returns only matching result" do
              expect(page).not_to have_content(user.name)
              expect(page).not_to have_content(other_user.name)
              expect(page).not_to have_content(inactive_user.name)
              expect(page).to have_content(other_org_user.name)
            end
          end

          context "when our search term matches an email and a name" do
            let!(:other_user) { create(:user, organisation: user.organisation, name: "joe", email: "other@example.com") }
            let!(:other_org_user) { create(:user, name: "User 4", email: "joe@otherexample.com", organisation: create(:organisation, :without_dpc)) }
            let(:search_param) { "joe" }

            it "returns any results including joe" do
              expect(page).to have_content(other_user.name)
              expect(page).not_to have_content(inactive_user.name)
              expect(page).to have_content(other_org_user.name)
              expect(page).not_to have_content(user.name)
            end

            it "updates the table caption" do
              expect(page).to have_content("2 users matching search")
            end
          end
        end
      end

      context "when filtering" do
        context "with status filter" do
          let!(:active_user) { create(:user, name: "active name", active: true, last_sign_in_at: Time.zone.now) }
          let!(:deactivated_user) { create(:user, active: false, name: "deactivated name", last_sign_in_at: Time.zone.now) }
          let!(:unconfirmed_user) { create(:user, last_sign_in_at: nil, name: "unconfirmed name") }

          it "shows users for multiple selected statuses" do
            get "/users?status[]=active&status[]=deactivated", headers:, params: {}
            expect(page).to have_link(active_user.name)
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end

          it "shows filtered active users" do
            get "/users?status[]=active", headers:, params: {}
            expect(page).to have_link(active_user.name)
            expect(page).not_to have_link(deactivated_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end

          it "shows filtered deactivated users" do
            get "/users?status[]=deactivated", headers:, params: {}
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end

          it "shows filtered unconfirmed users" do
            get "/users?status[]=unconfirmed", headers:, params: {}
            expect(page).to have_link(unconfirmed_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(deactivated_user.name)
          end

          it "does not reset the filters" do
            get "/users?status[]=deactivated", headers:, params: {}
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)

            get "/users", headers:, params: {}
            expect(page).to have_link(deactivated_user.name)
            expect(page).not_to have_link(active_user.name)
            expect(page).not_to have_link(unconfirmed_user.name)
          end
        end
      end
    end

    describe "CSV download" do
      let(:headers) { { "Accept" => "text/csv" } }
      let(:user) { create(:user, :support) }

      before do
        create_list(:user, 25)
      end

      context "when there is no search param" do
        before do
          get "/users", headers:, params: {}
        end

        let(:byte_order_mark) { "\uFEFF" }

        it "downloads a CSV file with headers" do
          csv = CSV.parse(response.body)

          expect(csv.first.to_csv).to eq(
            "#{byte_order_mark}id,email,name,organisation_name,role,old_user_id,is_dpo,is_key_contact,active,sign_in_count,last_sign_in_at\n",
          )
        end

        it "downloads all users" do
          csv = CSV.parse(response.body)
          expect(csv.count).to eq(User.all.count + 1) # +1 for the headers
        end

        it "downloads organisation names rather than ids" do
          csv = CSV.parse(response.body)
          expect(csv.second[3]).to eq(user.organisation.name.to_s)
        end
      end

      context "when there is a search param" do
        before do
          create(:user, name: "Unusual name")
          get "/users?search=unusual", headers:, params: {}
        end

        it "downloads only the matching records" do
          csv = CSV.parse(response.body)
          expect(csv.count).to eq(2)
        end
      end
    end

    describe "#show" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}", headers:, params: {}
        end

        it "show the user details" do
          expect(page).to have_content("Your account")
        end

        it "allows changing name, email, password, role, dpo and key contact" do
          expect(page).to have_link("Change", text: "name")
          expect(page).to have_link("Change", text: "email address")
          expect(page).to have_link("Change", text: "telephone number")
          expect(page).to have_link("Change", text: "password")
          expect(page).to have_link("Change", text: "role")
          expect(page).to have_link("Change", text: "if data protection officer")
          expect(page).to have_link("Change", text: "if a key contact")
          expect(page).to have_link("Change", text: "organisation")
        end

        it "does not allow deactivating the user" do
          expect(page).not_to have_link("Deactivate user", href: "/users/#{user.id}/deactivate")
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}", headers:, params: {}
        end

        context "when the user is part of the same organisation as the current user" do
          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("#{other_user.name}’s account")
          end

          it "allows changing name, email, role, dpo and key contact" do
            expect(page).to have_link("Change", text: "name")
            expect(page).to have_link("Change", text: "email address")
            expect(page).to have_link("Change", text: "telephone number")
            expect(page).not_to have_link("Change", text: "password")
            expect(page).to have_link("Change", text: "role")
            expect(page).to have_link("Change", text: "if data protection officer")
            expect(page).to have_link("Change", text: "if a key contact")
            expect(page).to have_link("Change", text: "organisation")
          end

          it "links to user organisation" do
            expect(page).to have_link(other_user.organisation.name, href: "/organisations/#{other_user.organisation.id}/lettings-logs")
          end

          it "does not show option to resend confirmation email" do
            expect(page).not_to have_button("Resend invite link")
          end

          it "allows deactivating the user" do
            expect(page).to have_link("Deactivate user", href: "/users/#{other_user.id}/deactivate")
          end

          it "does not alow deleting the the user" do
            expect(page).not_to have_link("Delete this user", href: "/users/#{other_user.id}/delete-confirmation")
          end

          context "when user never logged in" do
            before do
              other_user.update!(last_sign_in_at: nil)
              get "/users/#{other_user.id}", headers:, params: {}
            end

            it "returns 200" do
              expect(response).to have_http_status(:ok)
            end

            it "shows the user details page" do
              expect(page).to have_content("#{other_user.name}’s account")
            end

            it "allows changing name, email, role, dpo and key contact" do
              expect(page).to have_link("Change", text: "name")
              expect(page).to have_link("Change", text: "email address")
              expect(page).to have_link("Change", text: "telephone number")
              expect(page).not_to have_link("Change", text: "password")
              expect(page).to have_link("Change", text: "role")
              expect(page).to have_link("Change", text: "if data protection officer")
              expect(page).to have_link("Change", text: "if a key contact")
            end

            it "allows deactivating the user" do
              expect(page).to have_link("Deactivate user", href: "/users/#{other_user.id}/deactivate")
            end

            it "allows you to resend invitation emails" do
              expect(page).to have_button("Resend invite link")
            end

            it "does not allow deleting the the user" do
              expect(page).not_to have_link("Delete this user", href: "/users/#{other_user.id}/delete-confirmation")
            end
          end

          context "when user is deactivated" do
            before do
              other_user.update!(active: false)
              get "/users/#{other_user.id}", headers:, params: {}
            end

            it "shows if user is not active" do
              assert_select ".govuk-tag", text: /Deactivated/, count: 1
            end

            it "allows reactivating the user" do
              expect(page).to have_link("Reactivate user", href: "/users/#{other_user.id}/reactivate")
            end

            it "allows deleting the the user" do
              expect(page).to have_link("Delete this user", href: "/users/#{other_user.id}/delete-confirmation")
            end

            it "does not render informative text about deleting the user" do
              expect(response).to have_http_status(:ok)
              expect(page).not_to have_content("This user was active in an open or editable collection year, and cannot be deleted.")
            end

            context "and has associated logs in editable collection period" do
              before do
                create(:data_protection_confirmation, organisation: other_user.organisation, confirmed: true)
                create(:lettings_log, owning_organisation: other_user.organisation, assigned_to: other_user)
                get "/users/#{other_user.id}"
              end

              it "does not render delete this user" do
                expect(response).to have_http_status(:ok)
                expect(page).not_to have_link("Delete this user", href: "/users/#{user.id}/delete-confirmation")
              end

              it "adds informative text about deleting the user" do
                expect(response).to have_http_status(:ok)
                expect(page).to have_content("This user was active in an open or editable collection year, and cannot be deleted.")
              end
            end
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { create(:user) }

          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("#{other_user.name}’s account")
          end

          it "allows changing name, email, role, dpo and key contact" do
            expect(page).to have_link("Change", text: "name")
            expect(page).to have_link("Change", text: "email address")
            expect(page).to have_link("Change", text: "telephone number")
            expect(page).not_to have_link("Change", text: "password")
            expect(page).to have_link("Change", text: "role")
            expect(page).to have_link("Change", text: "if data protection officer")
            expect(page).to have_link("Change", text: "if a key contact")
          end
        end
      end
    end

    describe "#edit" do
      context "when the current user matches the user ID" do
        before do
          get "/users/#{user.id}/edit", headers:, params: {}
        end

        it "show the edit personal details page" do
          expect(page).to have_content("Change your personal details")
        end

        it "has fields for name, email, role, phone number and phone extension" do
          expect(page).to have_field("user[name]")
          expect(page).to have_field("user[email]")
          expect(page).to have_field("user[role]")
          expect(page).to have_field("user[phone]")
          expect(page).to have_field("user[phone_extension]")
          expect(page).to have_field("user[organisation_id]")
        end

        it "allows setting the role to `support`" do
          expect(page).to have_field("user-role-support-field")
        end
      end

      context "when the current user does not match the user ID" do
        before do
          get "/users/#{other_user.id}/edit", headers:, params: {}
        end

        context "when the user is part of the same organisation as the current user" do
          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("Change #{other_user.name}’s personal details")
          end

          it "has fields for name, email, role, phone number and phone extension" do
            expect(page).to have_field("user[name]")
            expect(page).to have_field("user[email]")
            expect(page).to have_field("user[role]")
            expect(page).to have_field("user[phone]")
            expect(page).to have_field("user[phone_extension]")
            expect(page).to have_field("user[organisation_id]")
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { create(:user) }

          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("Change #{other_user.name}’s personal details")
          end

          it "has fields for name, email, role, phone number and phone extension" do
            expect(page).to have_field("user[name]")
            expect(page).to have_field("user[email]")
            expect(page).to have_field("user[role]")
            expect(page).to have_field("user[phone]")
            expect(page).to have_field("user[phone_extension]")
            expect(page).to have_field("user[organisation_id]")
          end
        end

        context "when trying to edit deactivated user" do
          before do
            other_user.update!(active: false)
            get "/users/#{other_user.id}/edit", headers:, params: {}
          end

          it "redirects to user details page" do
            expect(response).to redirect_to("/users/#{other_user.id}")
            follow_redirect!
            expect(page).not_to have_link("Change")
          end
        end
      end
    end

    describe "#edit_password" do
      context "when the current user matches the user ID" do
        before do
          get "/account/edit/password", headers:, params: {}
        end

        it "shows the edit password page" do
          expect(page).to have_content("Change your password")
        end

        it "shows the password requirements hint" do
          expect(page).to have_css("#user-password-hint")
        end
      end

      context "when the current user does not match the user ID" do
        it "there is no route" do
          expect {
            get "/users/#{other_user.id}/password/edit", headers:, params: {}
          }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    describe "#update" do
      context "when the current user matches the user ID" do
        let(:request) { patch "/users/#{user.id}", headers:, params: }

        it "updates the user" do
          request
          user.reload
          expect(user.name).to eq(new_name)
        end

        it "tracks who updated the record" do
          request
          user.reload
          whodunnit_actor = user.versions.last.actor
          expect(whodunnit_actor).to be_a(User)
          expect(whodunnit_actor.id).to eq(user.id)
        end

        context "when user changes email, dpo and key contact", :aggregate_failures do
          let(:params) { { id: user.id, user: { name: new_name, email: new_email, is_dpo: "true", is_key_contact: "true" } } }
          let(:personalisation) do
            {
              name: params[:user][:name],
              email: new_email,
              organisation: user.organisation.name,
              link: include("/account/confirmation?confirmation_token="),
            }
          end

          before do
            user.legacy_users.destroy_all
          end

          it "shows flash notice" do
            patch("/users/#{other_user.id}", headers:, params:)

            expect(flash[:notice]).to eq("An email has been sent to #{new_email} to confirm this change.")
          end

          it "sends new flow emails" do
            expect(notify_client).to receive(:send_email).with(
              email_address: other_user.email,
              template_id: User::FOR_OLD_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
              personalisation: {
                new_email:,
                old_email: other_user.email,
              },
            ).once

            expect(notify_client).to receive(:send_email).with(
              email_address: new_email,
              template_id: User::FOR_NEW_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
              personalisation: {
                new_email:,
                old_email: other_user.email,
                link: include("/account/confirmation?confirmation_token="),
              },
            ).once

            expect(notify_client).not_to receive(:send_email)

            patch "/users/#{other_user.id}", headers:, params:
          end

          context "when user has never confirmed email address" do
            let(:old_email) { "old@test.com" }
            let(:new_email) { "new@test.com" }
            let(:other_user) { create(:user, organisation: user.organisation, email: old_email, confirmed_at: nil) }

            before do
              other_user.legacy_users.destroy_all
            end

            it "shows flash notice" do
              patch("/users/#{other_user.id}", headers:, params:)

              expect(flash[:notice]).to eq("An email has been sent to #{new_email} to confirm this change.")
            end

            it "sends new flow emails" do
              expect(notify_client).to receive(:send_email).with(
                email_address: new_email,
                template_id: User::RECONFIRMABLE_TEMPLATE_ID,
                personalisation: {
                  name: new_name,
                  email: new_email,
                  organisation: other_user.organisation.name,
                  link: include("/account/confirmation?confirmation_token="),
                },
              ).once

              expect(notify_client).to receive(:send_email).with(
                email_address: old_email,
                template_id: User::FOR_OLD_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
                personalisation: {
                  new_email:,
                  old_email:,
                },
              ).once

              expect(notify_client).not_to receive(:send_email)

              patch "/users/#{other_user.id}", headers:, params:
            end
          end
        end

        context "when we update the user password" do
          let(:params) do
            {
              id: user.id, user: { password: new_name, password_confirmation: "something_else" }
            }
          end

          before do
            patch "/users/#{user.id}", headers:, params:
          end

          it "shows an error if passwords don't match" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_selector(".govuk-error-summary__title")
          end
        end

        context "when updating organisation" do
          let(:new_organisation) { create(:organisation) }

          before do
            patch "/users/#{user.id}", headers:, params:
          end

          context "and organisation id is nil" do
            let(:params) { { id: user.id, user: { organisation_id: "" } } }

            it "does not update the organisation" do
              expect(response).to have_http_status(:unprocessable_entity)
              expect(page).to have_selector(".govuk-error-summary__title")
            end
          end

          context "and organisation id is not nil" do
            let(:params) { { id: user.id, user: { organisation_id: new_organisation.id, name: "new_name" } } }

            it "does not update the organisation" do
              expect(user.reload.organisation).not_to eq(new_organisation)
            end

            it "redirects to log reassignment page" do
              expect(response).to redirect_to("/users/#{user.id}/log-reassignment?organisation_id=#{new_organisation.id}")
            end

            it "updated other fields" do
              expect(user.reload.name).to eq("new_name")
            end
          end
        end
      end

      context "when the current user does not match the user ID" do
        context "when the user is part of the same organisation as the current user" do
          it "updates the user" do
            expect { patch "/users/#{other_user.id}", headers:, params: }
              .to change { other_user.reload.name }.from(other_user.name).to(new_name)
          end

          it "tracks who updated the record" do
            expect { patch "/users/#{other_user.id}", headers:, params: }
              .to change { other_user.reload.versions.last.actor&.id }.from(nil).to(user.id)
          end

          context "when user changes email, dpo, key_contact" do
            let(:params) { { id: other_user.id, user: { name: new_name, email: new_email, is_dpo: "true", is_key_contact: "true" } } }

            it "allows changing email, dpo, key_contact" do
              patch "/users/#{other_user.id}", headers: headers, params: params
              other_user.reload
              expect(other_user.unconfirmed_email).to eq(new_email)
              expect(other_user.is_data_protection_officer?).to be true
              expect(other_user.is_key_contact?).to be true
            end
          end

          it "does not bypass sign in for the support user" do
            patch "/users/#{other_user.id}", headers: headers, params: params
            follow_redirect!
            expect(page).to have_content("#{other_user.reload.name}’s account")
            expect(page).to have_content(other_user.reload.email.to_s)
          end

          context "when the support user tries to update the user’s password" do
            let(:params) do
              {
                id: user.id, user: { password: new_name, password_confirmation: new_name, name: "new name" }
              }
            end

            it "does not update the password" do
              expect { patch "/users/#{other_user.id}", headers:, params: }
                .not_to change(other_user, :encrypted_password)
            end

            it "does update other values" do
              expect { patch "/users/#{other_user.id}", headers:, params: }
                .to change { other_user.reload.name }.from("Danny Rojas").to("new name")
            end
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { create(:user) }
          let(:params) { { id: other_user.id, user: { name: new_name } } }

          it "updates the user" do
            expect { patch "/users/#{other_user.id}", headers:, params: }
              .to change { other_user.reload.name }.from(other_user.name).to(new_name)
          end

          it "tracks who updated the record" do
            expect { patch "/users/#{other_user.id}", headers:, params: }
              .to change { other_user.reload.versions.last.actor&.id }.from(nil).to(user.id)
          end

          context "when user changes email, dpo, key_contact" do
            let(:params) { { id: other_user.id, user: { name: new_name, email: new_email, is_dpo: "true", is_key_contact: "true" } } }

            it "allows changing email, dpo, key_contact" do
              patch "/users/#{other_user.id}", headers: headers, params: params
              other_user.reload
              expect(other_user.unconfirmed_email).to eq(new_email)
              expect(other_user.is_data_protection_officer?).to be true
              expect(other_user.is_key_contact?).to be true
            end
          end

          it "does not bypass sign in for the support user" do
            patch "/users/#{other_user.id}", headers: headers, params: params
            follow_redirect!
            expect(page).to have_content("#{other_user.reload.name}’s account")
            expect(page).to have_content(other_user.reload.email.to_s)
          end

          context "when the support user tries to update the user’s password", :aggregate_failures do
            let(:params) do
              {
                id: user.id, user: { password: new_name, password_confirmation: new_name, name: "new name", email: new_email }
              }
            end

            let(:personalisation) do
              {
                name: params[:user][:name],
                email: new_email,
                organisation: other_user.organisation.name,
                link: include("/account/confirmation?confirmation_token="),
              }
            end

            before do
              other_user.legacy_users.destroy_all
            end

            it "shows flash notice" do
              patch("/users/#{other_user.id}", headers:, params:)

              expect(flash[:notice]).to eq("An email has been sent to #{new_email} to confirm this change.")
            end

            it "sends new flow emails" do
              expect(notify_client).to receive(:send_email).with(
                email_address: other_user.email,
                template_id: User::FOR_OLD_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
                personalisation: {
                  new_email:,
                  old_email: other_user.email,
                },
              ).once

              expect(notify_client).to receive(:send_email).with(
                email_address: new_email,
                template_id: User::FOR_NEW_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
                personalisation: {
                  new_email:,
                  old_email: other_user.email,
                  link: include("/account/confirmation?confirmation_token="),
                },
              ).once

              expect(notify_client).not_to receive(:send_email)

              patch "/users/#{other_user.id}", headers:, params:
            end
          end

          context "when updating organisation" do
            let(:new_organisation) { create(:organisation) }

            before do
              patch "/users/#{other_user.id}", headers:, params:
            end

            context "and organisation id is nil" do
              let(:params) { { id: other_user.id, user: { organisation_id: "" } } }

              it "does not update the organisation" do
                expect(response).to have_http_status(:unprocessable_entity)
                expect(page).to have_selector(".govuk-error-summary__title")
              end
            end

            context "and organisation id is not nil" do
              let(:params) { { id: other_user.id, user: { organisation_id: new_organisation.id, name: "new_name" } } }

              it "does not update the organisation" do
                expect(user.reload.organisation).not_to eq(new_organisation)
              end

              it "redirects to log reassignment page" do
                expect(response).to redirect_to("/users/#{other_user.id}/log-reassignment?organisation_id=#{new_organisation.id}")
              end

              it "updated other fields" do
                expect(other_user.reload.name).to eq("new_name")
              end
            end
          end

          context "when updating log reassignment" do
            let(:new_organisation) { create(:organisation, name: "New org") }
            let(:new_organisation_2) { create(:organisation, name: "New org 2") }
            let(:new_organisation_3) { create(:organisation, name: "New org 3") }

            context "and log reassignment choice is not present" do
              let(:params) { { user: { organisation_id: new_organisation.id, log_reassignment: nil } } }

              before do
                patch "/users/#{other_user.id}/log-reassignment", headers:, params:
              end

              it "does not update the user's organisation" do
                expect(other_user.reload.organisation).not_to eq(new_organisation)
              end

              it "displays the error message" do
                expect(response).to have_http_status(:unprocessable_entity)
                expect(page).to have_content("Select if you want to reassign logs")
              end
            end

            context "and log reassignment choice is to change the stock owner and managing agent" do
              let(:params) { { user: { organisation_id: new_organisation.id, log_reassignment: "reassign_all" } } }

              before do
                patch "/users/#{other_user.id}/log-reassignment", headers:, params:
              end

              it "does not update the user's organisation" do
                expect(other_user.reload.organisation).not_to eq(new_organisation)
              end

              it "redirects to confirmation page" do
                expect(response).to redirect_to("/users/#{other_user.id}/confirm-organisation-change?log_reassignment=reassign_all&organisation_id=#{new_organisation.id}")
              end
            end

            context "and log reassignment choice is to unassign logs" do
              let(:params) { { user: { organisation_id: new_organisation.id, log_reassignment: "unassign" } } }

              before do
                patch "/users/#{other_user.id}/log-reassignment", headers:, params:
              end

              it "does not update the user's organisation" do
                expect(other_user.reload.organisation).not_to eq(new_organisation)
              end

              it "redirects to confirmation page" do
                expect(response).to redirect_to("/users/#{other_user.id}/confirm-organisation-change?log_reassignment=unassign&organisation_id=#{new_organisation.id}")
              end
            end

            context "and log reassignment choice is to change stock owner" do
              let(:params) { { user: { organisation_id: new_organisation.id, log_reassignment: "reassign_stock_owner" } } }

              context "when users organisation manages the logs" do
                before do
                  create(:lettings_log, managing_organisation: other_user.organisation, assigned_to: other_user)
                  create(:sales_log, managing_organisation: other_user.organisation, assigned_to: other_user)
                  patch "/users/#{other_user.id}/log-reassignment", headers:, params:
                end

                it "required the new org to have stock owner relationship with the current user org" do
                  expect(response).to have_http_status(:unprocessable_entity)
                  expect(page).to have_content("New org must be a stock owner of #{other_user.organisation_name} to make this change.")
                end
              end

              context "when different organisations manage the logs" do
                before do
                  create(:lettings_log, managing_organisation: other_user.organisation, assigned_to: other_user)
                  create(:lettings_log, managing_organisation: new_organisation_2, assigned_to: other_user)
                  create(:sales_log, managing_organisation: new_organisation_3, assigned_to: other_user)
                  patch "/users/#{other_user.id}/log-reassignment", headers:, params:
                end

                it "required the new org to have stock owner relationship with the managing organisations" do
                  expect(response).to have_http_status(:unprocessable_entity)
                  expect(page).to have_content("New org must be a stock owner of #{other_user.organisation_name}, #{new_organisation_2.name}, and #{new_organisation_3.name} to make this change.")
                end
              end
            end

            context "and log reassignment choice is to change managing agent" do
              let(:params) { { user: { organisation_id: new_organisation.id, log_reassignment: "reassign_managing_agent" } } }

              context "when users organisation manages the logs" do
                before do
                  create(:lettings_log, owning_organisation: other_user.organisation, assigned_to: other_user)
                  create(:sales_log, owning_organisation: other_user.organisation, assigned_to: other_user)
                  patch "/users/#{other_user.id}/log-reassignment", headers:, params:
                end

                it "required the new org to have managing agent relationship with the current user org" do
                  expect(response).to have_http_status(:unprocessable_entity)
                  expect(page).to have_content("New org must be a managing agent of #{other_user.organisation_name} to make this change.")
                end
              end

              context "when different organisations manage the logs" do
                before do
                  create(:lettings_log, owning_organisation: other_user.organisation, assigned_to: other_user)
                  create(:lettings_log, owning_organisation: new_organisation_2, assigned_to: other_user)
                  create(:sales_log, owning_organisation: new_organisation_3, managing_organisation: other_user.organisation, assigned_to: other_user)
                  patch "/users/#{other_user.id}/log-reassignment", headers:, params:
                end

                it "required the new org to have managing agent relationship with owning organisations" do
                  expect(response).to have_http_status(:unprocessable_entity)
                  expect(page).to have_content("New org must be a managing agent of #{other_user.organisation_name}, #{new_organisation_2.name}, and #{new_organisation_3.name} to make this change.")
                end
              end
            end
          end
        end
      end

      context "when the update fails to persist" do
        before do
          allow(User).to receive(:find_by).and_return(user)
          allow(user).to receive(:update).and_return(false)
          patch "/users/#{user.id}", headers:, params:
        end

        it "show an error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "#create" do
      let(:organisation) { create(:organisation, :without_dpc) }
      let(:email) { "new_user@example.com" }
      let(:params) do
        {
          "user": {
            name: "new user",
            email:,
            role: "data_coordinator",
            phone: "12345612456",
            phone_extension: "1234",
            organisation_id: organisation.id,
          },
        }
      end
      let(:request) { post "/users/", headers:, params: }

      it "invites a new user" do
        expect { request }.to change(User, :count).by(1)
      end

      it "adds the user to the correct organisation" do
        request
        expect(User.find_by(email:).organisation).to eq(organisation)
      end

      it "sets expected values on the user" do
        request
        user = User.find_by(email:)
        expect(user.name).to eq("new user")
        expect(user.phone).to eq("12345612456")
        expect(user.phone_extension).to eq("1234")
      end

      it "redirects back to users page" do
        request
        expect(response).to redirect_to("/users")
      end

      context "when validations fail" do
        let(:params) do
          {
            "user": {
              name: "",
              email: "",
              role: "",
              phone: "",
              organisation_id: nil,
            },
          }
        end

        before do
          create(:user, email: "new_user@example.com")
        end

        it "shows an error messages for all failed validations" do
          request
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.name.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.email.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.organisation_id.blank"))
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.phone.blank"))
        end
      end

      context "when the email is already taken" do
        before do
          create(:user, email: "new_user@example.com")
        end

        it "shows an error" do
          request
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("activerecord.errors.models.user.attributes.email.taken"))
        end
      end

      context "when trying to assign support role" do
        let(:params) do
          {
            "user": {
              name: "new user",
              email: "new_user@example.com",
              role: "support",
            },
          }
        end

        it "creates a new support user" do
          expect(User.last.role).to eq("support")
        end
      end
    end

    describe "#new" do
      before do
        create(:organisation, name: "other org")
      end

      context "when support user" do
        it "can assign support role to the new user" do
          get "/users/new"
          expect(page).to have_field("user-role-support-field")
        end

        it "can assign organisation to the new user" do
          get "/users/new"
          expect(page).to have_field("user-organisation-id-field")
        end

        it "has all organisation names in the dropdown" do
          get "/users/new"
          expect(page).to have_select("user-organisation-id-field", with_options: Organisation.pluck(:name))
        end

        context "when organisation id is present in params and there are multiple organisations in the database" do
          it "has only specific organisation name in the dropdown" do
            get "/users/new", params: { organisation_id: user.organisation.id }
            expect(page).to have_select("user-organisation-id-field", options: [user.organisation.name])
          end
        end
      end
    end

    describe "#delete-confirmation" do
      let(:other_user) { create(:user, active: false) }

      before do
        get "/users/#{other_user.id}/delete-confirmation"
      end

      it "shows the correct title" do
        expect(page.find("h1").text).to include "Are you sure you want to delete this user?"
      end

      it "shows a warning to the user" do
        expect(page).to have_selector(".govuk-warning-text", text: "You will not be able to undo this action")
      end

      it "shows a button to delete the selected user" do
        expect(page).to have_selector("form.button_to button", text: "Delete this user")
      end

      it "the delete user button submits the correct data to the correct path" do
        form_containing_button = page.find("form.button_to")

        expect(form_containing_button[:action]).to eq delete_user_path(other_user)
        expect(form_containing_button).to have_field "_method", type: :hidden, with: "delete"
      end

      it "shows a cancel link with the correct style" do
        expect(page).to have_selector("a.govuk-button--secondary", text: "Cancel")
      end

      it "shows cancel link that links back to the user page" do
        expect(page).to have_link(text: "Cancel", href: user_path(other_user))
      end
    end

    describe "#delete" do
      let(:other_user) { create(:user, name: "User to be deleted", active: false) }

      before do
        delete "/users/#{other_user.id}/delete"
      end

      it "deletes the user" do
        other_user.reload
        expect(other_user.status).to eq(:deleted)
        expect(other_user.discarded_at).not_to be nil
      end

      it "redirects to the users list and displays a notice that the user has been deleted" do
        expect(response).to redirect_to users_organisation_path(other_user.organisation)
        follow_redirect!
        expect(page).to have_selector(".govuk-notification-banner--success")
        expect(page).to have_selector(".govuk-notification-banner--success", text: "User to be deleted has been deleted.")
      end

      it "does not display the deleted user" do
        expect(response).to redirect_to users_organisation_path(other_user.organisation)
        follow_redirect!
        expect(page).not_to have_link("User to be deleted")
      end
    end

    describe "#search" do
      let(:parent_relationship) { create(:organisation_relationship, parent_organisation: user.organisation) }
      let(:child_relationship) { create(:organisation_relationship, child_organisation: user.organisation) }
      let!(:org_user) { create(:user, organisation: user.organisation, name: "test_name") }
      let!(:managing_user) { create(:user, organisation: child_relationship.parent_organisation, name: "stock_owner_test_name") }
      let!(:owner_user) { create(:user, organisation: parent_relationship.child_organisation, name: "managing_agent_test_name") }
      let!(:other_user) { create(:user, name: "other_organisation_test_name") }

      it "searches all users" do
        get "/users/search", headers:, params: { query: "test_name" }
        result = JSON.parse(response.body)
        expect(result.count).to eq(4)
        expect(result.keys).to match_array([org_user.id.to_s, managing_user.id.to_s, owner_user.id.to_s, other_user.id.to_s])
      end
    end

    describe "#log_reassignment" do
      context "when organisation id is not given" do
        it "redirects to the user page" do
          get "/users/#{other_user.id}/log-reassignment"
          expect(response).to redirect_to("/users/#{other_user.id}")
        end
      end

      context "when organisation id does not exist" do
        it "redirects to the user page" do
          get "/users/#{other_user.id}/log-reassignment?organisation_id=123123"
          expect(response).to redirect_to("/users/#{other_user.id}")
        end
      end

      context "with valid organisation id" do
        let(:new_organisation) { create(:organisation, name: "new org") }

        before do
          create(:lettings_log, assigned_to: other_user)
        end

        it "allows reassigning logs" do
          get "/users/#{other_user.id}/log-reassignment?organisation_id=#{new_organisation.id}"
          expect(page).to have_content("Should this user’s logs move to their new organisation?")
          expect(page).to have_content("You’re moving #{other_user.name} from #{other_user.organisation_name} to new org. There is 1 log assigned to them.")
          expect(page).to have_button("Continue")
          expect(page).to have_link("Back", href: "/users/#{other_user.id}/edit")
          expect(page).to have_link("Cancel", href: "/users/#{other_user.id}/edit")
        end
      end
    end
  end

  describe "title link" do
    before do
      sign_in user
    end

    it "routes user to the home page" do
      get "/", headers:, params: {}
      expect(path).to eq("/")
      expect(page).to have_content("Welcome back")
      expected_link = "<a class=\"govuk-header__link govuk-header__link--homepage\" href=\"/\">"
      expect(CGI.unescape_html(response.body)).to include(expected_link)
    end
  end
end
