require "rails_helper"

RSpec.describe Form::Lettings::Pages::Uprn, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[uprn_known uprn])
  end

  it "has the correct id" do
    expect(page.id).to eq("uprn")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to be_nil
  end

  it "has correct skip_text" do
    expect(page.skip_text).to eq("Enter address instead")
  end

  describe "has correct routed_to?" do
    context "when uprn_known == 1" do
      let(:log) { create(:lettings_log, uprn_known: 1) }

      it "returns true" do
        expect(page.routed_to?(log)).to eq(true)
      end
    end

    context "when needstype == 2" do
      let(:log) { create(:lettings_log, uprn_known: 1, needstype: 2) }

      it "returns true" do
        expect(page.routed_to?(log)).to eq(false)
      end
    end
  end

  describe "has correct skip_href" do
    context "when log is nil" do
      it "is nil" do
        expect(page.skip_href).to be_nil
      end
    end

    context "when log is present" do
      let(:log) { create(:lettings_log) }

      it "points to address page" do
        expect(page.skip_href(log)).to eq(
          "/lettings-logs/#{log.id}/address",
        )
      end
    end
  end
end
