require "rails_helper"

RSpec.describe Form::Sales::Pages::ServiceChargeChanged, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: collection_start_date_for_year(2026))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[hasservicechargeschanged newservicecharges])
  end

  it "has the correct id" do
    expect(page.id).to eq("service_charge_changed")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to be_nil
  end
end
