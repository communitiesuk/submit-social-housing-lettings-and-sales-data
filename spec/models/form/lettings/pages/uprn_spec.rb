require "rails_helper"

RSpec.describe Form::Lettings::Pages::Uprn, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }

  before do
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
    expect(page.depends_on).to eq([{ "is_supported_housing?" => false }])
  end

  describe "has correct skip_href" do
    context "when log is nil" do
      it "is nil" do
        expect(page.skip_href).to be_nil
      end
    end

    context "when log is present" do
      let(:log) { build(:lettings_log) }

      context "with current form" do
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
