require "rails_helper"

RSpec.describe Form::Sales::Pages::DepositDiscount, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection, optional: false) }

  let(:page_id) { "discount" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  before do
    allow(subsection).to receive(:form).and_return(instance_double(Form, start_date: current_collection_start_date))
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[cashdis])
  end

  it "has the correct id" do
    expect(page.id).to eq("discount")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq(
      [{ "social_homebuy?" => true, "stairowned_100?" => false }],
    )
  end

  context "when optional" do
    subject(:page) { described_class.new(page_id, page_definition, subsection, optional: true) }

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "social_homebuy?" => true, "stairowned_100?" => true }],
      )
    end
  end
end
