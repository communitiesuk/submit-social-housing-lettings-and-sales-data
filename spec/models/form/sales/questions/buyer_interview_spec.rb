require "rails_helper"

RSpec.describe Form::Sales::Questions::BuyerInterview, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: false) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_2024_or_later?: true) }
  let(:subsection) { instance_double(Form::Subsection, form:, copy_key: "setup") }
  let(:page) { instance_double(Form::Page, subsection:) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("noint")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "2" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  context "when there are joint buyers" do
    subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: true) }

    let(:subsection) { instance_double(Form::Subsection, form:, copy_key: "subsection_copy_key") }

    it "has the expected copy_key" do
      expect(question.copy_key).to eq("sales.subsection_copy_key.noint.joint_purchase")
    end
  end

  context "when there is a single buyer" do
    subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: false) }

    let(:subsection) { instance_double(Form::Subsection, form:, copy_key: "subsection_copy_key") }

    it "has the expected copy_key" do
      expect(question.copy_key).to eq("sales.subsection_copy_key.noint.not_joint_purchase")
    end
  end
end
