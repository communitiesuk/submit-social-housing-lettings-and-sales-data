require "rails_helper"

RSpec.describe Form, type: :model do
  describe "#new" do
    it "validates age is a number" do
      expect { CaseLog.create!(person_1_age: "random") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is under 120" do
      expect { CaseLog.create!(person_1_age: 121) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "validates age is over 0" do
      expect { CaseLog.create!(person_1_age: 0) }.to raise_error(ActiveRecord::RecordInvalid)
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

    context "income ranges" do
      let!(:income_range) { FactoryBot.create(:income_range, :full_time) }

      it "validates net income maximum" do
        expect {
          CaseLog.create!(
            person_1_economic_status: "Full-time - 30 hours or more",
            net_income: 5000,
            net_income_frequency: "Weekly",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "validates net income minimum" do
        expect {
          CaseLog.create!(
            person_1_status: "Full-time - 30 hours or more",
            net_income: 1,
            net_income_frequency: "Weekly",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "reasonable preference validation" do
      it "if given reasonable preference is yes a reason must be selected" do
        expect {
          CaseLog.create!(reasonable_preference: "Yes",
                          reasonable_preference_reason_homeless: nil,
                          reasonable_preference_reason_unsatisfactory_housing: nil,
                          reasonable_preference_reason_medical_grounds: nil,
                          reasonable_preference_reason_avoid_hardship: nil,
                          reasonable_preference_reason_do_not_know: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "if not previously homeless reasonable preference should not be selected" do
        expect {
          CaseLog.create!(
            homelessness: "No",
            reasonable_preference: "Yes",
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "if not given reasonable preference a reason should not be selected" do
        expect {
          CaseLog.create!(
            homelessness: "Yes",
            reasonable_preference: "No",
            reasonable_preference_reason_homeless: true,
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    context "reason for leaving last settled home validation" do
      it "Reason for leaving must be don't know if reason for leaving settled home (Q9a) is don't know." do
        expect {
          CaseLog.create!(reason_for_leaving_last_settled_home: "Do not know",
                          benefit_cap_spare_room_subsidy: "Yes - benefit cap")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    context "other reason for leaving last settled home validation" do
      it "must be provided if main reason for leaving last settled home was given as other" do
        expect {
          CaseLog.create!(reason_for_leaving_last_settled_home: "Other",
                          other_reason_for_leaving_last_settled_home: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must not be provided if the main reason for leaving settled home is not other" do
        expect {
          CaseLog.create!(reason_for_leaving_last_settled_home: "Repossession",
                          other_reason_for_leaving_last_settled_home: "the other reason provided")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "armed forces injured validation" do
      it "must be answered if tenant was a regular or reserve in armed forces" do
        expect {
          CaseLog.create!(armed_forces: "Yes - a regular",
                          armed_forces_injured: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "must be answered if tenant was not a regular or reserve in armed forces" do
        expect {
          CaseLog.create!(armed_forces: "No",
                          armed_forces_injured: "Yes")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "tenant’s income is from Universal Credit, state pensions or benefits" do
      it "Cannot be All if person 1 works full time" do
        expect {
          CaseLog.create!(net_income_uc_proportion: "All", person_1_economic_status: "Full-time - 30 hours or more")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot be All if person 1 works part time" do
        expect {
          CaseLog.create!(net_income_uc_proportion: "All", person_1_economic_status: "Part-time - Less than 30 hours")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Cannot be 1 All if any of persons 2-4 are person 1's partner and work part or full time" do
        expect {
          CaseLog.create!(net_income_uc_proportion: "All", person_2_relationship: "Partner", person_2_economic_status: "Part-time - Less than 30 hours")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    context "fixed term tenancy length" do
      it "Must not be completed if Type of main tenancy is not responded with either Secure or Assured shorthold " do
        expect {
          CaseLog.create!(tenancy_type: "Other",
                          fixed_term_tenancy: 10)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Must be completed and between 2 and 99 if type of tenancy is Assured shorthold" do
        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Assured Shorthold Tenancy (AST)",
                          fixed_term_tenancy: 1)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Assured Shorthold Tenancy (AST)",
                          fixed_term_tenancy: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Assured Shorthold Tenancy (AST)",
                          fixed_term_tenancy: 2)
        }.not_to raise_error
      end

      it "Must be empty or between 2 and 99 if type of tenancy is Secure" do
        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Secure",
                          fixed_term_tenancy: 1)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Secure",
                          fixed_term_tenancy: 100)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Secure",
                          fixed_term_tenancy: nil)
        }.not_to raise_error

        expect {
          CaseLog.create!(tenancy_type: "Fixed term – Secure",
                          fixed_term_tenancy: 2)
        }.not_to raise_error
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

  describe "weekly_net_income" do
    let(:net_income) { 5000 }
    let(:case_log) { FactoryBot.build(:case_log, net_income: net_income) }

    it "returns input income if frequency is already weekly" do
      case_log.net_income_frequency = "Weekly"
      expect(case_log.weekly_net_income).to eq(net_income)
    end

    it "calculates the correct weekly income from monthly income" do
      case_log.net_income_frequency = "Monthly"
      expect(case_log.weekly_net_income).to eq(1154)
    end

    it "calculates the correct weekly income from yearly income" do
      case_log.net_income_frequency = "Yearly"
      expect(case_log.weekly_net_income).to eq(417)
    end
  end
end
