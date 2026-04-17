require "rails_helper"

RSpec.describe Form::Lettings::Pages::PropertyLocalAuthority, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { FormHandler.instance.forms["current_lettings"] }
  let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true) }

  before do
    allow(form).to receive(:start_date).and_return(Time.utc(2022, 4, 1))
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(
      %w[
        la
      ],
    )
  end

  it "has the correct id" do
    expect(page.id).to eq("property_local_authority")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when routing to the page" do
    let(:log) { build(:lettings_log) }

    before do
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "is routed to when la is not inferred and it is general needs log" do
      log.needstype = 1
      log.is_la_inferred = false
      expect(page).to be_routed_to(log, nil)
    end

    it "is not routed to when la is inferred" do
      log.needstype = 1
      log.is_la_inferred = true
      expect(page).not_to be_routed_to(log, nil)
    end

    it "is not routed to when it's a supported housing log" do
      log.needstype = 2
      log.is_la_inferred = false
      expect(page).not_to be_routed_to(log, nil)
    end
  end
end
