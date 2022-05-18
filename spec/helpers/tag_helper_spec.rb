require "rails_helper"

RSpec.describe TagHelper do
  let(:empty_case_log) { FactoryBot.create(:case_log) }
  let(:case_log) { FactoryBot.create(:case_log, :in_progress) }

  describe "get the status tag" do
    it "returns tag with correct status text and colour" do
      expect(status_tag(case_log.status)).to eq("<strong class=\"govuk-tag govuk-tag--blue\">In progress</strong>")
    end

    it "returns tag with correct status text and colour and custom class" do
      expect(status_tag("not_started", "app-tag--small")).to eq("<strong class=\"govuk-tag app-tag--small govuk-tag--grey\">Not started</strong>")
    end
  end
end
