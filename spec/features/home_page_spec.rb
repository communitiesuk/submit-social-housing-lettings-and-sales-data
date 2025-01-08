require "rails_helper"

RSpec.describe "Home Page Features" do
  include CollectionTimeHelper

  let!(:user) { FactoryBot.create(:user) }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }
  let(:current_collection_year) { 2024 }
  let(:next_collection_year) { 2025 }

  before do
    sign_in user
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  context "when visiting during the current collection year" do
    before do
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(false)
      allow_any_instance_of(CollectionTimeHelper).to receive(:current_collection_start_year).and_return(current_collection_year)
      allow_any_instance_of(CollectionTimeHelper).to receive(:current_collection_end_year).and_return(current_collection_year + 1)
      visit root_path
      find("span.govuk-details__summary-text", text: "Quarterly cut-off dates for 2024 to 2025").click
    end

    after { travel_back }

    scenario "displays correct text for Q1" do
      travel_to Time.zone.local(current_collection_year, 4, 1) do
        expect(page).to have_content("Q1 - Friday 12 July 2024")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 6 June 2025.")
      end
    end

    scenario "displays correct text for Q2" do
      travel_to Time.zone.local(current_collection_year, 7, 1) do
        expect(page).to have_content("Q2 - Friday 11 October 2024")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 6 June 2025.")
      end
    end

    scenario "displays correct text for Q3" do
      travel_to Time.zone.local(current_collection_year, 10, 1) do
        expect(page).to have_content("Q3 - Friday 10 January 2025")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 6 June 2025.")
      end
    end

    scenario "displays correct text for Q4" do
      travel_to Time.zone.local(current_collection_year + 1, 3, 1) do
        expect(page).to have_content("End of year deadline - Friday 6 June 2025")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 6 June 2025.")
      end
    end
  end

  context "when visiting during the next collection year" do
    before do
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(false)
      allow_any_instance_of(CollectionTimeHelper).to receive(:current_collection_start_year).and_return(next_collection_year)
      allow_any_instance_of(CollectionTimeHelper).to receive(:current_collection_end_year).and_return(next_collection_year + 1)
      visit root_path
      find("span.govuk-details__summary-text", text: "Quarterly cut-off dates for 2025 to 2026").click
    end

    after { travel_back }

    scenario "displays correct text for Q1" do
      travel_to Time.zone.local(next_collection_year, 4, 1) do
        expect(page).to have_content("Q1 - Friday 11 July 2025")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 5 June 2026.")
      end
    end

    scenario "displays correct text for Q2" do
      travel_to Time.zone.local(next_collection_year, 7, 1) do
        expect(page).to have_content("Q2 - Friday 10 October 2025")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 5 June 2026.")
      end
    end

    scenario "displays correct text for Q3" do
      travel_to Time.zone.local(next_collection_year, 10, 1) do
        expect(page).to have_content("Q3 - Friday 16 January 2026")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 5 June 2026.")
      end
    end

    scenario "displays correct text for Q4" do
      travel_to Time.zone.local(next_collection_year + 1, 3, 1) do
        expect(page).to have_content("End of year deadline - Friday 5 June 2026")
        expect(page).to have_content("You can still create logs for a previous quarter after its cut-off date, as long as you complete them by the end-of-year deadline: Friday 5 June 2026.")
      end
    end
  end
end
