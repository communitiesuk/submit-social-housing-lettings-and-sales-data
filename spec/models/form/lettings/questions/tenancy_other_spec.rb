require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyOther, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(nil, nil, page) }

  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }
  let(:page) { instance_double(Form::Page, subsection:, id: "tenancy_type") }

  before do
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancyother")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct question number" do
    expect(question.question_number).to eq(27)
  end
end
