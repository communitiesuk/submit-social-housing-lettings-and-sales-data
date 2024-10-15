require "rails_helper"

RSpec.describe Form::Lettings::Questions::ReasonRenewal, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_after_2024?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("reason")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end

  it "has the correct conditional_for" do
    expect(question.conditional_for).to eq({ "reasonother" => [20] })
  end

  it "is not marked as derived" do
    expect(question).not_to be_derived(nil)
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "40" => { "value" => "End of assured shorthold tenancy (no fault)" },
        "42" => { "value" => "End of fixed term tenancy (no fault)" },
        "20" => { "value" => "Other" },
        "47" => { "value" => "Tenant prefers not to say" },
        "divider" => { "value" => true },
        "28" => { "value" => "Don’t know" },
      })
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "50" => { "value" => "End of social or private sector tenancy - no fault" },
        "51" => { "value" => "End of social or private sector tenancy - evicted due to anti-social behaviour (ASB)" },
        "52" => { "value" => "End of social or private sector tenancy - evicted due to rent arrears" },
        "53" => { "value" => "End of social or private sector tenancy - evicted for any other reason" },
        "20" => { "value" => "Other" },
        "47" => { "value" => "Tenant prefers not to say" },
        "divider" => { "value" => true },
        "28" => { "value" => "Don’t know" },
      })
    end
  end
end
