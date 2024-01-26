require "rails_helper"

RSpec.describe Form::Sales::Pages::SharedOwnershipType, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:, start_year_after_2024?: false)) }
  let(:start_date) { Time.utc(2022, 4, 1) }

  describe "headers" do
    context "when form is after the year 2023/24" do
      let(:start_date) { Time.zone.local(2023, 4, 8) }

      it "has the correct header" do
        expect(page.header).to eq("Type of shared ownership sale")
      end
    end

    context "when form is before the year 2023/24" do
      let(:start_date) { Time.zone.local(2022, 2, 8) }

      it "has the correct header" do
        expect(page.header).to eq(nil)
      end
    end
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[type])
  end

  it "has the correct id" do
    expect(page.id).to eq("shared_ownership_type")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{
      "ownershipsch" => 1,
    }])
  end
end
