require "rails_helper"

RSpec.describe TagHelper do
  let(:empty_lettings_log) { FactoryBot.create(:lettings_log) }
  let(:lettings_log) { FactoryBot.create(:lettings_log, :in_progress) }

  describe "get the status tag" do
    it "returns tag with correct status text and colour" do
      expect(status_tag(lettings_log.status)).to eq("<strong class=\"govuk-tag govuk-tag--blue\">In progress</strong>")
    end

    it "returns tag with correct status text and colour and custom class" do
      expect(status_tag("not_started", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Not started</strong>")
      expect(status_tag("cannot_start_yet", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Cannot start yet</strong>")
      expect(status_tag("in_progress", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--blue app-tag--small\">In progress</strong>")
      expect(status_tag("completed", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--green app-tag--small\">Completed</strong>")
      expect(status_tag("active", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--green app-tag--small\">Active</strong>")
      expect(status_tag("incomplete", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--red app-tag--small\">Incomplete</strong>")
      expect(status_tag("activating_soon", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--blue app-tag--small\">Activating soon</strong>")
      expect(status_tag("reactivating_soon", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--blue app-tag--small\">Reactivating soon</strong>")
      expect(status_tag("deactivating_soon", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--yellow app-tag--small\">Deactivating soon</strong>")
      expect(status_tag("deactivated", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Deactivated</strong>")
    end
  end
end
