require "rails_helper"

RSpec.describe Form::Setup::Pages::CreatedBy, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let(:case_log) { instance_double(CaseLog) }

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
    expect(page.header).to eq("")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to be nil
  end

  context "when the current user is a support user" do
    let(:support_user) { FactoryBot.build(:user, :support) }

    it "is shown" do
      expect(page.routed_to?(case_log, support_user)).to be true
    end
  end

  context "when the current user is not a support user" do
    let(:user) { FactoryBot.build(:user) }

    it "is not shown" do
      expect(page.routed_to?(case_log, user)).to be false
    end
  end
end
