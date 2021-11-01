require "rails_helper"
RSpec.describe "User Features" do
    let!(:user) { FactoryBot.build(:user) }
    context "A user navigating to case logs" do
        it " is required to log in" do
            visit("/case_logs")
            expect(page).to have_current_path("/users/sign_in")
        end
    end
end