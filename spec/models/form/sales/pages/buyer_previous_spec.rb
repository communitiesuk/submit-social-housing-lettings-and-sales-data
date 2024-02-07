require "rails_helper"

RSpec.describe Form::Sales::Pages::BuyerPrevious, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:log) { create(:sales_log, :completed) }

  let(:page_id) { "example" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let(:joint_purchase) { false }

  before do
    allow(subsection).to receive(:depends_on).and_return(nil)
    allow(subsection).to receive(:enabled?).and_return(true)
    allow(subsection).to receive(:form).and_return(form)
    allow(form).to receive(:depends_on_met).and_return(true)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[soctenant])
  end

  it "has the correct id" do
    expect(page.id).to eq("example")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when sales is a joint purchase" do
    let(:joint_purchase) { true }

    it "has the correct depends on" do
      expect(page.depends_on).to eq([{ "joint_purchase?" => true }])
    end
  end

  context "when sales is not a joint purchase" do
    it "has the correct depends on" do
      expect(page.depends_on).to eq([{ "joint_purchase?" => false }])
    end
  end

  context "with 23/24 log" do
    before do
      Timecop.freeze(Time.zone.local(2023, 4, 2))
      Singleton.__init__(FormHandler)
    end

    after do
      Timecop.return
    end

    it "has correct routed to" do
      log.staircase = 1
      expect(page.routed_to?(log, nil)).to eq(true)
    end
  end

  context "with 24/25 log" do
    before do
      Timecop.freeze(Time.zone.local(2024, 4, 2))
      Singleton.__init__(FormHandler)
    end

    after do
      Timecop.return
    end

    it "has correct routed to when staircase is yes" do
      log.staircase = 1
      expect(page.routed_to?(log, nil)).to eq(false)
    end

    it "has correct routed to when staircase is nil" do
      log.staircase = nil
      expect(page.routed_to?(log, nil)).to eq(true)
    end

    it "has correct routed to when staircase is no" do
      log.staircase = 2
      expect(page.routed_to?(log, nil)).to eq(true)
    end

    it "has correct routed to when staircase is don't know" do
      log.staircase = 3
      expect(page.routed_to?(log, nil)).to eq(true)
    end
  end
end
