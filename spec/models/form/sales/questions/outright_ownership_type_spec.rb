require "rails_helper"

RSpec.describe Form::Sales::Questions::OutrightOwnershipType, type: :model do
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
      "10" => { "value" => "Outright" },
      "12" => { "value" => "Other sale" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "othtype" => [12],
    })
  end

  describe "partial guidance" do
    context "when the form is for year 2023/24" do
      let(:start_date) { Time.zone.local(2023, 4, 8) }

      it "has the correct top_guidance_partial" do
        expect(question.top_guidance_partial).to eq("outright_sale_type_definitions")
      end

      it "has the correct bottom_guidance_partial" do
        expect(question.bottom_guidance_partial).to be_nil
      end

      it "is at the top" do
        expect(question.top_guidance?).to eq(true)
        expect(question.bottom_guidance?).to eq(false)
      end
    end

    context "when the form is for before year 2023/24" do
      let(:start_date) { Time.zone.local(2022, 4, 8) }

      it "does not display a top guidance partial" do
        expect(question.top_guidance_partial).to eq(nil)
      end

      it "does not display a bottom guidance partial" do
        expect(question.bottom_guidance_partial).to eq(nil)
      end
    end
  end
end
