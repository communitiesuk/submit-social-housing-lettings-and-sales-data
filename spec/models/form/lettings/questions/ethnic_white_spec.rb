require "rails_helper"

RSpec.describe Form::Lettings::Questions::EthnicWhite, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

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
    expect(question.id).to eq("ethnic")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which of the following best describes the lead tenant’s White background?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Lead tenant’s ethnic background")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
        "2" => { "value" => "Irish" },
        "18" => { "value" => "Gypsy or Irish Traveller" },
        "3" => { "value" => "Any other White background" },
      })
    end

    it "has the correct hint_text" do
      expect(question.hint_text).to eq("The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest.")
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
        "2" => { "value" => "Irish" },
        "18" => { "value" => "Gypsy or Irish Traveller" },
        "20" => { "value" => "Roma" },
        "3" => { "value" => "Any other White background" },
      })
    end

    it "has the correct hint_text" do
      expect(question.hint_text).to eq("")
    end
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end
end
