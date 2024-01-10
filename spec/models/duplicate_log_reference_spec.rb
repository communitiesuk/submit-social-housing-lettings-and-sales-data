require "rails_helper"

RSpec.describe DuplicateLogReference, type: :model do
  context "when adding a new duplicate log" do
    context "and duplicate_log_reference_id is not given" do
      let(:sales_log) { create(:sales_log) }

      it "generates a new random duplicate_log_reference_id" do
        duplicate_log = described_class.create!(log_id: sales_log.id, log_type: "SalesLog")
        expect(duplicate_log.duplicate_log_reference_id).to be_a(Integer)
      end
    end

    context "and duplicate_log_reference_id is given" do
      let(:sales_log) { create(:sales_log) }

      it "adds correct duplicate_log_reference_id" do
        duplicate_log = described_class.create!(log_id: sales_log.id, log_type: "SalesLog", duplicate_log_reference_id: 123_456)
        expect(duplicate_log.duplicate_log_reference_id).to eq(123_456)
      end
    end

    context "and log does not exist" do
      it "raises an error" do
        expect { described_class.create!(log_id: 1, log_type: "SalesLog") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "and log_type is invalid" do
      let(:sales_log) { create(:sales_log) }

      it "raises an error" do
        expect { described_class.create!(log_id: sales_log.id, log_type: "SomethingElse") }.to raise_error(NameError)
      end
    end
  end

  context "when accessing all duplicates for a sales log" do
    let(:sales_log) { create(:sales_log) }

    context "and there are no duplicates" do
      it "returns an empty array" do
        expect(sales_log.duplicates).to eq([])
      end
    end

    context "and there are duplicates" do
      let(:other_sales_log) { create(:sales_log) }

      before do
        duplicate_log = described_class.create!(log_id: sales_log.id, log_type: "SalesLog")
        described_class.create!(log_id: other_sales_log.id, log_type: "SalesLog", duplicate_log_reference_id: duplicate_log.duplicate_log_reference_id)
        create(:sales_log)
        create(:sales_log)
      end

      it "returns the correct duplicates" do
        expect(sales_log.duplicates.count).to eq(1)
        expect(sales_log.duplicates).to include(other_sales_log)
      end
    end
  end

  context "when accessing all duplicates for a lettings log" do
    let(:lettings_log) { create(:lettings_log) }

    context "and there are no duplicates" do
      it "returns an empty array" do
        expect(lettings_log.duplicates).to eq([])
      end
    end

    context "and there are duplicates" do
      let(:other_lettings_log) { create(:lettings_log) }

      before do
        duplicate_log = described_class.create!(log_id: lettings_log.id, log_type: "LettingsLog")
        described_class.create!(log_id: other_lettings_log.id, log_type: "LettingsLog", duplicate_log_reference_id: duplicate_log.duplicate_log_reference_id)
        create(:lettings_log)
        create(:lettings_log)
      end

      it "returns the correct duplicates" do
        expect(lettings_log.duplicates.count).to eq(1)
        expect(lettings_log.duplicates).to include(other_lettings_log)
      end
    end
  end
end
