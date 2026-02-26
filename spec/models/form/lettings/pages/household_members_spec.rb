require "rails_helper"

RSpec.describe Form::Lettings::Pages::HouseholdMembers, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date, start_year_2026_or_later?: true) }

  before do
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[hhmemb])
  end

  it "has the correct id" do
    expect(page.id).to eq("household_members")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end
end
