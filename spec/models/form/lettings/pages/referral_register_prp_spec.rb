require "rails_helper"

RSpec.describe Form::Lettings::Pages::ReferralRegisterPrp, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:form) { instance_double(Form, start_date: Time.zone.today) }
  let(:prp?) { nil }
  let(:organisation) { instance_double(Organisation, prp?: prp?) }
  let(:is_renewal?) { nil }
  let(:log) { instance_double(LettingsLog, is_renewal?: is_renewal?, owning_organisation: organisation) }

  before do
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[referral_register])
  end

  it "has the correct id" do
    expect(page.id).to eq("referral_register_prp")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to be nil
  end

  context "when log is a renewal" do
    let(:is_renewal?) { true }

    context "and log owning organisation is prp" do
      let(:prp?) { true }

      it "is not routed to" do
        expect(page.routed_to?(log, nil)).to be false
      end
    end

    context "and log owning organisation is not prp" do
      let(:prp?) { false }

      it "is not routed to" do
        expect(page.routed_to?(log, nil)).to be false
      end
    end
  end

  context "when log is not a renewal" do
    let(:is_renewal?) { false }

    context "and log owning organisation is prp" do
      let(:prp?) { true }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to be true
      end
    end

    context "and log owning organisation is not prp" do
      let(:prp?) { false }

      it "is not routed to" do
        expect(page.routed_to?(log, nil)).to be false
      end
    end
  end
end
