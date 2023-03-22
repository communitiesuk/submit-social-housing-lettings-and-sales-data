require "rails_helper"

RSpec.describe Form::Lettings::Pages::UprnKnown, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[uprn_known])
  end

  it "has the correct id" do
    expect(page.id).to eq("uprn_known")
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

  describe "has correct routed_to?" do
    context "when needstype != 2" do
      let(:log) { create(:lettings_log, needstype: nil) }

      it "returns true" do
        expect(page.routed_to?(log)).to eq(true)
      end
    end

    context "when needstype == 2" do
      let(:log) { create(:lettings_log, needstype: 2) }

      it "returns true" do
        expect(page.routed_to?(log)).to eq(false)
      end
    end
  end
end
