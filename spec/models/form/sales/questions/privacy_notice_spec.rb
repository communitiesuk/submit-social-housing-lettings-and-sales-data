require "rails_helper"

RSpec.describe Form::Sales::Questions::PrivacyNotice, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: false) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection, id: "setup", copy_key: "setup") }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("privacynotice")
  end

  it "has the correct type" do
    expect(question.type).to eq("checkbox")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "and there is a single buyer" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "privacynotice" => { "value" => "The buyer has seen or been given access to the MHCLG privacy notice" },
      })
    end

    it "uses the expected top guidance partial" do
      expect(question.top_guidance_partial).to eq("privacy_notice_buyer")
    end

    it "returns correct unanswered_error_message" do
      expect(question.unanswered_error_message).to eq("You must show or give the buyer access to the MHCLG privacy notice before you can submit this log.")
    end

    it "has the expected copy_key" do
      expect(question.copy_key).to eq("sales.setup.privacynotice.not_joint_purchase")
    end
  end

  context "and there are joint buyers" do
    subject(:question) { described_class.new(question_id, question_definition, page, joint_purchase: true) }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "privacynotice" => { "value" => "The buyers have seen or been given access to the MHCLG privacy notice" },
      })
    end

    it "uses the expected top guidance partial" do
      expect(question.top_guidance_partial).to eq("privacy_notice_buyer_joint_purchase")
    end

    it "returns correct unanswered_error_message" do
      expect(question.unanswered_error_message).to eq("You must show or give the buyers access to the MHCLG privacy notice before you can submit this log.")
    end

    it "has the expected copy_key" do
      expect(question.copy_key).to eq("sales.setup.privacynotice.joint_purchase")
    end
  end
end
