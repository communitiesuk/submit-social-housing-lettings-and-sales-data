require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyLengthIntermediateRent, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  before do
    allow(form).to receive(:start_year_after_2024?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancylength")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the length of the fixed-term tenancy to the nearest year?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Length of fixed-term tenancy")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("Do not include the starter or introductory period.</br>The minimum period is 1 year for intermediate rent general needs logs and you do not need a log for shorter tenancies.")
  end

  context "with collection year on or after 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct hint_text" do
      expect(question.hint_text).to eq("Do not include the starter or introductory period.</br>The minimum period is 1 year for intermediate rent general needs logs. You do not need to submit CORE logs for these types of tenancies if they are shorter than 1 year.")
    end
  end
end
