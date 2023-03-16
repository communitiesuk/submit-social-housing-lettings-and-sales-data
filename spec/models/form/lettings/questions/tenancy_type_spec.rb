require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyType, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancy")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the type of tenancy?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Type of main tenancy")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("")
  end

  it "has the correct conditional_for" do
    expect(question.conditional_for).to eq({ "tenancyother" => [3] })
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "4" => {
        "value" => "Assured Shorthold Tenancy (AST) – Fixed term",
        "hint" => "Mostly housing associations provide these. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
      },
      "6" => {
        "value" => "Secure – fixed term",
        "hint" => "Mostly local authorities provide these. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
      },
      "2" => {
        "value" => "Assured – lifetime",
      },
      "7" => {
        "value" => "Secure – lifetime",
      },
      "5" => {
        "value" => "Licence agreement",
        "hint" => "Licence agreements are mostly used for Supported Housing and work on a rolling basis.",
      },
      "3" => {
        "value" => "Other",
      },
    })
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end
