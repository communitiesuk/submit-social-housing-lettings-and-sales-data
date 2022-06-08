require "rails_helper"

RSpec.describe "Supported housing scheme Features" do
  context "when viewing list of schemes" do
    context "when I am signed as a support user in there are schemes in the database" do
      let(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
      let!(:schemes) { FactoryBot.create(:schemes) }
      
    end
  end
end
