require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer1PreviousTenure, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[prevten])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer1_previous_tenure")
  end
end
