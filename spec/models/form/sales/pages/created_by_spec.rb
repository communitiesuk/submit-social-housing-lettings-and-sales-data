require "rails_helper"

RSpec.describe Form::Sales::Pages::CreatedBy, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let(:lettings_log) { instance_double(LettingsLog) }

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

  context "when the current user is a support user" do
    let(:support_user) { build(:user, :support) }

    it "is shown" do
      expect(page.routed_to?(lettings_log, support_user)).to be true
    end
  end

  context "when the current user is a data coordinator" do
    let(:support_user) { build(:user, :data_coordinator) }

    it "is shown" do
      expect(page.routed_to?(lettings_log, support_user)).to be true
    end
  end

  context "when the current user is a data provider" do
    let(:user) { build(:user) }

    it "is not shown" do
      expect(page.routed_to?(lettings_log, user)).to be false
    end
  end
end
