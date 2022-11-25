require "rails_helper"

RSpec.describe "Bulk upload lettings log" do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context "when during crossover period" do
    it "shows journey with year option" do
      Timecop.freeze(2023, 6, 1) do
        visit("/lettings-logs")
        expect(page).to have_link("Upload lettings log in bulk")
        click_link("Upload lettings log in bulk")

        expect(page).to have_content("Which year")
        click_button("Continue")

        expect(page).to have_content("You must select a collection period to upload for")
        choose("2022/2023")
        click_button("Continue")

        click_link("Back")

        expect(page.find_field("form-year-2022-field")).to be_checked
        click_button("Continue")

        expect(page).to have_content("Upload lettings logs in bulk (2022/23)")
        click_button("Continue")

        expect(page).to have_content("Upload your file")
      end
    end
  end
end
