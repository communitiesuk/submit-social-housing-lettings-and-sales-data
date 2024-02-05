require "rails_helper"

RSpec.describe Form::Lettings::Questions::NationalityAll, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("nationality_all")
  end

  it "has the correct header" do
    expect(question.header).to eq("Enter a nationality")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Lead tenant’s nationality")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to be_nil
  end

  it "has the correct answer_options" do
    expect(question.answer_options.count).to eq(203)
  end
end
