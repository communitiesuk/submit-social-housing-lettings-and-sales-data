require "rails_helper"

RSpec.describe Form::Lettings::Questions::Sheltered, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_after_2024?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq page
  end

  it "has the correct id" do
    expect(question.id).to eq "sheltered"
  end

  it "has the correct header" do
    expect(question.header).to eq "Is this letting in sheltered accommodation?"
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq "Is this letting in sheltered accommodation?"
  end

  it "has the correct type" do
    expect(question.type).to eq "radio"
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq "Sheltered housing and special retirement housing are for tenants with low-level care and support needs. This typically provides some limited support to enable independent living, such as alarm-based assistance or a scheme manager.</br></br>Extra care housing is for tenants with medium to high care and support needs, often with 24 hour access to support staff provided by an agency registered with the Care Quality Commission."
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "2" => { "value" => "Yes – extra care housing" },
        "1" => { "value" => "Yes – specialist retirement housing" },
        "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
        "3" => { "value" => "No" },
        "divider" => { "value" => true },
        "4" => { "value" => "Don’t know" },
      })
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Yes – specialist retirement housing" },
        "2" => { "value" => "Yes – extra care housing" },
        "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
        "6" => { "value" => "Yes – sheltered housing for adults aged 55 years and over who are not retired" },
        "3" => { "value" => "No" },
        "divider" => { "value" => true },
        "4" => { "value" => "Don’t know" },
      })
    end
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end
