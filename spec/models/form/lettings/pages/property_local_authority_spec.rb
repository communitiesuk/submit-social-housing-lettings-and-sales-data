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

    context "with form before 2024" do
      before do
        allow(form).to receive(:start_year_2024_or_later?).and_return(false)
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

    context "with form after 2024" do
      before do
        allow(form).to receive(:start_year_2024_or_later?).and_return(true)
      end

      it "is routed to when la is not inferred, it is general needs log and address search has been given" do
        log.needstype = 1
        log.is_la_inferred = false
        log.address_line1_input = "1"
        log.postcode_full_input = "A11AA"
        expect(page).to be_routed_to(log, nil)
      end

      it "is not routed to when la is inferred" do
        log.needstype = 1
        log.is_la_inferred = true
        log.address_line1_input = "1"
        log.postcode_full_input = "A11AA"
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to when it's a supported housing log" do
        log.needstype = 2
        log.is_la_inferred = false
        log.address_line1_input = "1"
        log.postcode_full_input = "A11AA"
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to when address search is not given" do
        log.needstype = 1
        log.is_la_inferred = false
        log.address_line1_input = nil
        log.postcode_full_input = "A11AA"
        expect(page).not_to be_routed_to(log, nil)
      end
    end
  end
end
