require "rails_helper"

RSpec.describe Form::Lettings::Pages::CreatedBy, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let(:lettings_log) { instance_double(LettingsLog) }

  describe "#routed_to?" do
    context "when nil" do
      it "is not shown" do
        expect(page.routed_to?(nil, nil)).to eq(false)
      end
    end

    context "when support" do
      it "is shown" do
        expect(page.routed_to?(nil, create(:user, :support))).to eq(true)
      end
    end

    context "when not support" do
      it "is not shown" do
        expect(page.routed_to?(nil, create(:user, :data_coordinator))).to eq(false)
      end
    end
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[created_by_id])
  end

  it "has the correct id" do
    expect(page.id).to eq("created_by")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to be nil
  end
end
