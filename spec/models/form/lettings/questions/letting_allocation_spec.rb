require "rails_helper"

RSpec.describe Form::Lettings::Questions::LettingAllocation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_2024_or_later?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("letting_allocation")
  end

  it "has the correct type" do
    expect(question.type).to eq("checkbox")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "cbl" => { "value" => "Choice-based lettings (CBL)" },
        "cap" => { "value" => "Common Allocation Policy (CAP)" },
        "chr" => { "value" => "Common housing register (CHR)" },
        "divider" => { "value" => true },
        "letting_allocation_unknown" => { "value" => "None of these allocation systems" },
      })
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "cbl" => { "value" => "Choice-based lettings (CBL)", "hint" => "Where available vacant properties are advertised and applicants are able to bid for specific properties." },
        "cap" => { "value" => "Common Allocation Policy (CAP)", "hint" => "Where a common system agreed between a group of housing providers is used to determine applicant’s priority for housing." },
        "chr" => { "value" => "Common housing register (CHR)", "hint" => "Where a single waiting list is used by a group of housing providers to receive and process housing applications. Providers may use different approaches to determine priority." },
        "accessible_register" => { "value" => "Accessible housing register", "hint" => "Where the ‘access category’ or another descriptor of whether an available vacant property meets a range of access needs is displayed to applicants during the allocations process." },
        "divider" => { "value" => true },
        "letting_allocation_unknown" => { "value" => "None of these allocation systems" },
      })
    end
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end
end
