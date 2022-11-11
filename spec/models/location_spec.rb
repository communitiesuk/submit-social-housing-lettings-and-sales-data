require "rails_helper"

RSpec.describe Location, type: :model do
  describe "#new" do
    let(:location) { FactoryBot.build(:location) }

    before do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
    end

    it "belongs to an organisation" do
      expect(location.scheme).to be_a(Scheme)
    end

    it "infers the local authority" do
      location.postcode = "M1 1AE"
      location.save!
      expect(location.location_code).to eq("E08000003")
    end
  end

  describe "#validate_postcode" do
    let(:location) { FactoryBot.build(:location) }

    it "does not add an error if postcode is valid" do
      location.postcode = "M1 1AE"
      location.save!
      expect(location.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      location.postcode = "invalid"
      expect { location.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Postcode #{I18n.t('validations.postcode')}")
    end
  end

  describe "#units" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the number of units is invalid" do
      location.units = nil
      expect { location.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Units #{I18n.t('activerecord.errors.models.location.attributes.units.blank')}")
    end
  end

  describe "#type_of_unit" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the type of unit is invalid" do
      location.type_of_unit = nil
      expect { location.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Type of unit #{I18n.t('activerecord.errors.models.location.attributes.type_of_unit.blank')}")
    end
  end

  describe "paper trail" do
    let(:location) { FactoryBot.create(:location) }
    let!(:name) { location.name }

    it "creates a record of changes to a log" do
      expect { location.update!(name: "new test name") }.to change(location.versions, :count).by(1)
    end

    it "allows lettings logs to be restored to a previous version" do
      location.update!(name: "new test name")
      expect(location.paper_trail.previous_version.name).to eq(name)
    end
  end

  describe "scopes" do
    before do
      FactoryBot.create(:location, name: "ABC", postcode: "NW1 8RR", startdate: Time.zone.today)
      FactoryBot.create(:location, name: "XYZ", postcode: "SE1 6HJ", startdate: Time.zone.today + 1.day)
      FactoryBot.create(:location, name: "GHQ", postcode: "EW1 7JK", startdate: Time.zone.today - 1.day, confirmed: false)
      FactoryBot.create(:location, name: "GHQ", postcode: "EW1 7JK", startdate: nil)
    end

    context "when searching by name" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_name("abc").count).to eq(1)
        expect(described_class.search_by_name("AbC").count).to eq(1)
      end
    end

    context "when searching by postcode" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_postcode("se1 6hj").count).to eq(1)
        expect(described_class.search_by_postcode("SE1 6HJ").count).to eq(1)
      end
    end

    context "when searching by all searchable field" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by("aBc").count).to eq(1)
        expect(described_class.search_by("nw18rr").count).to eq(1)
      end
    end

    context "when filtering by started locations" do
      it "returns only locations that started today or earlier" do
        expect(described_class.started.count).to eq(3)
      end
    end

    context "when filtering by active locations" do
      it "returns only locations that started today or earlier and have been confirmed" do
        expect(described_class.active.count).to eq(2)
      end
    end
  end

  describe "status" do
    let(:location) { FactoryBot.build(:location, startdate: Time.zone.local(2022, 4, 1)) }

    before do
      Timecop.freeze(2022, 6, 7)
    end

    after do
      Timecop.unfreeze
    end

    context "when there have not been any previous deactivations" do
      it "returns active if the location has no deactivation records" do
        expect(location.status).to eq(:active)
      end

      it "returns deactivating soon if deactivation_date is in the future" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 8), location:)
        location.save!
        expect(location.status).to eq(:deactivating_soon)
      end

      it "returns deactivated if deactivation_date is in the past" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 6), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns deactivated if deactivation_date is today" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns reactivating soon if the location has a future reactivation date" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), reactivation_date: Time.zone.local(2022, 6, 8), location:)
        location.save!
        expect(location.status).to eq(:reactivating_soon)
      end

      it "returns activating soon if the location has a future startdate" do
        location.startdate = Time.zone.local(2022, 7, 7)
        location.save!
        expect(location.status).to eq(:activating_soon)
      end
    end

    context "when there have been previous deactivations" do
      before do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 4), reactivation_date: Time.zone.local(2022, 6, 5), location:)
        location.save!
      end

      it "returns active if the location has no relevant deactivation records" do
        expect(location.status).to eq(:active)
      end

      it "returns deactivating soon if deactivation_date is in the future" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 8), location:)
        location.save!
        expect(location.status).to eq(:deactivating_soon)
      end

      it "returns deactivated if deactivation_date is in the past" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 6), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns deactivated if deactivation_date is today" do
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), location:)
        location.save!
        expect(location.status).to eq(:deactivated)
      end

      it "returns reactivating soon if the location has a future reactivation date" do
        Timecop.freeze(2022, 6, 8)
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), reactivation_date: Time.zone.local(2022, 6, 9), location:)
        location.save!
        expect(location.status).to eq(:reactivating_soon)
      end

      it "returns reactivating soon if the location had a deactivation during another deactivation" do
        Timecop.freeze(2022, 6, 4)
        FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 2), location:)
        location.save!
        expect(location.status).to eq(:reactivating_soon)
      end

      it "returns activating soon if the location has a future startdate" do
        location.startdate = Time.zone.local(2022, 7, 7)
        location.save!
        expect(location.status).to eq(:activating_soon)
      end
    end
  end

  describe "available_from" do
    context "when there is a startdate" do
      let(:location) { FactoryBot.build(:location, startdate: Time.zone.local(2022, 4, 6)) }

      it "returns the startdate" do
        expect(location.available_from).to eq(Time.zone.local(2022, 4, 6))
      end
    end

    context "when there is no start date" do
      context "and the location was created at the start of the 2022/23 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2022, 4, 6), startdate: nil) }

        it "returns the beginning of 22/23 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2022, 4, 1))
        end
      end

      context "and the location was created at the end of the 2022/23 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2023, 2, 6), startdate: nil) }

        it "returns the beginning of 22/23 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2022, 4, 1))
        end
      end

      context "and the location was created at the start of the 2021/22 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2021, 4, 6), startdate: nil) }

        it "returns the beginning of 21/22 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2021, 4, 1))
        end
      end

      context "and the location was created at the end of the 2021/22 collection window" do
        let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2022, 2, 6), startdate: nil) }

        it "returns the beginning of 21/22 collection window" do
          expect(location.available_from).to eq(Time.zone.local(2021, 4, 1))
        end
      end
    end
  end
end
