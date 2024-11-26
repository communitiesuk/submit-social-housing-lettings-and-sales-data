require "rails_helper"

RSpec.describe Form::Sales::Pages::BuyerInterview, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: false) }

  let(:page_id) { "buyer_interview" }
  let(:page_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_2024_or_later?: false) }
  let(:subsection) { instance_double(Form::Subsection, form:, id: "setup", copy_key: "subsection_copy_key") }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[noint])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_interview")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when there are joint buyers" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: true) }

    let(:subsection) { instance_double(Form::Subsection, form:, copy_key: "subsection_copy_key") }

    it "has the expected copy_key" do
      expect(page.copy_key).to eq("sales.subsection_copy_key.noint.joint_purchase")
    end
  end

  context "when there is a single buyer" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: false) }

    let(:subsection) { instance_double(Form::Subsection, form:, copy_key: "subsection_copy_key") }

    it "has the expected copy_key" do
      expect(page.copy_key).to eq("sales.subsection_copy_key.noint.not_joint_purchase")
    end
  end
end
