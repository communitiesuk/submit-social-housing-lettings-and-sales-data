require "rails_helper"

RSpec.describe TasklistHelper do
  describe "get subsection status" do
    @form = Form.new(2021, 2022)
    income_and_benefits_questions = @form.questions_for_subsection("income_and_benefits").keys
    declaration_questions = @form.questions_for_subsection("declaration").keys
    local_authority_questions = @form.questions_for_subsection("local_authority").keys
    let!(:case_log) { FactoryBot.create(:case_log) }

    it "returns not started if none of the questions in the subsection are answered" do
      status = get_subsection_status("income_and_benefits", case_log, income_and_benefits_questions)
      expect(status).to eq(:not_started)
    end

    it "returns cannot start yet if the subsection is declaration" do
      status = get_subsection_status("declaration", case_log, declaration_questions)
      expect(status).to eq(:cannot_start_yet)
    end

    it "returns in progress if some of the questions have been answered" do
      case_log["previous_postcode"] = "P0 5TT"
      status = get_subsection_status("local_authority", case_log, local_authority_questions)
      expect(status).to eq(:in_progress)
    end

    it "returns completed if all the questions in the subsection have been answered" do
      %w(net_income net_income_frequency net_income_uc_proportion housing_benefit).each {|x| case_log[x] = "value" }
      status = get_subsection_status("income_and_benefits", case_log, income_and_benefits_questions)
      expect(status).to eq(:completed)
    end

    it "returns not started if the subsection is declaration and all the questions are completed" do
      completed_case_log = CaseLog.new(case_log.attributes.map { |key, value| Hash[key, value || "value"]  }.reduce(:merge))
      status = get_subsection_status("declaration", completed_case_log, declaration_questions)
      expect(status).to eq(:not_started)
    end
  end

  describe "get next incomplete section" do
    let!(:case_log) { FactoryBot.create(:case_log) }

    it "returns the first subsection name if it is not completed" do
      @form = Form.new(2021, 2022)
      expect(get_next_incomplete_section(@form, case_log)).to eq("household_characteristics")
    end

    it "returns the first subsection name if it is partially completed" do
      @form = Form.new(2021, 2022)
      case_log["tenant_code"] = 123
      expect(get_next_incomplete_section(@form, case_log)).to eq("household_characteristics")
    end
  end
end
