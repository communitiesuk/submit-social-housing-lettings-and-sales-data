require "rails_helper"

RSpec.describe Form::Lettings::Questions::FirstTimePropertyLetAsSocialHousing, type: :model do
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
    expect(question.id).to eq("first_time_property_let_as_social_housing")
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Yes", "hint" => "This is a new let." },
        "0" => { "value" => "No", "hint" => "This is a re-let of existing social housing." },
      })
    end
  end

  context "with 2024/25 form" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }

    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Yes", "hint" => "This property was previously used for other purposes or is a new-build." },
        "0" => { "value" => "No", "hint" => "This is a re-let of existing social housing stock." },
      })
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(15)
    end
  end

  context "with 2025/26 form" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1)) }

    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(12)
    end
  end
end
