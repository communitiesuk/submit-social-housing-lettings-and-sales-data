require "rails_helper"

RSpec.describe OrganisationNameChange, type: :model do
  let(:organisation) { create(:organisation) }

  describe "validations" do
    it "is valid with valid attributes" do
      name_change = build(:organisation_name_change, organisation:)
      expect(name_change).to be_valid
    end

    it "is invalid without a name" do
      name_change = build(:organisation_name_change, organisation:, name: nil)
      expect(name_change).not_to be_valid
      expect(name_change.errors[:name]).to include("New name is required and cannot be left blank.")
    end

    it "is invalid without a startdate if not immediate" do
      name_change = build(:organisation_name_change, organisation:, startdate: nil, immediate_change: false)
      expect(name_change).not_to be_valid
      expect(name_change.errors[:startdate]).to include("Start date must be provided unless this is an immediate change.")
    end

    it "is invalid if startdate is not unique for the organisation" do
      create(:organisation_name_change, organisation:, startdate: Time.zone.tomorrow)
      name_change = build(:organisation_name_change, organisation:, immediate_change: false, startdate: Time.zone.tomorrow)
      expect(name_change).not_to be_valid
      expect(name_change.errors[:startdate]).to include("Start date cannot be the same as another name change.")
    end

    it "is invalid if name is the same as the current name on the change date" do
      create(:organisation_name_change, organisation:, name: "New Name", startdate: 1.day.ago)
      name_change = build(:organisation_name_change, organisation:, name: "New Name", startdate: Time.zone.now)
      expect(name_change).not_to be_valid
      expect(name_change.errors[:name]).to include("New name must be different from the current name on the change date.")
    end

    it "is invalid if startdate is after the organisation's merge date" do
      organisation.update!(merge_date: Time.zone.now)
      name_change = build(:organisation_name_change, organisation:, immediate_change: false, startdate: Time.zone.tomorrow)
      expect(name_change).not_to be_valid
      expect(name_change.errors[:startdate]).to include("Start date must be earlier than the organisation's merge date (#{organisation.merge_date.to_formatted_s(:govuk_date)}). You cannot make changes to the name of an organisation after it has merged.")
    end
  end

  describe "scopes" do
    let!(:visible_change) { create(:organisation_name_change, :future_change, organisation:) }
    let!(:discarded_change) { create(:organisation_name_change, organisation:, discarded_at: Time.zone.now) }

    it "returns only visible changes" do
      expect(described_class.visible).to include(visible_change)
      expect(described_class.visible).not_to include(discarded_change)
    end

    it "returns changes before a specific date" do
      name_change = create(:organisation_name_change, organisation:, startdate: 1.day.ago)
      expect(described_class.before_date(Time.zone.now)).to include(name_change)
    end

    it "returns changes after a specific date" do
      name_change = create(:organisation_name_change, organisation:, startdate: 2.days.from_now)
      expect(described_class.after_date(Time.zone.now)).to include(name_change)
    end
  end

  describe "#status" do
    it "returns 'scheduled' if the startdate is in the future" do
      name_change = build(:organisation_name_change, organisation:, startdate: 1.day.from_now)
      expect(name_change.status).to eq("scheduled")
    end

    it "returns 'active' if the startdate is today or in the past and end_date is nil or in the future" do
      name_change = build(:organisation_name_change, organisation:, startdate: 1.day.ago)
      expect(name_change.status).to eq("active")
    end

    it "returns 'inactive' if the end_date is in the past" do
      name_change = create(:organisation_name_change, organisation:, startdate: 2.days.ago)
      allow(name_change).to receive(:end_date).and_return(1.day.ago)
      expect(name_change.status).to eq("inactive")
    end
  end

  describe "#includes_date?" do
    it "returns true if the date is within the change period" do
      name_change = create(:organisation_name_change, organisation:, startdate: 1.day.ago)
      expect(name_change.includes_date?(Time.zone.now)).to be true
    end

    it "returns false if the date is outside the change period" do
      name_change = create(:organisation_name_change, organisation:, startdate: 2.days.ago)
      create(:organisation_name_change, organisation:, startdate: 1.day.from_now)
      expect(name_change.includes_date?(2.days.from_now)).to be false
    end
  end
end
