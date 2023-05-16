require "rails_helper"

RSpec.describe SalesLogPolicy do
  subject(:policy) { described_class }

  permissions :destroy? do
    let(:log) { create(:sales_log, :in_progress) }

    context "when log nil" do
      before do
        allow(log).to receive(:collection_period_open?).and_return(false)
      end

      it "does not allow deletion of log" do
        expect(policy).not_to permit(build(:user, :support), nil)
      end
    end

    context "when user nil" do
      before do
        allow(log).to receive(:collection_period_open?).and_return(false)
      end

      it "does not allow deletion of log" do
        expect(policy).not_to permit(nil, build(:sales_log, :in_progress))
      end
    end

    context "when collection period closed" do
      before do
        allow(log).to receive(:collection_period_open?).and_return(false)
      end

      it "does not allow deletion of log" do
        expect(log).to receive(:collection_period_open?)

        expect(policy).not_to permit(build(:user, :support), log)
      end
    end

    context "when collection period open" do
      before do
        allow(log).to receive(:collection_period_open?).and_return(true)
      end

      context "when not started" do
        before do
          allow(log).to receive(:in_progress?).and_return(false)
          allow(log).to receive(:completed?).and_return(false)
        end

        it "does not allow deletion of log" do
          expect(log).to receive(:in_progress?)
          expect(log).to receive(:collection_period_open?)

          expect(policy).not_to permit(build(:user, :support), log)
        end
      end

      [
        %i[sales_log in_progress],
        %i[sales_log completed],
      ].each do |type, status|
        let(:log) { create(type, status) }
        context "when #{type} status: #{status}" do
          context "when user is data coordinator" do
            let(:user) { create(:user, :data_coordinator) }
            let(:user_of_owning_org) { create(:user, :data_coordinator, organisation: log.owning_organisation) }

            it "does not allow deletion of log" do
              expect(log).to receive(:collection_period_open?)

              expect(policy).not_to permit(user, log)
            end

            it "allows deletion of log" do
              expect(log).to receive(:collection_period_open?)

              expect(policy).to permit(user_of_owning_org, log)
            end
          end

          context "when user is support" do
            let(:user) { create(:user, :support) }

            it "does allow deletion of log" do
              expect(log).to receive(:collection_period_open?)

              expect(policy).to permit(user, log)
            end
          end

          context "when user is data provider" do
            let(:user) { create(:user) }

            it "does not allow deletion of log" do
              expect(log).to receive(:collection_period_open?)

              expect(policy).not_to permit(user, log)
            end

            context "when the log is assigned to the user" do
              let(:log) { create(:sales_log, :in_progress, created_by: user) }

              it "does allow deletion of log" do
                expect(policy).to permit(user, log)
              end
            end
          end
        end
      end
    end
  end
end
