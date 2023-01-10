require "rails_helper"

RSpec.describe Form::Sales::Pages::PersonWorkingSituation, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 1 }

  context "without joint purchase" do
    let(:page_id) { "person_1_working_situation" }

    it "has correct subsection" do
      expect(page.subsection).to eq(subsection)
    end

    it "has the correct header" do
      expect(page.header).to eq("")
    end

    it "has the correct description" do
      expect(page.description).to be_nil
    end

    context "with person 1" do
      let(:person_index) { 2 }
      let(:page_id) { "person_1_working_situation" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat2])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_1_working_situation")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_1" => 1, "jointpur" => 2 }])
      end
    end

    context "with person 2" do
      let(:person_index) { 3 }
      let(:page_id) { "person_2_working_situation" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat3])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_working_situation")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_2" => 1, "jointpur" => 2 }])
      end
    end

    context "with person 3" do
      let(:person_index) { 4 }
      let(:page_id) { "person_3_working_situation" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat4])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_working_situation")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_3" => 1, "jointpur" => 2 }])
      end
    end

    context "with person 4" do
      let(:person_index) { 5 }
      let(:page_id) { "person_4_working_situation" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat5])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_working_situation")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_4" => 1, "jointpur" => 2 }])
      end
    end
  end

  context "with joint purchase" do
    let(:page_id) { "person_1_working_situation_joint_purchase" }

    it "has correct subsection" do
      expect(page.subsection).to eq(subsection)
    end

    it "has the correct header" do
      expect(page.header).to eq("")
    end

    it "has the correct description" do
      expect(page.description).to be_nil
    end

    context "with person 1" do
      let(:person_index) { 3 }
      let(:page_id) { "person_1_working_situation_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat3])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_1_working_situation_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_1" => 1, "jointpur" => 1 }])
      end
    end

    context "with person 2" do
      let(:person_index) { 4 }

      let(:page_id) { "person_2_working_situation_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat4])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_working_situation_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_2" => 1, "jointpur" => 1 }])
      end
    end

    context "with person 3" do
      let(:person_index) { 5 }
      let(:page_id) { "person_3_working_situation_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat5])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_working_situation_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_3" => 1, "jointpur" => 1 }])
      end
    end

    context "with person 4" do
      let(:person_index) { 6 }
      let(:page_id) { "person_4_working_situation_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[ecstat6])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_working_situation_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "details_known_4" => 1, "jointpur" => 1 }])
      end
    end
  end
end
