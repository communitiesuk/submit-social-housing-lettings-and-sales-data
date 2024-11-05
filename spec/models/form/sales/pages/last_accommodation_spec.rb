require "rails_helper"

RSpec.describe Form::Sales::Pages::LastAccommodation, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:log) { build(:sales_log, :completed) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:start_year_after_2024) { false }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_2024_or_later?: start_year_after_2024) }
  let(:subsection) { instance_double(Form::Subsection, form:, depends_on: nil) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[ppcodenk ppostcode_full])
  end

  it "has the correct id" do
    expect(page.id).to eq("last_accommodation")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to be_nil
  end

  it "is routed to" do
    log.ownershipsch = 2
    expect(page).to be_routed_to(log, nil)
  end

  context "with 2024 form" do
    let(:start_year_after_2024) { true }

    it "is routed to for 2024 non discounted sale logs" do
      log.update!(ownershipsch: 1)
      expect(page).to be_routed_to(log, nil)
    end

    it "is not routed to for 2024 discounted sale logs" do
      log.update!(ownershipsch: 2)
      expect(page).not_to be_routed_to(log, nil)
    end
  end
end
