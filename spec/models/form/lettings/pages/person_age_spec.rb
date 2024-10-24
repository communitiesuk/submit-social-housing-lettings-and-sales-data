require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonAge, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:, person_type:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_after_2024?: false)) }
  let(:person_index) { 2 }
  let(:person_type) { "non_child" }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be nil
  end

  context "with person 2" do
    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[age2_known age2])
    end

    context "when child" do
      let(:person_type) { "child" }

      it "has the correct id" do
        expect(page.id).to eq("person_2_age_child")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [{ "details_known_2" => 0, "person_2_child_relation?" => true }],
        )
      end
    end

    context "when not child" do
      it "has the correct id" do
        expect(page.id).to eq("person_2_age_non_child")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [{ "details_known_2" => 0, "person_2_child_relation?" => false }],
        )
      end
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[age3_known age3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_age_non_child")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "details_known_3" => 0, "person_3_child_relation?" => false }],
      )
    end
  end
end
