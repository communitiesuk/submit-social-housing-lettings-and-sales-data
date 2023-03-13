require "rails_helper"

RSpec.describe Form::Lettings::Questions::PreviousTenure, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has the correct id" do
    expect(question.id).to eq("prevten")
  end

  it "has the correct header" do
    expect(question.header).to eq("Where was the household immediately before this letting?")
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Where was the household immediately before this letting?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("This is where the household was the night before they moved.")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "30" => { "value" => "Fixed-term local authority general needs tenancy" },
      "32" => { "value" => "Fixed-term private registered provider (PRP) general needs tenancy" },
      "31" => { "value" => "Lifetime local authority general needs tenancy" },
      "33" => { "value" => "Lifetime private registered provider (PRP) general needs tenancy" },
      "34" => { "value" => "Specialist retirement housing" },
      "35" => { "value" => "Extra care housing" },
      "6" => { "value" => "Other supported housing" },
      "3" => { "value" => "Private sector tenancy" },
      "27" => { "value" => "Owner occupation (low-cost home ownership)" },
      "26" => { "value" => "Owner occupation (private)" },
      "28" => { "value" => "Living with friends or family" },
      "14" => { "value" => "Bed and breakfast" },
      "7" => { "value" => "Direct access hostel" },
      "10" => { "value" => "Hospital" },
      "29" => { "value" => "Prison or approved probation hostel" },
      "19" => { "value" => "Rough sleeping" },
      "18" => { "value" => "Any other temporary accommodation" },
      "13" => { "value" => "Children’s home or foster care" },
      "24" => { "value" => "Home Office Asylum Support" },
      "23" => { "value" => "Mobile home or caravan" },
      "21" => { "value" => "Refuge" },
      "9" => { "value" => "Residential care home" },
      "4" => { "value" => "Tied housing or rented with job" },
      "36" => { "value" => "Sheltered housing for adults aged under 55 years" },
      "37" => { "value" => "Host family or similar refugee accommodation" },
      "25" => { "value" => "Any other accommodation" },
    })
  end
end
