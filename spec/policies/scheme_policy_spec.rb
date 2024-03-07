require "rails_helper"

RSpec.describe SchemePolicy do
  subject(:policy) { described_class }

  let(:data_provider) { create(:user, :data_provider) }
  let(:data_coordinator) { create(:user, :data_coordinator) }
  let(:support) { create(:user, :support) }

  permissions :delete? do
    let(:scheme) { create(:scheme) }

    before do
      create(:location, scheme:)
    end

    context "with active scheme" do
      it "does not allow deleting a scheme as a provider" do
        expect(policy).not_to permit(data_provider, scheme)
      end

      it "does not allow allows deleting a scheme as a coordinator" do
        expect(policy).not_to permit(data_coordinator, scheme)
      end

      it "does not allow deleting a scheme as a support user" do
        expect(policy).not_to permit(support, scheme)
      end
    end

    context "with incomplete scheme" do
      let(:scheme) { create(:scheme, :incomplete) }

      it "does not allow deleting a scheme as a provider" do
        expect(policy).not_to permit(data_provider, scheme)
      end

      it "does not allow allows deleting a scheme as a coordinator" do
        expect(policy).not_to permit(data_coordinator, scheme)
      end

      it "allows deleting a scheme as a support user" do
        expect(policy).to permit(support, scheme)
      end
    end

    context "with deactivated scheme" do
      before do
        scheme.scheme_deactivation_periods << create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2024, 4, 10), scheme:)
        scheme.save!
        Timecop.freeze(Time.utc(2024, 4, 10))
        log = create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, scheme:)
        log.startdate = Time.zone.local(2022, 10, 10)
        log.save!(validate: false)
      end

      after do
        Timecop.unfreeze
      end

      context "and associated logs in editable collection period" do
        before do
          create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, scheme:, startdate: Time.zone.local(2024, 4, 9))
        end

        it "does not allow deleting a scheme as a provider" do
          expect(policy).not_to permit(data_provider, scheme)
        end

        it "does not allow allows deleting a scheme as a coordinator" do
          expect(policy).not_to permit(data_coordinator, scheme)
        end

        it "does not allow deleting a scheme as a support user" do
          expect(policy).not_to permit(support, scheme)
        end
      end

      context "and no associated logs in editable collection period" do
        it "does not allow deleting a scheme as a provider" do
          expect(policy).not_to permit(data_provider, scheme)
        end

        it "does not allow allows deleting a scheme as a coordinator" do
          expect(policy).not_to permit(data_coordinator, scheme)
        end

        it "allows deleting a scheme as a support user" do
          expect(policy).to permit(support, scheme)
        end
      end
    end
  end
end