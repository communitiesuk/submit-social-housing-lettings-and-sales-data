require "rails_helper"

RSpec.describe Form::Sales::Questions::BuyerInterview, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: false) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_after_2024?: true) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form:)) }

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

    context "when the form start year is before 2024" do
      let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 3, 1), start_year_after_2024?: false) }

      it "has the expected copy_key" do
        expect(question.copy_key).to eq("sales.household_characteristics.noint.joint_purchase")
      end
    end

    context "when the form start year is after 2024" do
      let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_after_2024?: true) }

      it "has the expected copy_key" do
        expect(question.copy_key).to eq("sales.setup.noint.joint_purchase")
      end
    end
  end

  context "when there is a single buyer" do
    subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: false) }

    context "when the form start year is before 2024" do
      let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_after_2024?: false) }

      it "has the expected copy_key" do
        expect(question.copy_key).to eq("sales.household_characteristics.noint.not_joint_purchase")
      end
    end

    context "when the form start year is after 2024" do
      let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_after_2024?: true) }

      it "has the expected copy_key" do
        expect(question.copy_key).to eq("sales.setup.noint.not_joint_purchase")
      end
    end
  end
end
