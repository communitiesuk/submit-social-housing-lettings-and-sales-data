require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer2LivingIn, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[buy2living])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_2_living_in")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "buyer_two_will_live_in_property?" => true }])
  end
end
