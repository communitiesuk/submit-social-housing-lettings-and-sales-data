require "rails_helper"

RSpec.describe Form::Sales::Pages::PropertyLocalAuthority, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:)) }
  let(:start_date) { Time.utc(2022, 4, 1) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  describe "has correct questions" do
    context "when 2022" do
      let(:start_date) { Time.utc(2022, 2, 8) }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(
          %w[
            la_known
            la
          ],
        )
      end
    end

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

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([{
      "is_la_inferred" => false,
    }])
  end

  describe "has correct routed_to?" do
    context "when start_date < 2023" do
      let(:log) { create(:sales_log, uprn_known: 1) }
      let(:start_date) { Time.utc(2022, 2, 8) }

      it "returns false" do
        expect(page.routed_to?(log)).to eq(true)
      end
    end

    context "when start_date >= 2023" do
      let(:log) { create(:sales_log, uprn_known: 1) }
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "returns true" do
        expect(page.routed_to?(log)).to eq(true)
      end
    end

    context "when start_date < 2023 and uprn_known: nil" do
      let(:log) { create(:sales_log, uprn_known: nil) }
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "returns true" do
        expect(page.routed_to?(log)).to eq(false)
      end
    end
  end
end
