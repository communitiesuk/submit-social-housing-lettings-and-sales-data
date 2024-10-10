require "rails_helper"

RSpec.describe Form::Lettings::Questions::NationalityAllGroup, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("nationality_all_group")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "826" => { "value" => "United Kingdom" },
      "12" => { "value" => "Other" },
      "0" => { "value" => "Tenant prefers not to say" },
    })
  end
end
