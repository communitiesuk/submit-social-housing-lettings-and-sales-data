require "rails_helper"

RSpec.describe UsersController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:unauthorised_user) { FactoryBot.create(:user) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:new_value) { "new test name" }
  let(:params) { { id: user.id, user: { name: new_value } } }
  let(:notify_client) { double(Notifications::Client) }

  before do
    allow_any_instance_of(DeviseNotifyMailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  context "a not signed in user" do
    describe "#show" do
      it "does not let you see user details" do
        get "/users/#{user.id}", headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end

    describe "#edit" do
      it "does not let you edit user details" do
        get "/users/#{user.id}/edit", headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end

    describe "#password" do
      it "does not let you edit user passwords" do
        get "/users/#{user.id}/password/edit", headers: headers, params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end

    describe "#patch" do
      it "does not let you update user details" do
        patch "/logs/#{user.id}", params: {}
        expect(response).to redirect_to("/users/sign-in")
      end
    end

    describe "reset password" do
      it "renders the user edit password view" do
        _raw, enc = Devise.token_generator.generate(User, :reset_password_token)
        get "/users/password/edit?reset_password_token=#{enc}"
        expect(page).to have_css("h1", class: "govuk-heading-l", text: "Reset your password")
      end

      context "update password" do
        context "valid reset token" do
          let(:params) do
            {
              id: user.id, user: { password: new_value, password_confirmation: "something_else" }
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

        context "reset token more than 3 hours old" do
          let(:raw) { user.send_reset_password_instructions }
          let(:params) do
            {
              id: user.id,
              user: {
                password: new_value,
                password_confirmation: new_value,
                reset_password_token: raw,
              },
            }
          end

          before do
            allow_any_instance_of(User).to receive(:reset_password_sent_at).and_return(4.hours.ago)
            put "/users/password", headers: headers, params: params
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
        get "/", headers: headers, params: {}
        expected_link = "href=\"/\">#{I18n.t('service_name')}</a>"
        expect(CGI.unescape_html(response.body)).to include(expected_link)
      end
    end
  end

  describe "#show" do
    context "current user is user" do
      before do
        sign_in user
        get "/users/#{user.id}", headers: headers, params: {}
      end

      it "show the user details" do
        expect(page).to have_content("Your account")
      end
    end

    context "current user is another user" do
      before do
        sign_in user
        get "/users/#{unauthorised_user.id}", headers: headers, params: {}
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
    context "current user is user" do
      before do
        sign_in user
        get "/users/#{user.id}/edit", headers: headers, params: {}
      end

      it "show the edit personal details page" do
        expect(page).to have_content("Change your personal details")
      end
    end

    context "current user is another user" do
      before do
        sign_in user
        get "/users/#{unauthorised_user.id}/edit", headers: headers, params: {}
      end

      it "returns not found 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#edit_password" do
    context "current user is user" do
      before do
        sign_in user
        get "/users/#{user.id}/password/edit", headers: headers, params: {}
      end

      it "show the edit password page" do
        expect(page).to have_content("Change your password")
      end
    end

    context "current user is another user" do
      before do
        sign_in user
        get "/users/#{unauthorised_user.id}/edit", headers: headers, params: {}
      end

      it "returns not found 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#update" do
    context "current user is user" do
      before do
        sign_in user
        patch "/users/#{user.id}", headers: headers, params: params
      end

      it "updates the user" do
        user.reload
        expect(user.name).to eq(new_value)
      end
    end

    context "update fails to persist" do
      before do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        sign_in user
        patch "/users/#{user.id}", headers: headers, params: params
      end

      it "show an error" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "current user is another user" do
      let(:params) { { id: unauthorised_user.id, user: { name: new_value } } }

      before do
        sign_in user
        patch "/users/#{unauthorised_user.id}", headers: headers, params: params
      end

      it "returns not found 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "update password" do
      let(:params) do
        {
          id: user.id, user: { password: new_value, password_confirmation: "something_else" }
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

  describe "title link" do
    before do
      sign_in user
    end

    it "routes user to the /logs page" do
      get "/", headers: headers, params: {}
      expected_link = "href=\"/logs\">#{I18n.t('service_name')}</a>"
      expect(CGI.unescape_html(response.body)).to include(expected_link)
    end
  end
end
