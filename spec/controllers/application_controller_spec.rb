require "rails_helper"

RSpec.describe ApplicationController do
  describe "when Pundit::NotAuthorizedError raised" do
    render_views

    controller do
      def index
        raise Pundit::NotAuthorizedError, "error goes here"
      end
    end

    it "returns status 401 unauthorized" do
      get :index
      expect(response).to be_unauthorized
    end

    it "renders page not found" do
      get :index
      expect(response.body).to have_content("Page not found")
    end
  end
end
