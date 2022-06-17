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

  it "has the correct derived" do
    expect(page.derived).to be nil
  end

  context "when the current user is a support user" do
    let(:support_user) { FactoryBot.build(:user, :support) }

    before do
      allow(subsection).to receive(:form).and_return(form)
      allow(form).to receive(:current_user).and_return(support_user)
    end

    it "is shown" do
      expect(page.routed_to?(case_log)).to be true
    end
  end

  context "when the current user is not a support user" do
    let(:user) { FactoryBot.build(:user) }

    before do
      allow(subsection).to receive(:form).and_return(form)
      allow(form).to receive(:current_user).and_return(user)
    end

    it "is not shown" do
      expect(page.routed_to?(case_log)).to be false
    end
  end
end
