require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer1Nationality, type: :model do
  subject(:page) { described_class.new(nil, nil, subsection) }

  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(subsection).to receive(:form).and_return(form)
    allow(form).to receive(:start_year_after_2024?).and_return(false)
  end

  it "has correct subsection" do
    expect(page.subsection).to be subsection
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq %w[national]
  end

  it "has the correct id" do
    expect(page.id).to eq "buyer_1_nationality"
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq [{ "buyer_has_seen_privacy_notice?" => true }, { "buyer_not_interviewed?" => true }]
  end

  context "with year 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq %w[nationality_all_group nationality_all]
    end
  end
end
