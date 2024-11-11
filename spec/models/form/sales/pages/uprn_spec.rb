require "rails_helper"

RSpec.describe Form::Sales::Pages::Uprn, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_2024_or_later?).and_return(false)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[uprn_known uprn])
  end

  it "has the correct id" do
    expect(page.id).to eq("uprn")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to be_nil
  end

  describe "has correct skip_href" do
    context "when log is nil" do
      it "is nil" do
        expect(page.skip_href).to be_nil
      end
    end

    context "when log is present" do
      let(:log) { build(:sales_log) }

      context "with 2023/24 form" do
        it "points to address page" do
          expect(page.skip_href(log)).to eq(
            "address",
          )
        end

        it "has correct skip_text" do
          expect(page.skip_text).to eq("Enter address instead")
        end
      end

      context "with 2024/25 form" do
        before do
          allow(form).to receive(:start_year_2024_or_later?).and_return(true)
        end

        it "points to address search page" do
          expect(page.skip_href(log)).to eq(
            "address-matcher",
          )
        end

        it "has correct skip_text" do
          expect(page.skip_text).to eq("Search for address instead")
        end
      end
    end
  end
end
