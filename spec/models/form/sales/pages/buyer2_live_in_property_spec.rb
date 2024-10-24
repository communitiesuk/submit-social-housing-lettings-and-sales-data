require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer2LiveInProperty, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[buy2livein])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_2_live_in_property")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "buyer_has_seen_privacy_notice?" => true,
        "outright_sale?" => false,
        "joint_purchase?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
        "outright_sale?" => false,
        "joint_purchase?" => true,
      },
      {
        "buyer_has_seen_privacy_notice?" => true,
        "joint_purchase?" => true,
        "buyers_will_live_in?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
        "joint_purchase?" => true,
        "buyers_will_live_in?" => true,
      },
    ])
  end
end
