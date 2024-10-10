require "rails_helper"

RSpec.describe Form::Lettings::Questions::Period, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct answer options" do
    expect(question.answer_options).to eq(
      {
        "2" => { "value" => "Every 2 weeks" },
        "3" => { "value" => "Every 4 weeks" },
        "4" => { "value" => "Every calendar month" },
        "9" => { "value" => "Weekly for 46 weeks" },
        "8" => { "value" => "Weekly for 47 weeks" },
        "7" => { "value" => "Weekly for 48 weeks" },
        "6" => { "value" => "Weekly for 49 weeks" },
        "5" => { "value" => "Weekly for 50 weeks" },
        "11" => { "value" => "Weekly for 51 weeks" },
        "1" => { "value" => "Weekly for 52 weeks" },
        "10" => { "value" => "Weekly for 53 weeks" },
      },
    )
  end

  context "when managing organisation has rent periods" do
    let(:managing_organisation) { create(:organisation) }
    let(:log) { create(:lettings_log, managing_organisation:) }

    before do
      create(:organisation_rent_period, organisation: managing_organisation, rent_period: 3)
    end

    it "has correct displayed answer options" do
      expect(question.displayed_answer_options(log, nil)).to eq(
        {
          "3" => { "value" => "Every 4 weeks" },
        },
      )
    end
  end
end
