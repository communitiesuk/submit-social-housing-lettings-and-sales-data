require "rails_helper"

RSpec.describe "Supported housing scheme Features" do
  context "when viewing list of schemes" do
    context "when I am signed as a support user in there are schemes in the database" do
      let(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
      let!(:schemes) { FactoryBot.create(:scheme) }

      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: user.password)
        click_button("Sign in")
      end

      it "displays the link to the supported housing" do
        expect(page).to have_link("Supported housing")
      end
    end
  end
end
