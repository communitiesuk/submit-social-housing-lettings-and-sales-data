require "rails_helper"

RSpec.describe TasklistHelper do
  describe "get subsection status" do
    let!(:case_log) { FactoryBot.create(:case_log) }
    @form = Form.new(2021, 2022)

    it "returns not started if none of the questions in the subsection are answered" do
      expect(get_subsection_status("income_and_benefits", case_log)).to eq("Not started")
    end

    it "returns cannot start yet if the subsection is declaration" do
      expect(get_subsection_status("declaration", case_log)).to eq("Cannot start yet")
    end

    it "returns in progress if some of the questions have been answered" do
      case_log["previous_postcode"] = "P0 5TT"
      expect(get_subsection_status("local_authority", case_log)).to eq("In progress")
    end

    it "returns completed if all the questions in the subsection have been answered" do
      %w(net_income net_income_frequency net_income_uc_proportion housing_benefit).each {|x| case_log[x] = "value" }
      expect(get_subsection_status("income_and_benefits", case_log)).to eq("Completed")
    end

    it "returns not started if the subsection is declaration and all the questions are completed" do
      completed_case_log = CaseLog.new(case_log.attributes.map { |key, value| Hash[key, value || "value"]  }.reduce(:merge))
      expect(get_subsection_status("declaration", completed_case_log)).to eq("Not started")
    end
  end
end
