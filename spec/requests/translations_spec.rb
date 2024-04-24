require 'rails_helper'

RSpec.describe "Translations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/translations/index"
      expect(response).to have_http_status(:success)
    end
  end

end
