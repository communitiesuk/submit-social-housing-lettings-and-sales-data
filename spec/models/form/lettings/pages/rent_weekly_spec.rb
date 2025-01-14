require "rails_helper"

RSpec.describe Form::Lettings::Pages::RentWeekly, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection) }

  let(:page_definition) { nil }
  let(:start_date) { Time.zone.local(2024, 4, 1) }
  let(:start_year_2025_or_later) { false }
  let(:form) { instance_double(Form, start_date:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:person_index) { 2 }

  before do
    allow(form).to receive(:start_year_2025_or_later?).and_return(start_year_2025_or_later)
  end

  context "with form before 2025" do
    let(:start_date) { Time.zone.local(2024, 4, 1) }
    let(:start_year_2025_or_later) { false }

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [
          { "rent_and_charges_paid_weekly?" => true, "household_charge" => 0, "is_carehome?" => false },
          { "rent_and_charges_paid_weekly?" => true, "household_charge" => nil, "is_carehome?" => false },
        ],
      )
    end
  end

  context "with form on or after 2025" do
    let(:start_date) { Time.zone.local(2025, 4, 1) }
    let(:start_year_2025_or_later) { true }

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [
          { "rent_and_charges_paid_weekly?" => true, "household_charge" => 0 },
          { "rent_and_charges_paid_weekly?" => true, "household_charge" => nil },
        ],
      )
    end
  end
end
