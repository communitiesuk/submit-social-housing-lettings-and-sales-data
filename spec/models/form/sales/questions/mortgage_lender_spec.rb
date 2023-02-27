require "rails_helper"

RSpec.describe Form::Sales::Questions::MortgageLender, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, question_number:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:question_number) { "Q1" }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mortgagelender")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q1 - What is the name of the mortgage lender?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Mortgage Lender")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "is has correct guidance_position" do
    expect(question.top_guidance?).to be false
    expect(question.bottom_guidance?).to be true
  end

  it "is has correct guidance_partial" do
    expect(question.guidance_partial).to eq("mortgage_lender")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "" => "Select an option",
      "1" =>	"Atom Bank",
      "2" =>	"Barclays Bank PLC",
      "3" =>	"Bath Building Society",
      "4" =>	"Buckinghamshire Building Society",
      "5" =>	"Cambridge Building Society",
      "6" =>	"Coventry Building Society",
      "7" =>	"Cumberland Building Society",
      "8" =>	"Darlington Building Society",
      "9" =>	"Dudley Building Society",
      "10" =>	"Ecology Building Society",
      "11" =>	"Halifax",
      "12" =>	"Hanley Economic Building Society",
      "13" =>	"Hinckley and Rugby Building Society",
      "14" =>	"Holmesdale Building Society",
      "15" =>	"Ipswich Building Society",
      "16" =>	"Leeds Building Society",
      "17" =>	"Lloyds Bank",
      "18" =>	"Mansfield Building Society",
      "19" =>	"Market Harborough Building Society",
      "20" =>	"Melton Mowbray Building Society",
      "21" =>	"Nationwide Building Society",
      "22" =>	"Natwest",
      "23" =>	"Nedbank Private Wealth",
      "24" =>	"Newbury Building Society",
      "25" =>	"OneSavings Bank",
      "26" =>	"Parity Trust",
      "27" =>	"Penrith Building Society",
      "28" =>	"Pepper Homeloans",
      "29" =>	"Royal Bank of Scotland",
      "30" =>	"Santander",
      "31" =>	"Skipton Building Society",
      "32" =>	"Teachers Building Society",
      "33" =>	"The Co-operative Bank",
      "34" =>	"Tipton & Coseley Building Society",
      "35" =>	"TSB",
      "36" =>	"Ulster Bank",
      "37" =>	"Virgin Money",
      "38" =>	"West Bromwich Building Society",
      "39" =>	"Yorkshire Building Society",
      "40" =>	"Other",
    })
  end
end
