require "rails_helper"

RSpec.describe Form::Lettings::Questions::Voiddate, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("voiddate")
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(23)
  end

  it "has the correct top_guidance_partial" do
    expect(question.top_guidance_partial).to eq("void_date")
  end

  it "has the correct type" do
    expect(question.type).to eq("date")
  end

  it "is not marked as derived" do
    expect(question).not_to be_derived(nil)
  end
end
