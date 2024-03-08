require "rails_helper"

RSpec.describe Form::Sales::Pages::LaNominations, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:log) { create(:sales_log, :completed) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  before do
    allow(subsection).to receive(:depends_on).and_return(nil)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[lanomagr])
  end

  it "has the correct id" do
    expect(page.id).to eq("la_nominations")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
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
