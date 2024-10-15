require "rails_helper"

RSpec.describe Form::Sales::Questions::BuyersOrganisations, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("buyers_organisations")
  end

  it "has the correct type" do
    expect(question.type).to eq("checkbox")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq(
      {
        "pregyrha" => { "value" => "Their private registered provider (PRP) - housing association" },
        "pregother" => { "value" => "Other private registered provider (PRP) - housing association" },
        "pregla" => { "value" => "Local Authority" },
        "pregghb" => { "value" => "Help to Buy Agent" },
        "pregblank" => { "value" => "None of the above" },
      },
    )
  end

  it "has the correct displayed answer_options" do
    expect(question.displayed_answer_options(FactoryBot.build(:sales_log))).to eq(
      {
        "pregyrha" => { "value" => "Their private registered provider (PRP) - housing association" },
        "pregother" => { "value" => "Other private registered provider (PRP) - housing association" },
        "pregla" => { "value" => "Local Authority" },
        "pregghb" => { "value" => "Help to Buy Agent" },
      },
    )
  end
end
