require "rails_helper"

RSpec.describe "Bulk upload sales log" do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context "when during crossover period" do
    it "shows journey with year option" do
      Timecop.freeze(2023, 6, 1) do
        visit("/sales-logs")
        expect(page).to have_link("Upload sales log in bulk")
        click_link("Upload sales log in bulk")

        expect(page).to have_content("Which year")
        click_button("Continue")

        expect(page).to have_content("You must select a collection period to upload for")
        choose("2022/2023")
        click_button("Continue")

        expect(page).to have_content("prepare file goes here")
        click_link("Back")

        expect(page.find_field("form-year-2022-field")).to be_checked
      end
    end
  end
end
