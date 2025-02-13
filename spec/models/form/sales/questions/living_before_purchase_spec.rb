require "rails_helper"

RSpec.describe Form::Sales::Questions::LivingBeforePurchase, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1, joint_purchase: false) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("proplen_asked")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq("0" => { "value" => "Yes" },
                                          "1" => { "value" => "No" })
  end
end
