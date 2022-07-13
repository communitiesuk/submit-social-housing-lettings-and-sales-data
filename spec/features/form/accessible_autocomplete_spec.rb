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
    )
  end

  before do
    sign_in user
  end

  context "when using accessible autocomplete" do
    before do
      allow_any_instance_of(Form::Question).to receive(:answer_option_synonyms).and_call_original
      allow_any_instance_of(Form::Question).to receive(:answer_option_synonyms).with("E08000003").and_return("synonym")
      allow_any_instance_of(Form::Question).to receive(:answer_option_append).and_call_original
      allow_any_instance_of(Form::Question).to receive(:answer_option_append).with("E08000003").and_return(" (append)")
      allow_any_instance_of(Form::Question).to receive(:answer_option_hint).and_call_original
      allow_any_instance_of(Form::Question).to receive(:answer_option_hint).with("E08000003").and_return("hint")
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

    it "can match on synonyms", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("s", "y", "n", "o", "n", :down, :enter)
      expect(find("#case-log-prevloc-field").value).to eq("Manchester")
    end

    it "displays appended text next to the options", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("m", "a", "n", :down, :enter)
      expect(find(".autocomplete__option__append", visible: :hidden, text: /(append)/)).to be_present
    end

    it "displays hint text under the options", js: true do
      find("#case-log-prevloc-field").click.native.send_keys("m", "a", "n", :down, :enter)
      expect(find(".autocomplete__option__hint", visible: :hidden, text: /hint/)).to be_present
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

  it "has the correct option selected if one has been saved" do
    case_log.update!(postcode_known: 0, previous_la_known: 1, prevloc: "Oxford")
    visit("/logs/#{case_log.id}/accessible-select")
    expect(page).to have_select("case-log-prevloc-field", selected: %w[Oxford])
  end
end
