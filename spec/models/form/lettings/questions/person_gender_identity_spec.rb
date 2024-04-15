require "rails_helper"

RSpec.describe Form::Lettings::Questions::PersonGenderIdentity, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "with form year before 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has the correct hint" do
      expect(question.hint_text).to eq("")
    end
  end

  context "with form year >= 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct hint" do
      expect(question.hint_text).to eq("This should be however they personally choose to identify from the options below. This may or may not be the same as their biological sex or the sex they were assigned at birth.")
    end
  end

  context "with person 2" do
    it "has the correct id" do
      expect(question.id).to eq("sex2")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 2’s gender identity")
    end

    it "has the correct header" do
      expect(question.header).to eq("Which of these best describes person 2’s gender identity?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("sex3")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 3’s gender identity")
    end

    it "has the correct header" do
      expect(question.header).to eq("Which of these best describes person 3’s gender identity?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end
end
