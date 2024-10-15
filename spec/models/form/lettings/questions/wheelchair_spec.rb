require "rails_helper"

RSpec.describe Form::Lettings::Questions::Wheelchair, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(instance_double(Form, start_year_after_2024?: false, start_date: Time.zone.local(2023, 4, 1)))
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("wchair")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    })
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end
end
