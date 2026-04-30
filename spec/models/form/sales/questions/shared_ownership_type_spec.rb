require "rails_helper"

RSpec.describe Form::Sales::Questions::SharedOwnershipType, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_date) { current_collection_start_date }
  let(:form) { instance_double(Form, start_date:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:page) { instance_double(Form::Page, subsection:) }

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

  it "shows shows correct top_guidance_partial" do
    expect(question.top_guidance_partial).to eq("shared_ownership_type_definitions")
  end
end
