require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer2EthnicBackgroundWhite, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[ethnicbuy2])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_2_ethnic_background_white")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "ethnic_group2" => 0 }])
  end
end
