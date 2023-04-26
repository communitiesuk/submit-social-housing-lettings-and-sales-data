require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer2Nationality, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to be subsection
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq %w[nationalbuy2]
  end

  it "has the correct id" do
    expect(page.id).to eq "buyer_2_nationality"
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq [
      {
        "joint_purchase?" => true,
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "joint_purchase?" => true,
        "buyer_not_interviewed?" => true,
      },
    ]
  end
end
