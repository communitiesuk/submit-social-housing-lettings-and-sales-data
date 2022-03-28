require "rails_helper"

RSpec.describe UsersController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
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
        get "/users/#{user.id}/password/edit", headers: headers, params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "#patch" do
      it "does not let you update user details" do
        patch "/logs/#{user.id}", params: {}
        expect(response).to redirect_to("/account/sign-in")
      end
    end

    describe "reset password" do
      it "renders the user edit password view" do
        _raw, enc = Devise.token_generator.generate(User, :reset_password_token)
        get "/account/password/edit?reset_password_token=#{enc}"
        expect(page).to have_css("h1", class: "govuk-heading-l", text: "Reset your password")
      end

      context "when updating a user password" do
        context "when the reset token is valid" do
          let(:params) do
            {
              id: user.id, user: { password: new_name, password_confirmation: "something_else" }
            }
          end

          before do
            sign_in user
            put "/users/#{user.id}", headers: headers, params: params
          end

          it "shows an error if passwords don't match" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_selector("#error-summary-title")
            expect(page).to have_content("Password confirmation doesn't match Password")
          end
        end

        context "when a reset token is more than 3 hours old" do
          let(:raw) { user.send_reset_password_instructions }
          let(:params) do
            {
              id: user.id,
              user: {
                password: new_name,
                password_confirmation: new_name,
                reset_password_token: raw,
              },
            }
          end

          before do
            allow(User).to receive(:find_or_initialize_with_error_by).and_return(user)
            allow(user).to receive(:reset_password_sent_at).and_return(4.hours.ago)
            put "/account/password", headers: headers, params: params
          end

          it "shows an error" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_selector("#error-summary-title")
            expect(page).to have_content("Reset password token has expired, please request a new one")
          end
        end
      end
    end

    describe "title link" do
      it "routes user to the /logs page" do
        get "/", headers:, params: {}
        expected_link = "href=\"/\">#{I18n.t('service_name')}</a>"
        expect(CGI.unescape_html(response.body)).to include(expected_link)
      end
    end
  end

  context "when user is signed in as a data provider" do
    describe "#show" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          get "/users/#{user.id}", headers: headers, params: {}
        end

        it "show the user details" do
          expect(page).to have_content("Your account")
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
          get "/users/#{other_user.id}", headers: headers, params: {}
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end

        it "shows the 404 view" do
          expect(page).to have_content("Page not found")
        end
      end
    end

    describe "#edit" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          get "/users/#{user.id}/edit", headers: headers, params: {}
        end

        it "show the edit personal details page" do
          expect(page).to have_content("Change your personal details")
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
          get "/users/#{other_user.id}/edit", headers: headers, params: {}
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#edit_password" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          get "/users/#{user.id}/password/edit", headers: headers, params: {}
        end

        it "shows the edit password page" do
          expect(page).to have_content("Change your password")
        end

        it "shows the password requirements hint" do
          expect(page).to have_css("#user-password-hint")
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
          get "/users/#{other_user.id}/edit", headers: headers, params: {}
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#update" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          patch "/users/#{user.id}", headers: headers, params: params
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
          let(:params) { { id: user.id, user: { name: new_name, email: new_email, is_dpo: "1" } } }

          it "allows changing email and dpo" do
            user.reload
            expect(user.email).to eq(new_email)
            expect(user.is_data_protection_officer?).to be true
          end
        end
      end

      context "when the update fails to persist" do
        before do
          sign_in user
          allow(User).to receive(:find_by).and_return(user)
          allow(user).to receive(:update).and_return(false)
          patch "/users/#{user.id}", headers: headers, params: params
        end

        it "show an error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when the current user does not matches the user ID" do
        let(:params) { { id: other_user.id, user: { name: new_name } } }

        before do
          sign_in user
          patch "/users/#{other_user.id}", headers: headers, params: params
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
          sign_in user
          patch "/users/#{user.id}", headers: headers, params: params
        end

        it "shows an error if passwords don't match" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_selector("#error-summary-title")
        end
      end
    end
  end

  context "when user is signed in as a data coordinator" do
    let(:user) { FactoryBot.create(:user, :data_coordinator) }
    let(:other_user) { FactoryBot.create(:user, organisation: user.organisation) }

    describe "#show" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          get "/users/#{user.id}", headers: headers, params: {}
        end

        it "show the user details" do
          expect(page).to have_content("Your account")
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
          get "/users/#{other_user.id}", headers: headers, params: {}
        end

        context "when the user is part of the same organisation as the current user" do
          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("#{other_user.name}’s account")
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { FactoryBot.create(:user) }

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
          sign_in user
          get "/users/#{user.id}/edit", headers: headers, params: {}
        end

        it "show the edit personal details page" do
          expect(page).to have_content("Change your personal details")
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
          get "/users/#{other_user.id}/edit", headers: headers, params: {}
        end

        context "when the user is part of the same organisation as the current user" do
          it "returns 200" do
            expect(response).to have_http_status(:ok)
          end

          it "shows the user details page" do
            expect(page).to have_content("Change #{other_user.name}’s personal details")
          end
        end

        context "when the user is not part of the same organisation as the current user" do
          let(:other_user) { FactoryBot.create(:user) }

          it "returns not found 404" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end

    describe "#edit_password" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          get "/users/#{user.id}/password/edit", headers: headers, params: {}
        end

        it "shows the edit password page" do
          expect(page).to have_content("Change your password")
        end

        it "shows the password requirements hint" do
          expect(page).to have_css("#user-password-hint")
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
          get "/users/#{other_user.id}/password/edit", headers: headers, params: {}
        end

        it "returns not found 404" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#update" do
      context "when the current user matches the user ID" do
        before do
          sign_in user
          patch "/users/#{user.id}", headers: headers, params: params
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
          let(:params) { { id: user.id, user: { name: new_name, email: new_email, is_dpo: "1" } } }

          it "allows changing email and dpo" do
            user.reload
            expect(user.email).to eq(new_email)
            expect(user.is_data_protection_officer?).to be true
          end
        end

        context "when we update the user password" do
          let(:params) do
            {
              id: user.id, user: { password: new_name, password_confirmation: "something_else" }
            }
          end

          before do
            sign_in user
            patch "/users/#{user.id}", headers: headers, params: params
          end

          it "shows an error if passwords don't match" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(page).to have_selector("#error-summary-title")
          end
        end
      end

      context "when the current user does not matches the user ID" do
        before do
          sign_in user
        end

        context "when the user is part of the same organisation as the current user" do
          it "updates the user" do
            expect { patch "/users/#{other_user.id}", headers: headers, params: params }
              .to change { other_user.reload.name }.from(other_user.name).to(new_name)
          end

          it "tracks who updated the record" do
            expect { patch "/users/#{other_user.id}", headers: headers, params: params }
              .to change { other_user.reload.versions.last.actor&.id }.from(nil).to(user.id)
          end

          context "when user changes email and dpo" do
            let(:params) { { id: other_user.id, user: { name: new_name, email: new_email, is_dpo: "1" } } }

            it "allows changing email and dpo" do
              patch "/users/#{other_user.id}", headers: headers, params: params
              other_user.reload
              expect(other_user.email).to eq(new_email)
              expect(other_user.is_data_protection_officer?).to be true
            end
          end

          it "does not bypass sign in for the coordinator" do
            patch "/users/#{other_user.id}", headers: headers, params: params
            follow_redirect!
            expect(page).to have_content("#{other_user.reload.name}’s account")
            expect(page).to have_content(other_user.reload.email.to_s)
          end

          context "when we try to update the user password" do
            let(:params) do
              {
                id: user.id, user: { password: new_name, password_confirmation: new_name, name: "new name" }
              }
            end

            it "does not update the password" do
              expect { patch "/users/#{other_user.id}", headers: headers, params: params }
                .not_to change(other_user, :encrypted_password)
            end

            it "does update other values" do
              expect { patch "/users/#{other_user.id}", headers: headers, params: params }
                .to change { other_user.reload.name }.from("Danny Rojas").to("new name")
            end
          end
        end

        context "when the current user does not matches the user ID" do
          context "when the user is not part of the same organisation as the current user" do
            let(:other_user) { FactoryBot.create(:user) }
            let(:params) { { id: other_user.id, user: { name: new_name } } }

            before do
              sign_in user
              patch "/users/#{other_user.id}", headers: headers, params: params
            end

            it "returns not found 404" do
              expect(response).to have_http_status(:not_found)
            end
          end
        end
      end

      context "when the update fails to persist" do
        before do
          sign_in user
          allow(User).to receive(:find_by).and_return(user)
          allow(user).to receive(:update).and_return(false)
          patch "/users/#{user.id}", headers: headers, params: params
        end

        it "show an error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
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
    let(:request) { post "/users/", headers: headers, params: params }

    before do
      sign_in user
    end

    it "invites a new user" do
      expect { request }.to change(User, :count).by(1)
    end

    it "redirects back to organisation users page" do
      request
      expect(response).to redirect_to("/organisations/#{user.organisation.id}/users")
    end

    context "when the email is already taken" do
      before do
        FactoryBot.create(:user, email: "new_user@example.com")
      end

      it "shows an error" do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(page).to have_content(I18n.t("validations.email.taken"))
      end
    end
  end

  describe "title link" do
    before do
      sign_in user
    end

    it "routes user to the /logs page" do
      get "/", headers:, params: {}
      expected_link = "href=\"/logs\">#{I18n.t('service_name')}</a>"
      follow_redirect!
      expect(CGI.unescape_html(response.body)).to include(expected_link)
    end
  end
end
