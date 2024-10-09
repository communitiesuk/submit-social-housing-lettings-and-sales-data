require "rails_helper"

RSpec.describe Form::Sales::Pages::PrivacyNotice, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: false) }

  let(:page_id) { "privacy_notice" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(subsection).to receive(:form).and_return(form)
    allow(form).to receive(:start_year_after_2024?)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[privacynotice])
  end

  it "has the correct id" do
    expect(page.id).to eq("privacy_notice")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when there are joint buyers" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: true) }

    it "has the expected copy_key" do
      expect(page.copy_key).to eq("sales.setup.privacynotice.joint_purchase")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "joint_purchase?" => true }])
    end
  end

  context "when there is a single buyer" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase: false) }

    it "has the expected copy_key" do
      expect(page.copy_key).to eq("sales.setup.privacynotice.not_joint_purchase")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "not_joint_purchase?" => true }, { "jointpur" => nil }])
    end
  end
end
