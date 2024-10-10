require "rails_helper"

RSpec.describe Form::Lettings::Questions::Nationality, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("national")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "18" => { "value" => "United Kingdom" },
      "17" => { "value" => "Republic of Ireland" },
      "19" => { "value" => "European Economic Area (EEA) country, excluding Ireland" },
      "20" => { "value" => "Afghanistan" },
      "21" => { "value" => "Ukraine" },
      "12" => { "value" => "Other" },
      "divider" => true,
      "13" => { "value" => "Tenant prefers not to say" },
    })
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end
end
