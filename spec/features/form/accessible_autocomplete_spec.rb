require "rails_helper"
require_relative "helpers"

RSpec.describe "Accessible Autocomplete" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      previous_la_known: 1,
      prevloc: "E09000033",
      is_la_inferred: false,
      assigned_to: user,
    )
  end

  before do
    allow(lettings_log.form).to receive(:new_logs_end_date).and_return(Time.zone.today + 1.day)
    sign_in user
  end

  context "when using accessible autocomplete" do
    before do
      visit("/lettings-logs/#{lettings_log.id}/previous-local-authority")
    end

    it "allows type ahead filtering", js: true do
      find("#lettings-log-prevloc-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
      expect(find("#lettings-log-prevloc-field").value).to eq("Thanet")
    end

    it "ignores punctuation", js: true do
      find("#lettings-log-prevloc-field").click.native.send_keys("T", "h", "a", "'", "n", :down, :enter)
      expect(find("#lettings-log-prevloc-field").value).to eq("Thanet")
    end

    it "ignores stop words", js: true do
      find("#lettings-log-prevloc-field").click.native.send_keys("t", "h", "e", " ", "W", "e", "s", "t", "m", :down, :enter)
      expect(find("#lettings-log-prevloc-field").value).to eq("Westmorland and Furness")
    end

    it "does not perform an exact match", js: true do
      find("#lettings-log-prevloc-field").click.native.send_keys("K", "i", "n", "g", "s", "t", "o", "n", " ", "T", "h", "a", "m", "e", "s", :down, :enter)
      expect(find("#lettings-log-prevloc-field").value).to eq("Kingston upon Thames")
    end

    it "maintains enhancement state across back navigation", js: true do
      find("#lettings-log-prevloc-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
      click_button("Save and continue")
      page.go_back
      expect(page).to have_selector("input", class: "autocomplete__input", count: 1)
    end

    it "displays the placeholder text", js: true do
      expect(find("#lettings-log-prevloc-field")["placeholder"]).to eq("Start typing to search")
    end

    context "and multiple schemes with same names", js: true do
      let(:lettings_log) { FactoryBot.create(:lettings_log, :sh, assigned_to: user) }
      let!(:schemes) { FactoryBot.create_list(:scheme, 2, owning_organisation_id: user.organisation_id, service_name: "Scheme", primary_client_group: "O", secondary_client_group: "O") }

      before do
        schemes.each do |scheme|
          FactoryBot.create(:location, scheme:)
        end

        visit("/lettings-logs/#{lettings_log.id}/scheme")
      end

      it "allows selecting any scheme" do
        find("#lettings-log-scheme-id-field").click.native.send_keys("s", "c", "h", :enter)
        expect(find("#lettings-log-scheme-id-field").value).to match(/Scheme/)
        click_button("Save and continue")
        first_selected_scheme_id = lettings_log.reload.scheme_id
        expect(schemes.map(&:id)).to include(first_selected_scheme_id)

        visit("/lettings-logs/#{lettings_log.id}/scheme")
        find("#lettings-log-scheme-id-field").click.native.send_keys("s", "c", "h", :down, :enter)
        expect(find("#lettings-log-scheme-id-field").value).to match(/Scheme/)
        click_button("Save and continue")

        second_selected_scheme_id = lettings_log.reload.scheme_id
        expect(schemes.map(&:id)).to include(lettings_log.reload.scheme_id)
        expect(first_selected_scheme_id).not_to eq(second_selected_scheme_id)
      end
    end
  end

  context "when searching schemes" do
    let(:scheme) { FactoryBot.create(:scheme, owning_organisation_id: lettings_log.assigned_to.organisation_id, primary_client_group: "Q", secondary_client_group: "P") }

    before do
      FactoryBot.create(:location, scheme:, postcode: "W6 0ST", startdate: Time.zone.local(2022, 1, 1))
      FactoryBot.create(:location, scheme:, postcode: "SE6 1LB", startdate: Time.zone.local(2022, 1, 1))
      FactoryBot.create(:location, scheme:, postcode: nil, startdate: Time.zone.local(2022, 1, 1), confirmed: false)
      lettings_log.update!(needstype: 2)
      visit("/lettings-logs/#{lettings_log.id}/scheme")
    end

    it "can match on synonyms", js: true do
      find("#lettings-log-scheme-id-field").click.native.send_keys("w", "6", :down, :enter)
      expect(find("#lettings-log-scheme-id-field").value).to include(scheme.service_name)
    end

    it "displays appended text next to the options", js: true do
      find("#lettings-log-scheme-id-field").click.native.send_keys("w", "6", :down, :enter)
      expect(find(".autocomplete__option", visible: :hidden, text: scheme.service_name)).to be_present
      expect(find("span", visible: :hidden, text: "2 completed locations, 1 incomplete location")).to be_present
    end

    it "displays hint text under the options", js: true do
      find("#lettings-log-scheme-id-field").click.native.send_keys("w", "6", :down, :enter)
      expect(find(".autocomplete__option__hint", visible: :hidden, text: /Young people at risk, Young people leaving care/)).to be_present
    end
  end

  it "has the correct option selected if one has been saved" do
    lettings_log.update!(postcode_known: 0, previous_la_known: 1, prevloc: "E07000178")
    visit("/lettings-logs/#{lettings_log.id}/previous-local-authority")
    expect(page).to have_select("lettings-log-prevloc-field", selected: %w[Oxford])
  end
end
