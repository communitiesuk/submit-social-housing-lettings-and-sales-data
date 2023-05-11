require "rails_helper"

RSpec.describe LogPolicy do
  subject(:policy) { described_class }

  permissions :destroy? do
    let(:log) { create(:lettings_log, :setup_completed) }

    context "when collection period closed" do
      before do
        allow(log).to receive(:collection_period_open?).and_return(false)
      end

      it "does not allow deletion of log" do
        expect(log).to receive(:collection_period_open?)

        expect(policy).not_to permit(nil, log)
      end
    end

    context "when collection period open" do
      before do
        allow(log).to receive(:collection_period_open?).and_return(true)
      end

      context "when setup_completed false" do
        before do
          allow(log).to receive(:setup_completed?).and_return(false)
        end

        it "does not allow deletion of log" do
          expect(log).to receive(:setup_completed?)
          expect(log).to receive(:collection_period_open?)

          expect(policy).not_to permit(nil, log)
        end
      end

      context "when setup_completed true" do
        before do
          allow(log).to receive(:setup_completed?).and_return(true)
        end

        context "when user is data coordinator" do
          let(:user) { create(:user, :data_coordinator) }

          it "does allow deletion of log" do
            expect(log).to receive(:setup_completed?)
            expect(log).to receive(:collection_period_open?)

            expect(policy).to permit(user, log)
          end
        end

        context "when user is support" do
          let(:user) { create(:user, :support) }

          it "does allow deletion of log" do
            expect(log).to receive(:setup_completed?)
            expect(log).to receive(:collection_period_open?)

            expect(policy).to permit(user, log)
          end
        end

        context "when user is data provider" do
          let(:user) { create(:user) }

          it "does not allow deletion of log" do
            expect(log).to receive(:setup_completed?)
            expect(log).to receive(:collection_period_open?)

            expect(policy).not_to permit(user, log)
          end

          context "when the log is assigned to the user" do
            let(:log) { create(:lettings_log, :setup_completed, created_by: user) }

            it "does allow deletion of log" do
              expect(log).to receive(:setup_completed?)
              expect(log).to receive(:collection_period_open?)

              expect(policy).to permit(user, log)
            end
          end
        end
      end
    end
  end
end
