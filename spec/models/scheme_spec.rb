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
          expect(described_class.search_by("S#{scheme_1.id}").count).to eq(1)
          expect(described_class.search_by("s#{scheme_1.id}").count).to eq(1)
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

      context "when filtering by owning organisation" do
        let(:organisation_1) { create(:organisation) }
        let(:organisation_2) { create(:organisation) }
        let(:organisation_3) { create(:organisation) }

        before do
          create(:scheme, owning_organisation: organisation_1)
          create(:scheme, owning_organisation: organisation_1)
          create(:scheme, owning_organisation: organisation_2)
          create(:scheme, owning_organisation: organisation_2)
        end

        it "filters by given owning organisation" do
          expect(described_class.filter_by_owning_organisation([organisation_1]).count).to eq(2)
          expect(described_class.filter_by_owning_organisation([organisation_1, organisation_2]).count).to eq(4)
          expect(described_class.filter_by_owning_organisation([organisation_3]).count).to eq(0)
        end
      end

      context "when filtering by status" do
        let!(:incomplete_scheme) { FactoryBot.create(:scheme, :incomplete, service_name: "name") }
        let!(:incomplete_scheme_2) { FactoryBot.create(:scheme, :incomplete, service_name: "name") }
        let!(:incomplete_scheme_with_nil_confirmed) { FactoryBot.create(:scheme, :incomplete, service_name: "name", confirmed: nil) }
        let(:active_scheme) { FactoryBot.create(:scheme) }
        let(:active_scheme_2) { FactoryBot.create(:scheme) }
        let(:deactivating_soon_scheme) { FactoryBot.create(:scheme) }
        let(:deactivating_soon_scheme_2) { FactoryBot.create(:scheme) }
        let(:deactivated_scheme) { FactoryBot.create(:scheme) }
        let(:deactivated_scheme_2) { FactoryBot.create(:scheme) }
        let(:reactivating_soon_scheme) { FactoryBot.create(:scheme) }
        let(:reactivating_soon_scheme_2) { FactoryBot.create(:scheme) }
        let(:activating_soon_scheme) { FactoryBot.create(:scheme, startdate: Time.zone.today + 1.week)}

        before do
          scheme.destroy!
          scheme_1.destroy!
          scheme_2.destroy!
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.tomorrow, scheme: deactivating_soon_scheme)
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.tomorrow, scheme: deactivating_soon_scheme_2)
          deactivating_soon_scheme.save!
          deactivating_soon_scheme_2.save!
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.yesterday, scheme: deactivated_scheme)
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.yesterday, scheme: deactivated_scheme_2)
          deactivated_scheme.save!
          deactivated_scheme_2.save!
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.yesterday, reactivation_date: Time.zone.tomorrow, scheme: reactivating_soon_scheme)
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.yesterday, reactivation_date: Time.zone.tomorrow, scheme: reactivating_soon_scheme_2)
          reactivating_soon_scheme.save!
          reactivating_soon_scheme_2.save!
          FactoryBot.create(:location, scheme: active_scheme, confirmed: true)
          FactoryBot.create(:location, scheme: active_scheme_2, confirmed: true)
        end

        context "when filtering by incomplete status" do
          it "returns only incomplete schemes" do
            expect(described_class.filter_by_status(%w[incomplete]).count).to eq(3)
            expect(described_class.filter_by_status(%w[incomplete])).to include(incomplete_scheme)
            expect(described_class.filter_by_status(%w[incomplete])).to include(incomplete_scheme_2)
            expect(described_class.filter_by_status(%w[incomplete])).to include(incomplete_scheme_with_nil_confirmed)
          end
        end

        context "when filtering by incomplete status and searching" do
          it "returns only incomplete schemes" do
            expect(described_class.search_by("name").filter_by_status(%w[incomplete]).count).to eq(3)
            expect(described_class.search_by("name").filter_by_status(%w[incomplete])).to include(incomplete_scheme)
            expect(described_class.search_by("name").filter_by_status(%w[incomplete])).to include(incomplete_scheme_2)
            expect(described_class.search_by("name").filter_by_status(%w[incomplete])).to include(incomplete_scheme_with_nil_confirmed)
          end
        end

        context "when filtering by active status" do
          it "returns only active schemes" do
            expect(described_class.filter_by_status(%w[active]).count).to eq(2)
            expect(described_class.filter_by_status(%w[active])).to include(active_scheme)
            expect(described_class.filter_by_status(%w[active])).to include(active_scheme_2)
          end
        end

        context "when filtering by deactivating_soon status" do
          it "returns only deactivating_soon schemes" do
            expect(described_class.filter_by_status(%w[deactivating_soon]).count).to eq(2)
            expect(described_class.filter_by_status(%w[deactivating_soon])).to include(deactivating_soon_scheme)
            expect(described_class.filter_by_status(%w[deactivating_soon])).to include(deactivating_soon_scheme_2)
          end
        end

        context "when filtering by deactivated status" do
          it "returns only deactivated schemes" do
            expect(described_class.filter_by_status(%w[deactivated]).count).to eq(2)
            expect(described_class.filter_by_status(%w[deactivated])).to include(deactivated_scheme)
            expect(described_class.filter_by_status(%w[deactivated])).to include(deactivated_scheme_2)
          end
        end

        context "when filtering by reactivating_soon status" do
          it "returns only reactivating_soon schemes" do
            expect(described_class.filter_by_status(%w[reactivating_soon]).count).to eq(2)
            expect(described_class.filter_by_status(%w[reactivating_soon])).to include(reactivating_soon_scheme)
            expect(described_class.filter_by_status(%w[reactivating_soon])).to include(reactivating_soon_scheme_2)
          end
        end

        context "when filtering by multiple statuses" do
          it "returns relevant schemes" do
            expect(described_class.filter_by_status(%w[deactivating_soon reactivating_soon]).count).to eq(4)
            expect(described_class.filter_by_status(%w[deactivating_soon reactivating_soon])).to include(reactivating_soon_scheme)
            expect(described_class.filter_by_status(%w[deactivating_soon reactivating_soon])).to include(reactivating_soon_scheme_2)
            expect(described_class.filter_by_status(%w[deactivating_soon reactivating_soon])).to include(deactivating_soon_scheme)
            expect(described_class.filter_by_status(%w[deactivating_soon reactivating_soon])).to include(deactivating_soon_scheme_2)
          end
        end
      end
    end
  end

  describe "status" do
    let(:scheme) { FactoryBot.build(:scheme) }

    before do
      FactoryBot.create(:location, scheme:)
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

      it "returns reactivating soon if the scheme has a future reactivation date" do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), reactivation_date: Time.zone.local(2022, 6, 8), scheme:)
        scheme.save!
        expect(scheme.status).to eq(:reactivating_soon)
      end

      it "returns activating soon if the scheme has a future startdate" do
        Timecop.freeze(2022, 6, 4)
        scheme.startdate = Time.zone.local(2022, 7, 7)
        scheme.save!
        expect(scheme.status).to eq(:activating_soon)
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

      it "returns reactivating soon if the scheme has a future reactivation date" do
        Timecop.freeze(2022, 6, 8)
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 7), reactivation_date: Time.zone.local(2022, 6, 9), scheme:)
        scheme.save!
        expect(scheme.status).to eq(:reactivating_soon)
      end

      it "returns reactivating soon if the scheme had a deactivation during another deactivation" do
        Timecop.freeze(2022, 6, 4)
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 2), scheme:)
        scheme.save!
        expect(scheme.status).to eq(:reactivating_soon)
      end

      it "returns activating soon if the scheme has a future startdate" do
        scheme.startdate = Time.zone.local(2022, 7, 7)
        scheme.save!
        expect(scheme.status).to eq(:activating_soon)
      end
    end
  end

  describe "status_at" do
    let(:scheme) { FactoryBot.build(:scheme) }

    before do
      FactoryBot.create(:location, scheme:)
      Timecop.freeze(2022, 6, 7)
    end

    after do
      Timecop.unfreeze
    end

    context "when there have been previous deactivations" do
      before do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), reactivation_date: Time.zone.local(2022, 6, 5), scheme:)
      end

      it "returns active if the scheme has no relevant deactivation records" do
        expect(scheme.status_at(Time.zone.local(2022, 5, 5))).to eq(:active)
      end
    end
  end

  describe "available_from" do
    context "when the scheme was created at the start of the 2022/23 collection window" do
      let(:scheme) { FactoryBot.build(:scheme, created_at: Time.zone.local(2022, 4, 6)) }

      it "returns the beginning of 22/23 collection window" do
        expect(scheme.available_from).to eq(Time.zone.local(2021, 4, 1))
      end
    end

    context "when the scheme was created at the end of the 2022/23 collection window" do
      let(:scheme) { FactoryBot.build(:scheme, created_at: Time.zone.local(2023, 2, 6)) }

      it "returns the beginning of 22/23 collection window" do
        expect(scheme.available_from).to eq(Time.zone.local(2022, 4, 1))
      end
    end

    context "when the scheme was created at the start of the 2021/22 collection window" do
      let(:scheme) { FactoryBot.build(:scheme, created_at: Time.zone.local(2021, 4, 6)) }

      it "returns the beginning of 21/22 collection window" do
        expect(scheme.available_from).to eq(Time.zone.local(2020, 4, 1))
      end
    end

    context "when the scheme was created at the end of the 2021/22 collection window" do
      let(:scheme) { FactoryBot.build(:scheme, created_at: Time.zone.local(2022, 2, 6)) }

      it "returns the beginning of 21/22 collection window" do
        expect(scheme.available_from).to eq(Time.zone.local(2020, 4, 1))
      end
    end
  end

  describe "owning organisation" do
    let(:stock_owning_org) { FactoryBot.create(:organisation, holds_own_stock: true) }
    let(:non_stock_owning_org) { FactoryBot.create(:organisation, holds_own_stock: false) }
    let(:scheme) { FactoryBot.create(:scheme, owning_organisation_id: stock_owning_org.id) }

    context "when the owning organisation is set as a non-stock-owning organisation" do
      it "throws the correct validation error" do
        expect { scheme.update!({ owning_organisation: non_stock_owning_org }) }.to raise_error(ActiveRecord::RecordInvalid, /Enter an organisation that owns housing stock/)
      end
    end
  end
end
