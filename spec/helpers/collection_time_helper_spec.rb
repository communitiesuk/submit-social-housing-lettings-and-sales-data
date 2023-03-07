require "rails_helper"

RSpec.describe CollectionTimeHelper do
  let(:current_user) { create(:user, :data_coordinator) }
  let(:user) { create(:user, :data_coordinator) }

  describe "Current collection start year" do
    around do |example|
      Timecop.freeze(now) do
        example.run
      end
      Timecop.return
    end

    context "when the date is after 1st of April" do
      let(:now) { Time.utc(2022, 8, 3) }

      it "returns the same year as the current start year" do
        expect(current_collection_start_year).to eq(2022)
      end

      it "returns the correct current start date" do
        expect(current_collection_start_date).to eq(Time.zone.local(2022, 4, 1))
      end

      it "returns the correct current end date" do
        expect(current_collection_end_date).to eq(Time.zone.local(2023, 3, 31).end_of_day)
      end
    end

    context "with the date before 1st of April" do
      let(:now) { Time.utc(2022, 2, 3) }

      it "returns the previous year as the current start year" do
        expect(current_collection_start_year).to eq(2021)
      end

      it "returns the correct current start date" do
        expect(current_collection_start_date).to eq(Time.zone.local(2021, 4, 1))
      end

      it "returns the correct current end date" do
        expect(current_collection_end_date).to eq(Time.zone.local(2022, 3, 31).end_of_day)
      end
    end
  end

  describe "Any collection year" do
    context "when the date is after 1st of April" do
      let(:now) { Time.utc(2022, 8, 3) }

      it "returns the same year as the current start year" do
        expect(collection_start_year(now)).to eq(2022)
      end

      it "returns the correct current start date" do
        expect(collection_start_date(now)).to eq(Time.zone.local(2022, 4, 1))
      end

      it "returns the correct current end date" do
        expect(collection_end_date(now)).to eq(Time.zone.local(2023, 3, 31).end_of_day)
      end
    end

    context "with the date before 1st of April" do
      let(:now) { Time.utc(2022, 2, 3) }

      it "returns the previous year as the current start year" do
        expect(collection_start_year(now)).to eq(2021)
      end

      it "returns the correct current start date" do
        expect(collection_start_date(now)).to eq(Time.zone.local(2021, 4, 1))
      end

      it "returns the correct current end date" do
        expect(collection_end_date(now)).to eq(Time.zone.local(2022, 3, 31).end_of_day)
      end
    end
  end

  describe "#date_mid_collection_year_formatted" do
    subject(:result) { date_mid_collection_year_formatted(input) }

    context "when called with nil" do
      let(:input) { nil }

      it "returns the current date" do
        today = Time.zone.today
        expect(result).to eq("#{today.day} #{today.month} #{today.year}")
      end
    end

    context "when called with a date after the first of April" do
      calendar_year = 2030
      let(:input) { Date.new(calendar_year, 7, 7) }

      it "returns the first of September from that year" do
        expect(result).to eq("1 9 #{calendar_year}")
      end
    end

    context "when called with a date before April" do
      calendar_year = 2040
      let(:input) { Date.new(calendar_year, 2, 7) }

      it "returns the first of September from the previous year" do
        expect(result).to eq("1 9 #{calendar_year - 1}")
      end
    end
  end

  describe "#currently_crossover_period?", focus: true do
    subject(:result) { currently_crossover_period? }

    around do |example|
      Timecop.freeze(now) do
        example.run
      end
    end

    context "when it is January" do
      let(:now) { Time.utc(2022, 1, 3) }

      it "returns false" do
        expect(result).to be false
      end
    end

    context "when it is December" do
      let(:now) { Time.utc(2020, 12, 3) }

      it "returns false" do
        expect(result).to be false
      end
    end

    context "when it is April" do
      let(:now) { Time.utc(2023, 4, 3) }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when it is June" do
      context "and it is the first Friday" do
        let(:now) { Time.utc(2024, 6, 7) }

        it "returns true" do
          expect(result).to be true
        end
      end

      context "and it is after the first Friday" do
        let(:now) { Time.utc(2024, 6, 8) }

        it "returns false" do
          expect(result).to be false
        end
      end

      context "and it is 2023, after the first Friday, but before the arbitrary crossover period end" do
        let(:now) { Time.utc(2023, 6, 7) }

        it "returns true" do
          expect(result).to be true
        end
      end
    end
  end
end
