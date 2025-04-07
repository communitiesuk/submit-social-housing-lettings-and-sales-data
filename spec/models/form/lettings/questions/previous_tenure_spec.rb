require "rails_helper"

RSpec.describe Form::Lettings::Questions::PreviousTenure, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_2025_or_later?: false) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form:)) }

  it "has the correct id" do
    expect(question.id).to eq("prevten")
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "with start year before 2025" do
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

  context "with 2025 logs" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1), start_year_2025_or_later?: true) }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "30" => { "value" => "Fixed-term local authority general needs tenancy" },
        "32" => { "value" => "Fixed-term private registered provider (PRP) general needs tenancy" },
        "31" => { "value" => "Lifetime local authority general needs tenancy" },
        "33" => { "value" => "Lifetime private registered provider (PRP) general needs tenancy" },
        "35" => { "value" => "Extra care housing" },
        "38" => { "value" => "Older people’s housing for tenants with low support needs" },
        "6" => { "value" => "Other supported housing" },
        "3" => { "value" => "Private sector tenancy" },
        "27" => { "value" => "Owner occupation (low-cost home ownership)" },
        "26" => { "value" => "Owner occupation (private)" },
        "28" => { "value" => "Living with friends or family (long-term)" },
        "39" => { "value" => "Sofa surfing (moving regularly between family or friends, no permanent bed)" },
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
        "37" => { "value" => "Host family or similar refugee accommodation" },
        "25" => { "value" => "Any other accommodation" },
      })
    end
  end
end
