require "rails_helper"

RSpec.describe Form::Sales::Pages::PersonAge, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "person_1_age" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to eq("")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  context "with a non joint purchase" do
    context "and person 1" do
      let(:page_id) { "person_1_age" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age2_known age2])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_1_age")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_1" => 1, "jointpur" => 2 },
          ],
        )
      end
    end

    context "and person 2" do
      let(:page_id) { "person_2_age" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age3_known age3])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_age")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_2" => 1, "jointpur" => 2 },
          ],
        )
      end
    end

    context "and person 3" do
      let(:page_id) { "person_3_age" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age4_known age4])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_age")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_3" => 1, "jointpur" => 2 },
          ],
        )
      end
    end

    context "and person 4" do
      let(:page_id) { "person_4_age" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age5_known age5])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_age")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_4" => 1, "jointpur" => 2 },
          ],
        )
      end
    end
  end

  context "with joint purchase" do
    context "and person 1" do
      let(:page_id) { "person_1_age_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age3_known age3])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_1_age_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_1" => 1, "jointpur" => 1 },
          ],
        )
      end
    end

    context "and person 2" do
      let(:page_id) { "person_2_age_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age4_known age4])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_age_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_2" => 1, "jointpur" => 1 },
          ],
        )
      end
    end

    context "and person 3" do
      let(:page_id) { "person_3_age_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age5_known age5])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_age_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_3" => 1, "jointpur" => 1 },
          ],
        )
      end
    end

    context "and person 4" do
      let(:page_id) { "person_4_age_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[age6_known age6])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_age_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            { "details_known_4" => 1, "jointpur" => 1 },
          ],
        )
      end
    end
  end
end
