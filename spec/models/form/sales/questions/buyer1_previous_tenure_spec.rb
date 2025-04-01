require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer1PreviousTenure, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }
  let(:log) { create(:sales_log) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("prevten")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Local authority tenant" },
      "2" => { "value" => "Private registered provider or housing association tenant" },
      "3" => { "value" => "Private tenant" },
      "4" => { "value" => "Tied home or renting with job" },
      "5" => { "value" => "Owner occupier" },
      "6" => { "value" => "Living with family or friends" },
      "7" => { "value" => "Temporary accommodation" },
      "9" => { "value" => "Other" },
      "divider" => { "value" => true },
      "0" => { "value" => "Don’t know" },
    })
  end
end
