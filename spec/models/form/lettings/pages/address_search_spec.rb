require "rails_helper"

RSpec.describe Form::Lettings::Pages::AddressSearch, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:)) }
  let(:start_date) { Time.utc(2024, 4, 1) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[uprn])
  end

  it "has the correct id" do
    expect(page.id).to eq("address_search")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "is_address_asked?" => true, "manual_address_entry_selected" => false }])
  end

  it "has the correct question number" do
    expect(page.question_number).to eq(12)
  end

  context "with 2025/26 form" do
    let(:start_date) { Time.utc(2025, 4, 1) }

    it "has the correct question number" do
      expect(page.question_number).to eq(16)
    end
  end

  context "when routing to the page" do
    let(:form) { FormHandler.instance.forms["current_lettings"] }
    let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true) }

    context "when the log is general needs" do
      let(:log) { build(:lettings_log, needstype: 1) }

      it "is routed to when the address is not being entered manually" do
        log.manual_address_entry_selected = false
        expect(page).to be_routed_to(log, nil)
      end

      it "is not routed to when the address is being entered manually" do
        log.manual_address_entry_selected = true
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to when `manual_address_entry_selected` is nil" do
        log.manual_address_entry_selected = nil
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when the log is supported housing" do
      let(:log) { build(:lettings_log, needstype: 2) }

      context "and the collection year is 2026 or later" do
        before do
          allow(form).to receive(:start_year_2026_or_later?).and_return(true)
        end

        it "is routed to when the address is not being entered manually" do
          log.manual_address_entry_selected = false
          expect(page).to be_routed_to(log, nil)
        end

        it "is not routed to when the address is being entered manually" do
          log.manual_address_entry_selected = true
          expect(page).not_to be_routed_to(log, nil)
        end

        it "is not routed to when `manual_address_entry_selected` is nil" do
          log.manual_address_entry_selected = nil
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "and the collection year is before 2026" do
        before do
          allow(form).to receive(:start_year_2026_or_later?).and_return(false)
        end

        it "is not routed to, even when the address is not being entered manually" do
          log.manual_address_entry_selected = false
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "when the scheme has confidential information" do
        let(:log) { build(:lettings_log, needstype: 2, scheme: build(:scheme, sensitive: 1)) }

        before do
          allow(form).to receive(:start_year_2026_or_later?).and_return(true)
        end

        it "is not routed to, even when the address is not being entered manually" do
          log.manual_address_entry_selected = false
          expect(page).not_to be_routed_to(log, nil)
        end
      end
    end
  end
end
