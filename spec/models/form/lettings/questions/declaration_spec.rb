require "rails_helper"

RSpec.describe Form::Lettings::Questions::Declaration, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_after_2024?)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("declaration")
  end

  it "has the correct header" do
    expect(question.header).to eq("Declaration")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Tenant has seen the privacy notice")
  end

  it "has the correct type" do
    expect(question.type).to eq("checkbox")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  context "when the form year is before 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "declaration" => { "value" => "The tenant has seen the MHCLG privacy notice." },
      })
    end

    it "uses the expected top guidance partial" do
      expect(question.top_guidance_partial).to eq("privacy_notice_tenant")
    end

    it "has check_answers_card_number = 0" do
      expect(question.check_answers_card_number).to eq(0)
    end

    it "returns correct unanswered_error_message" do
      expect(question.unanswered_error_message).to eq("You must show the MHCLG privacy notice to the tenant before you can submit this log.")
    end
  end

  context "when the form year is >= 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "declaration" => { "value" => "The tenant has seen or been given access to the MHCLG privacy notice" },
      })
    end

    it "uses the expected top guidance partial" do
      expect(question.top_guidance_partial).to eq("privacy_notice_tenant_2024")
    end

    it "has check_answers_card_number nil" do
      expect(question.check_answers_card_number).to be_nil
    end

    it "returns correct unanswered_error_message" do
      expect(question.unanswered_error_message).to eq("You must show or give the tenant access to the MHCLG privacy notice before you can submit this log.")
    end
  end
end
