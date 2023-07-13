require "rails_helper"
require "rake"

RSpec.describe "data_cleanup" do
  describe ":remove_placeholder_deactivations", type: :task do
    subject(:task) { Rake::Task["data_cleanup:remove_placeholder_deactivations"] }

    before do
      Rake.application.rake_require("tasks/remove_placeholder_deactivations")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "with location model" do
        let(:locations) { create_list(:location, 3) }
        let!(:placeholder_location_deactivation) { create(:location_deactivation_period, deactivation_date: Time.zone.local(2031, 1, 1), location: locations[0]) }
        let!(:placeholder_location_deactivation_two) { create(:location_deactivation_period, deactivation_date: Time.zone.local(2031, 1, 1), location: locations[1]) }
        let!(:valid_location_deactivation) { create(:location_deactivation_period, deactivation_date: Time.zone.local(2030, 12, 31), location: locations[2]) }

        it "removes location_deactivation_period with date on or after 2031/01/01" do
          expect(Rails.logger).to receive(:info).with("Removed 2 location deactivation periods")
          expect { task.invoke("location") }.to change(LocationDeactivationPeriod, :count).by(-2)
          expect { placeholder_location_deactivation.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { placeholder_location_deactivation_two.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { valid_location_deactivation.reload }.not_to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with scheme model" do
        let(:schemes) { create_list(:scheme, 3) }
        let!(:placeholder_scheme_deactivation) { create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2031, 1, 1), scheme: schemes[0]) }
        let!(:placeholder_scheme_deactivation_two) { create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2031, 1, 1), scheme: schemes[1]) }
        let!(:valid_scheme_deactivation) { create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2030, 12, 31), scheme: schemes[2]) }

        it "removes scheme_deactivation_period with date on or after 2031/01/01" do
          expect(Rails.logger).to receive(:info).with("Removed 2 scheme deactivation periods")
          expect { task.invoke("scheme") }.to change(SchemeDeactivationPeriod, :count).by(-2)
          expect { placeholder_scheme_deactivation.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { placeholder_scheme_deactivation_two.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { valid_scheme_deactivation.reload }.not_to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it "raises an error when no model is given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_cleanup:remove_placeholder_deactivations['model_name']")
      end

      it "logs an error when wrong model is given" do
        expect { task.invoke("fake_model") }.to raise_error(RuntimeError, "Deactivations for fake_model cannot be deleted")
      end
    end
  end
end
