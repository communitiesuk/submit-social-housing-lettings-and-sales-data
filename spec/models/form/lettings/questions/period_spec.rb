require "rails_helper"

RSpec.describe Form::Lettings::Questions::Period, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has the correct hint" do
    expect(question.hint_text).to eq("Select how often the household is charged. This may be different to how often they pay.")
  end
end
