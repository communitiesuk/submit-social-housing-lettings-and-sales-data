require "rails_helper"

RSpec.describe Form::Sales::Pages::PersonKnown, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  context "without joint purchase" do
    let(:page_id) { "person_2_known" }
    let(:page_definition) { nil }
    let(:subsection) { instance_double(Form::Subsection) }
    let(:person_index) { 2 }

    it "has correct subsection" do
      expect(page.subsection).to eq(subsection)
    end

    it "has the correct header" do
      expect(page.header).to be_nil
    end

    it "has the correct description" do
      expect(page.description).to be_nil
    end

    context "with person 2" do
      let(:page_id) { "person_2_known" }
      let(:person_index) { 2 }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[details_known_2])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_known")
      end

      it "has the correct header_partial" do
        expect(page.header_partial).to eq("person_2_known_page")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{
          "not_joint_purchase?" => true,
          "hholdcount" => {
            "operator" => ">=",
            "operand" => 1,
          },
        }])
      end
    end

    context "with person 3" do
      let(:page_id) { "person_3_known" }
      let(:person_index) { 3 }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[details_known_3])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_known")
      end

      it "has the correct header_partial" do
        expect(page.header_partial).to eq("person_3_known_page")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([
          {
            "not_joint_purchase?" => true,
            "hholdcount" => {
              "operator" => ">=",
              "operand" => 2,
            },
          },
          {
            "joint_purchase?" => true,
            "hholdcount" => {
              "operator" => ">=",
              "operand" => 1,
            },

          },
        ])
      end
    end

    context "with person 4" do
      let(:page_id) { "person_4_known" }
      let(:person_index) { 4 }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[details_known_4])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_known")
      end

      it "has the correct header_partial" do
        expect(page.header_partial).to eq("person_4_known_page")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([
          {
            "not_joint_purchase?" => true,
            "hholdcount" => {
              "operator" => ">=",
              "operand" => 3,
            },
          },
          {
            "joint_purchase?" => true,
            "hholdcount" => {
              "operator" => ">=",
              "operand" => 2,
            },
          },
        ])
      end
    end

    context "with person 5" do
      let(:page_id) { "person_5_known" }
      let(:person_index) { 5 }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[details_known_5])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_5_known")
      end

      it "has the correct header_partial" do
        expect(page.header_partial).to eq("person_5_known_page")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([
          {
            "not_joint_purchase?" => true,
            "hholdcount" => {
              "operator" => ">=",
              "operand" => 4,
            },
          },
          {
            "joint_purchase?" => true,
            "hholdcount" => {
              "operator" => ">=",
              "operand" => 3,
            },
          },
        ])
      end
    end
  end
end
