require "rails_helper"

RSpec.describe TagHelper do
  let(:empty_lettings_log) { FactoryBot.create(:lettings_log) }
  let(:lettings_log) { FactoryBot.create(:lettings_log, :in_progress) }

  describe "get the status tag" do
    it "returns tag with correct status text and colour" do
      expect(status_tag(lettings_log.status)).to eq("<strong class=\"govuk-tag govuk-tag--blue\">In progress</strong>")
    end

    context "when status is 'Not started'" do
      it "returns tag with correct status text and colour and custom class" do
        expect(status_tag("not_started", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Not started</strong>")
      end
    end

    context "when status is 'Cannot start yet'" do
      it "returns tag with correct status text and colour and custom class" do
        expect(status_tag("cannot_start_yet", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Cannot start yet</strong>")
      end
    end

    context "when status is 'Not started'" do
      it "returns tag with correct status text and colour and custom class" do
        code = "not_started"
        text = "Not started"
        colour = "grey"
        expect(status_tag(code, "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--#{colour} app-tag--small\">#{text}</strong>")
      end
    end

    context "when status is 'Cannot start yet'" do
      it "returns tag with correct status text and colour and custom class" do
        code = "cannot_start_yet"
        text = "Cannot start yet"
        colour = "grey"
        expect(status_tag(code, "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--#{colour} app-tag--small\">#{text}</strong>")
      end

      it "returns tag with correct status text and colour and custom class" do
        expect(status_tag("not_started", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Not started</strong>")
        expect(status_tag("cannot_start_yet", "app-tag--small")).to eq("<strong class=\"govuk-tag govuk-tag--grey app-tag--small\">Cannot start yet</strong>")
      end
    end
  end
end
