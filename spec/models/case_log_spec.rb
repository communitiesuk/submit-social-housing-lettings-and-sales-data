require "rails_helper"

RSpec.describe Form, type: :model do
  describe "#new" do
    it "validates age is a number" do
      expect { CaseLog.create!(tenant_age: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is under 120" do
      expect { CaseLog.create!(tenant_age: 121) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is over 0" do
      expect { CaseLog.create!(tenant_age: 0) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates number of relets is a number" do
      expect { CaseLog.create!(property_number_of_times_relet: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates number of relets is under 20" do
      expect { CaseLog.create!(property_number_of_times_relet: 21) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates number of relets is over 0" do
      expect { CaseLog.create!(property_number_of_times_relet: 0) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    describe "reasonable preference validation" do
      it "if given reasonable preference is yes a reason must be selected" do
        expect { 
          CaseLog.create!(reasonable_preference: "Yes",
            reasonable_preference_reason_homeless: nil,
            reasonable_preference_reason_unsatisfactory_housing: nil,
            reasonable_preference_reason_medical_grounds: nil,
            reasonable_preference_reason_avoid_hardship: nil,
            reasonable_preference_reason_do_not_know: nil
          ) 
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "if not previously homesless reasonable preference should not be selected" do
        expect { 
          CaseLog.create!(
            homelessness: "No",
            reasonable_preference: "Yes"
          ) 
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "if not given reasonable preference a reason should not be selected" do
        expect { 
          CaseLog.create!(
            homelessness: "Yes",
            reasonable_preference: "No",
            reasonable_preference_reason_homeless: true
          ) 
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "status" do
    let!(:empty_case_log) { FactoryBot.create(:case_log) }
    let!(:in_progress_case_log) { FactoryBot.create(:case_log, :in_progress) }

    it "is set to not started for an empty case log" do
      expect(empty_case_log.not_started?).to be(true)
      expect(empty_case_log.in_progress?).to be(false)
      expect(empty_case_log.completed?).to be(false)
    end

    it "is set to not started for an empty case log" do
      expect(in_progress_case_log.in_progress?).to be(true)
      expect(in_progress_case_log.not_started?).to be(false)
      expect(in_progress_case_log.completed?).to be(false)
    end
  end
end
