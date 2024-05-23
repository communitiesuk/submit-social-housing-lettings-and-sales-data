require "rails_helper"

RSpec.describe LocationPolicy do
  subject(:policy) { described_class }

  let(:data_provider) { FactoryBot.create(:user, :data_provider) }
  let(:data_coordinator) { FactoryBot.create(:user, :data_coordinator) }
  let(:support) { FactoryBot.create(:user, :support) }

  permissions :delete? do
    let(:location) { FactoryBot.create(:location) }

    context "with active location" do
      it "does not allow deleting a location as a provider" do
        expect(policy).not_to permit(data_provider, location)
      end

      it "does not allow allows deleting a location as a coordinator" do
        expect(policy).not_to permit(data_coordinator, location)
      end

      it "does not allow deleting a location as a support user" do
        expect(policy).not_to permit(support, location)
      end
    end

    context "with incomplete location" do
      before do
        location.update!(units: nil)
      end

      it "does not allow deleting a location as a provider" do
        expect(policy).not_to permit(data_provider, location)
      end

      it "does not allow allows deleting a location as a coordinator" do
        expect(policy).not_to permit(data_coordinator, location)
      end

      it "allows deleting a location as a support user" do
        expect(policy).to permit(support, location)
      end
    end

    context "with deactivated location" do
      before do
        location.location_deactivation_periods << create(:location_deactivation_period, deactivation_date: Time.zone.today, location:)
        location.save!
        log = build(:lettings_log, scheme: location.scheme, location:, startdate: Time.zone.today - 2.years)
        log.save!(validate: false)
      end

      context "and associated logs in editable collection period" do
        before do
          create(:lettings_log, scheme: location.scheme, location:)
        end

        it "does not allow deleting a location as a provider" do
          expect(policy).not_to permit(data_provider, location)
        end

        it "does not allow allows deleting a location as a coordinator" do
          expect(policy).not_to permit(data_coordinator, location)
        end

        it "does not allow deleting a location as a support user" do
          expect(policy).not_to permit(support, location)
        end
      end

      context "and no associated logs in editable collection period" do
        it "does not allow deleting a location as a provider" do
          expect(policy).not_to permit(data_provider, location)
        end

        it "does not allow allows deleting a location as a coordinator" do
          expect(policy).not_to permit(data_coordinator, location)
        end

        it "allows deleting a location as a support user" do
          expect(policy).to permit(support, location)
        end
      end
    end
  end
end
