require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Saving Data" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { lettings_log.id }
  let(:lettings_log_with_checkbox_questions_answered) do
    FactoryBot.create(
      :lettings_log, :in_progress,
      housingneeds_a: 1,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation
    )
  end
  let(:question_answers) do
    {
      tenancycode: { type: "text", answer: "BZ737", path: "tenant-code-test" },
      age1: { type: "numeric", answer: 25, path: "person_1_age" },
      sex1: { type: "radio", answer: { "F" => "Female" }, path: "person_1_gender" },
    }
  end

  before do
    sign_in user
  end

  it "updates model attributes correctly for each question" do
    question_answers.each do |question, hsh|
      type = hsh[:type]
      answer = hsh[:answer].respond_to?(:keys) ? hsh[:answer].keys.first : hsh[:answer]
      path = hsh[:path]
      original_value = lettings_log.send(question)
      visit("/lettings-logs/#{id}/#{path.to_s.dasherize}")
      case type
      when "text"
        fill_in("lettings-log-#{question.to_s.dasherize}-field", with: answer)
      when "radio"
        choose("lettings-log-#{question.to_s.dasherize}-#{hsh[:answer].keys.first.downcase}-field")
      else
        fill_in("lettings-log-#{question.to_s.dasherize}-field", with: answer)
      end
      expect { click_button("Save and continue") }.to change {
        lettings_log.reload.send(question.to_s)
      }.from(original_value).to(answer)
    end
  end

  it "updates total value of the rent", js: true do
    visit("/lettings-logs/#{id}/rent")

    fill_in("lettings-log-brent-field", with: 3.02)
    expect(page.find("#lettings-log-tcharge-field")).to have_content("3.02")

    fill_in("lettings-log-scharge-field", with: 2.8)
    expect(page.find("#lettings-log-tcharge-field")).to have_content("5.82")

    fill_in("lettings-log-pscharge-field", with: 1)
    expect(page.find("#lettings-log-tcharge-field")).to have_content("6.82")

    fill_in("lettings-log-supcharg-field", with: 4.11)
    expect(page.find("#lettings-log-tcharge-field")).to have_content("10.93")
  end

  it "displays number answers in inputs if they are already saved" do
    visit("/lettings-logs/#{id}/property-postcode")
    expect(page).to have_field("lettings-log-postcode-full-field", with: lettings_log.postcode_full)
  end

  it "displays text answers in inputs if they are already saved" do
    visit("/lettings-logs/#{id}/person-1-age")
    expect(page).to have_field("lettings-log-age1-field", with: "17")
  end

  it "displays checkbox answers in inputs if they are already saved" do
    visit("/lettings-logs/#{lettings_log_with_checkbox_questions_answered.id.to_s.dasherize}/accessibility-requirements")
    expect(page).to have_checked_field(
      "lettings-log-accessibility-requirements-housingneeds-a-field",
      visible: :all,
    )
    expect(page).to have_unchecked_field(
      "lettings-log-accessibility-requirements-housingneeds-b-field",
      visible: :all,
    )
  end
end
