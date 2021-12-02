require "rails_helper"
require_relative "../support/devise"

RSpec.describe UsersController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "#show" do
    before do
      sign_in user
      get "/users/#{user.id}", headers: headers, params: {}
    end

    it "show the user details" do
      expect(page).to have_content("Your account")
    end
  end

  describe "#edit" do
    before do
      sign_in user
      get "/users/#{user.id}/edit", headers: headers, params: {}
    end

    it "show the edit personal details page" do
      expect(page).to have_content("Change your personal details")
    end
  end

  describe "#edit_password" do
    before do
      sign_in user
      get "/users/#{user.id}/password/edit", headers: headers, params: {}
    end

    it "show the edit password page" do
      expect(page).to have_content("Change your password")
    end
  end
end
