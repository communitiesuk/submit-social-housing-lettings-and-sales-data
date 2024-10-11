require "rails_helper"

RSpec.describe Form::Sales::Pages::PropertyLocalAuthority, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { FormHandler.instance.forms["current_sales"] }
  let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true) }
  let(:start_date) { Time.utc(2022, 4, 1) }

  before do
    allow(form).to receive(:start_date).and_return(start_date)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  describe "has correct questions" do
    context "when 2023" do
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(
          %w[
            la
          ],
        )
      end
    end
  end

  it "has the correct id" do
    expect(page.id).to eq("property_local_authority")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when routing to the page" do
    let(:log) { build(:sales_log) }

    context "with form before 2024" do
      before do
        allow(form).to receive(:start_year_after_2024?).and_return(false)
      end

      it "is routed to when la is not inferred" do
        log.is_la_inferred = false
        expect(page).to be_routed_to(log, nil)
      end

      it "is not routed to when la is inferred" do
        log.is_la_inferred = true
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "with form after 2024" do
      before do
        allow(form).to receive(:start_year_after_2024?).and_return(true)
      end

      it "is routed to when la is not inferred and address search has been given" do
        log.is_la_inferred = false
        log.address_line1_input = "1"
        log.postcode_full_input = "A11AA"
        expect(page).to be_routed_to(log, nil)
      end

      it "is not routed to when la is inferred" do
        log.is_la_inferred = true
        log.address_line1_input = "1"
        log.postcode_full_input = "A11AA"
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to when address search is not given" do
        log.is_la_inferred = false
        log.address_line1_input = nil
        log.postcode_full_input = "A11AA"
        expect(page).not_to be_routed_to(log, nil)
      end
    end
  end
end
