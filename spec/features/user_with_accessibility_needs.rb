require 'rails_helper'

RSpec.describe "A11y testing" do
  let!(:user) { FactoryBot.create(:user) }
  scenario 'case logs index is an accessible page', js: true do
    visit("/case_logs")
    fill_in("user_email", with: "test@example.com")
    fill_in("user_password", with: "pAssword1")
    click_button("Sign in")
    expect(page).to have_current_path("/case_logs")
    expect(page).to be_axe_clean
  end
end