require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonWorkingSituation, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:form) { Form.new(nil, 2024, [], "lettings") }
  let(:subsection) { instance_double(Form::Subsection, enabled?: true, form:, depends_on: nil) }
  let(:person_index) { 2 }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be nil
  end

  context "with person 2" do
    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[ecstat2])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_working_situation")
    end

    describe "routed_to?" do
      context "with details_known_2 = 0 and age2 > 15" do
        let(:log) { build(:lettings_log, details_known_2: 0, age2: 16) }

        it "is routed to" do
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end

      context "with details_known_2 = 0 and age2 = nil" do
        let(:log) { build(:lettings_log, details_known_2: 0, age2: nil) }

        it "is routed to" do
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end

      context "with details_known_2 not 0" do
        let(:log) { build(:lettings_log, details_known_2: 1, age2: 16) }

        it "is not routed to" do
          expect(page.routed_to?(log, nil)).to eq(false)
        end
      end

      context "with age2 < 15" do
        let(:log) { build(:lettings_log, details_known_2: 0, age2: 15) }

        it "is not routed to" do
          expect(page.routed_to?(log, nil)).to eq(false)
        end
      end
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[ecstat3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_working_situation")
    end
  end
end
