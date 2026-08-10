require "rails_helper"

RSpec.describe Form::Sales::Pages::BuyerPrevious, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:log) { build(:sales_log, :completed) }

  let(:page_id) { "example" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, depends_on: nil, enabled?: true, form:) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }
  let(:joint_purchase) { false }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[soctenant])
  end

  it "has the correct id" do
    expect(page.id).to eq("example")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  describe "#routed_to?" do
    [nil, 1, 2, 3].each do |staircase|
      it "is not routed to when staircase is #{staircase.inspect}" do
        log.staircase = staircase
        expect(page.routed_to?(log, nil)).to be(false)
      end
    end
  end
end
