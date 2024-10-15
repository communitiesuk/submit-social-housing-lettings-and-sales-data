require "rails_helper"

RSpec.describe Form::Sales::Questions::DiscountedOwnershipType, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection:) }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:)) }
  let(:start_date) { Time.zone.today }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("type")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "8" => { "value" => "Right to Acquire (RTA)" },
      "14" => { "value" => "Preserved Right to Buy (PRTB)" },
      "27" => { "value" => "Voluntary Right to Buy (VRTB)" },
      "9" => { "value" => "Right to Buy (RTB)" },
      "29" => { "value" => "Rent to Buy - Full Ownership" },
      "21" => { "value" => "Social HomeBuy for outright purchase" },
      "22" => { "value" => "Any other equity loan scheme" },
    })
  end

  describe "partial guidance" do
    context "when the form is for 2023/24" do
      let(:start_date) { Time.zone.local(2023, 4, 8) }

      it "shows shows correct top_guidance_partial" do
        expect(question.top_guidance_partial).to eq("discounted_ownership_type_definitions")
      end

      it "is at the top" do
        expect(question.top_guidance?).to eq(true)
        expect(question.bottom_guidance?).to eq(false)
      end
    end

    context "when the form is for before 2023/24" do
      let(:start_date) { Time.zone.local(2022, 4, 8) }

      it "does not show a top_guidance_partial" do
        expect(question.top_guidance_partial).to eq(nil)
      end
    end
  end
end
