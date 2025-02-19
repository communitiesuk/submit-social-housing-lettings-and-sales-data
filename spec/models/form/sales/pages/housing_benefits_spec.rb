require "rails_helper"

RSpec.describe Form::Sales::Pages::HousingBenefits, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:page_id) { "provided_id" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }
  let(:joint_purchase) { false }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[hb])
  end

  it "has the correct id" do
    expect(page.id).to eq(page_id)
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when joint_purchase is false" do
    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "not_joint_purchase?" => true }, { "jointpur" => nil }])
    end
  end

  context "when joint_purchase is true" do
    let(:joint_purchase) { true }

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "joint_purchase?" => true }])
    end
  end
end
