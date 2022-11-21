require "rails_helper"

RSpec.describe Scheme, type: :model do
  describe "#new" do
    let(:scheme) { FactoryBot.create(:scheme) }

    it "belongs to an organisation" do
      expect(scheme.owning_organisation).to be_a(Organisation)
    end

    describe "paper trail" do
      let(:scheme) { FactoryBot.create(:scheme) }
      let!(:name) { scheme.service_name }

      it "creates a record of changes to a log" do
        expect { scheme.update!(service_name: "new test name") }.to change(scheme.versions, :count).by(1)
      end

      it "allows lettings logs to be restored to a previous version" do
        scheme.update!(service_name: "new test name")
        expect(scheme.paper_trail.previous_version.service_name).to eq(name)
      end
    end

    describe "scopes" do
      let!(:scheme_1) { FactoryBot.create(:scheme) }
      let!(:scheme_2) { FactoryBot.create(:scheme) }
      let!(:location) { FactoryBot.create(:location, :export, scheme: scheme_1) }
      let!(:location_2) { FactoryBot.create(:location, scheme: scheme_2, postcode: "NE4 6TR", name: "second location") }

      context "when filtering by id" do
        it "returns case insensitive matching records" do
          expect(described_class.filter_by_id(scheme_1.id.to_s).count).to eq(1)
          expect(described_class.filter_by_id(scheme_1.id.to_s).first.id).to eq(scheme_1.id)
          expect(described_class.filter_by_id(scheme_2.id.to_s).count).to eq(1)
          expect(described_class.filter_by_id(scheme_2.id.to_s).first.id).to eq(scheme_2.id)
        end
      end

      context "when searching by scheme name" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by_service_name(scheme_1.service_name.upcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_1.service_name.downcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_1.service_name.downcase).first.service_name).to eq(scheme_1.service_name)
          expect(described_class.search_by_service_name(scheme_2.service_name.upcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_2.service_name.downcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_2.service_name.downcase).first.service_name).to eq(scheme_2.service_name)
        end
      end

      context "when searching by postcode" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by_postcode(location.postcode.upcase).count).to eq(1)
          expect(described_class.search_by_postcode(location.postcode.downcase).count).to eq(1)
          expect(described_class.search_by_postcode(location.postcode.downcase).first.locations.first.postcode).to eq(location.postcode)
          expect(described_class.search_by_postcode(location_2.postcode.upcase).count).to eq(1)
          expect(described_class.search_by_postcode(location_2.postcode.downcase).count).to eq(1)
          expect(described_class.search_by_postcode(location_2.postcode.downcase).first.locations.first.postcode).to eq(location_2.postcode)
        end
      end

      context "when searching by location name" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by_location_name(location.name.upcase).count).to eq(1)
          expect(described_class.search_by_location_name(location.name.downcase).count).to eq(1)
          expect(described_class.search_by_location_name(location.name.downcase).first.locations.first.name).to eq(location.name)
          expect(described_class.search_by_location_name(location_2.name.upcase).count).to eq(1)
          expect(described_class.search_by_location_name(location_2.name.downcase).count).to eq(1)
          expect(described_class.search_by_location_name(location_2.name.downcase).first.locations.first.name).to eq(location_2.name)
        end
      end

      context "when searching by all searchable fields" do
        before do
          location_2.update!(postcode: location_2.postcode.gsub(scheme_1.id.to_s, "0"))
        end

        it "returns case insensitive matching records" do
          expect(described_class.search_by(scheme_1.id.to_s).count).to eq(1)
          expect(described_class.search_by(scheme_1.id.to_s).first.id).to eq(scheme_1.id)
          expect(described_class.search_by(scheme_2.service_name.upcase).count).to eq(1)
          expect(described_class.search_by(scheme_2.service_name.downcase).count).to eq(1)
          expect(described_class.search_by(scheme_2.service_name.downcase).first.service_name).to eq(scheme_2.service_name)
          expect(described_class.search_by(location.postcode.upcase).count).to eq(1)
          expect(described_class.search_by(location.postcode.downcase).count).to eq(1)
          expect(described_class.search_by(location.postcode.downcase).first.locations.first.postcode).to eq(location.postcode)
          expect(described_class.search_by(location.name.upcase).count).to eq(1)
          expect(described_class.search_by(location.name.downcase).count).to eq(1)
          expect(described_class.search_by(location.name.downcase).first.locations.first.name).to eq(location.name)
        end
      end
    end
  end

  describe "status" do
    let(:scheme) { FactoryBot.build(:scheme) }

    before do
      Timecop.freeze(2022, 6, 7)
    end

    after do
      Timecop.unfreeze
    end

    context "when there have not been any previous deactivations" do
      it "returns active if the scheme is not deactivated" do
        expect(scheme.status).to eq(:active)
      end

      it "returns deactivating soon if deactivation_date is in the future" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 8), scheme:)
        scheme.reload
        expect(scheme.status).to eq(:deactivating_soon)
      end

      it "returns deactivated if deactivation_date is in the past" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 6), scheme:)
        scheme.reload
        expect(scheme.status).to eq(:deactivated)
      end

      it "returns deactivated if deactivation_date is today" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), scheme:)
        scheme.reload
        expect(scheme.status).to eq(:deactivated)
      end
    end

    context "when there have been previous deactivations" do
      before do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 6, 5), scheme:)
      end

      it "returns active if the scheme has no relevant deactivation records" do
        expect(scheme.status).to eq(:active)
      end

      it "returns deactivating soon if deactivation_date is in the future" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 8), scheme:)
        scheme.reload
        expect(scheme.status).to eq(:deactivating_soon)
      end

      it "returns deactivated if deactivation_date is in the past" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 6), scheme:)
        scheme.reload
        expect(scheme.status).to eq(:deactivated)
      end

      it "returns deactivated if deactivation_date is today" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), scheme:)
        scheme.reload
        expect(scheme.status).to eq(:deactivated)
      end
    end
  end
end
