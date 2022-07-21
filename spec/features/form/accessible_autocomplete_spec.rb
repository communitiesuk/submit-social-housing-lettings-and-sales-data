require "rails_helper"
require_relative "helpers"

RSpec.describe "Accessible Automcomplete" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      previous_la_known: 1,
      prevloc: "E09000033",
      illness: 1,
      is_la_inferred: false,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end

  before do
    sign_in user
  end

  context "when using accessible autocomplete" do
    before do
      visit("/logs/#{case_log.id}/accessible-select")
    end

    it "allows type ahead filtering", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
      expect(find("#case-log-prevloc-field").value).to eq("Thanet")
    end

    it "ignores punctuation", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("T", "h", "a", "'", "n", :down, :enter)
      expect(find("#case-log-prevloc-field").value).to eq("Thanet")
    end

    it "ignores stop words", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("t", "h", "e", " ", "W", "e", "s", "t", "m", :down, :enter)
      expect(find("#case-log-prevloc-field").value).to eq("Westminster")
    end

    it "does not perform an exact match", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("o", "n", "l", "y", " ", "t", "o", "w", "n", :down, :enter)
      expect(find("#case-log-prevloc-field").value).to eq("The one and only york town")
    end

    it "maintains enhancement state across back navigation", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
      click_button("Save and continue")
      click_link(text: "Back")
      expect(page).to have_selector("input", class: "autocomplete__input", count: 1)
    end

    it "has a disabled null option" do
      expect(page).to have_select("case-log-prevloc-field", disabled_options: ["Select an option"])
    end
  end

  context "when searching schemes" do
    let(:scheme) { FactoryBot.create(:scheme, owning_organisation_id: case_log.created_by.organisation_id, primary_client_group: "Q", secondary_client_group: "P") }

    before do
      FactoryBot.create(:location, scheme:, postcode: "W6 0ST")
      FactoryBot.create(:location, scheme:, postcode: "SE6 1LB")
      case_log.update!(needstype: 2)
      visit("/logs/#{case_log.id}/scheme")
    end

    it "can match on synonyms", js: true do
      find("#case-log-scheme-id-field").click.native.send_keys("w", "6", :down, :enter)
      expect(find("#case-log-scheme-id-field").value).to eq(scheme.service_name)
    end

    it "displays appended text next to the options", js: true do
      find("#case-log-scheme-id-field").click.native.send_keys("w", "6", :down, :enter)
      expect(find(".autocomplete__option__append", visible: :hidden, text: scheme.service_name)).to be_present
      expect(find("span", visible: :hidden, text: "2 locations")).to be_present
    end

    it "displays hint text under the options", js: true do
      find("#case-log-scheme-id-field").click.native.send_keys("w", "6", :down, :enter)
      expect(find(".autocomplete__option__hint", visible: :hidden, text: /Young people at risk, Young people leaving care/)).to be_present
    end
  end

  it "has the correct option selected if one has been saved" do
    case_log.update!(postcode_known: 0, previous_la_known: 1, prevloc: "E07000178")
    visit("/logs/#{case_log.id}/accessible-select")
    expect(page).to have_select("case-log-prevloc-field", selected: %w[Oxford])
  end
end
