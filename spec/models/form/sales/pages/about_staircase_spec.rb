require "rails_helper"

RSpec.describe Form::Sales::Pages::AboutStaircase, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:page_id) { "an_id" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:joint_purchase) { false }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  describe "questions" do
    let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:)) }

    context "when 2022" do
      let(:start_date) { Time.utc(2022, 2, 8) }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[stairbought stairowned])
      end
    end

    context "when 2023" do
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[stairbought stairowned staircasesale])
      end
    end
  end

  it "has the correct id" do
    expect(page.id).to eq("an_id")
  end

  it "has the correct header" do
    expect(page.header).to eq("About the staircasing transaction")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when not a joint purchase" do
    it "has correct depends_on" do
      expect(page.depends_on).to eq([{
        "staircase" => 1,
        "joint_purchase?" => false,
      }])
    end
  end

  context "when a joint purchase" do
    let(:joint_purchase) { true }

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{
        "staircase" => 1,
        "joint_purchase?" => true,
      }])
    end
  end
end
