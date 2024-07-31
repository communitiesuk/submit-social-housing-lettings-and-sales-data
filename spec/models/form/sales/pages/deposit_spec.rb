require "rails_helper"

RSpec.describe Form::Sales::Pages::Deposit, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, optional: false) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  before do
    allow(subsection).to receive(:form).and_return(instance_double(Form, start_year_after_2024?: false, start_date: Time.zone.local(2023, 4, 1)))
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[deposit])
  end

  it "has the correct id" do
    expect(page.id).to eq(nil)
  end

  it "has the correct header" do
    expect(page.header).to eq("About the deposit")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq(
      [{ "social_homebuy?" => false, "ownershipsch" => 1 },
       { "ownershipsch" => 2 },
       { "ownershipsch" => 3, "mortgageused" => 1 },
       { "social_homebuy?" => true }],
    )
  end

  context "when optional is true" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, optional: true) }

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "social_homebuy?" => false, "ownershipsch" => 1 },
         { "ownershipsch" => 2 },
         { "ownershipsch" => 3, "mortgageused" => 1 },
         { "social_homebuy?" => true }],
      )
    end
  end

  context "when it's a 2024 form" do
    before do
      allow(subsection).to receive(:form).and_return(instance_double(Form, start_year_after_2024?: true, start_date: Time.zone.local(2024, 4, 1)))
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "social_homebuy?" => false, "ownershipsch" => 1, "stairowned_100?" => false },
         { "ownershipsch" => 2 },
         { "ownershipsch" => 3, "mortgageused" => 1 },
         { "social_homebuy?" => true, "stairowned_100?" => false }],
      )
    end

    context "and optional is true" do
      subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, optional: true) }

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [{ "social_homebuy?" => false, "ownershipsch" => 1, "stairowned_100?" => true },
           { "ownershipsch" => 2 },
           { "ownershipsch" => 3, "mortgageused" => 1 },
           { "social_homebuy?" => true, "stairowned_100?" => true }],
        )
      end
    end
  end
end
