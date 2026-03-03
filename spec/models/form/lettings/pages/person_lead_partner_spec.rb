require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonLeadPartner, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:start_year_2026_or_later?) { false }
  let(:person_question_count) { 4 }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2026_or_later?: start_year_2026_or_later?, person_question_count:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:person_index) { 2 }
  let(:is_any_person_partner?) { false }
  let(:log) { instance_double(LettingsLog, is_any_person_partner?: is_any_person_partner?) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  describe "#skip_page_in_form_flow?" do
    context "with start year < 2026", metadata: { year: 25 } do
      context "when no other person is the partner of the lead tenant" do
        let(:is_any_person_partner?) { false }

        it "returns false" do
          expect(page.skip_page_in_form_flow?(log)).to be false
        end
      end

      context "when another person is the partner of the lead tenant" do
        let(:is_any_person_partner?) { true }

        it "returns false" do
          expect(page.skip_page_in_form_flow?(log)).to be false
        end
      end
    end

    context "with start year >= 2026", metadata: { year: 26 } do
      let(:start_year_2026_or_later?) { true }

      context "when no other person is the partner of the lead tenant" do
        let(:is_any_person_partner?) { false }

        it "returns false" do
          expect(page.skip_page_in_form_flow?(log)).to be false
        end
      end

      context "when another person is the partner of the lead tenant" do
        let(:is_any_person_partner?) { true }

        it "returns true" do
          expect(page.skip_page_in_form_flow?(log)).to be true
        end
      end
    end
  end

  context "with person 2" do
    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[relat2])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_lead_partner")
    end

    context "with start year < 2026", metadata: { year: 25 } do
      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [{ "details_known_2" => 0 }],
        )
      end
    end

    context "with start year >= 2026", metadata: { year: 26 } do
      let(:start_year_2026_or_later?) { true }

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            {
              "details_known_2" => 0,
              "age2" => {
                "operator" => ">=",
                "operand" => 16,
              },
            },
            { "details_known_2" => 0, "age2" => nil },
          ],
        )
      end
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[relat3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_lead_partner")
    end

    context "with start year < 2026", metadata: { year: 25 } do
      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [{ "details_known_3" => 0 }],
        )
      end
    end

    context "with start year >= 2026", metadata: { year: 26 } do
      let(:start_year_2026_or_later?) { true }

      it "has correct depends_on" do
        expect(page.depends_on).to eq(
          [
            {
              "details_known_3" => 0,
              "age3" => {
                "operator" => ">=",
                "operand" => 16,
              },
            },
            { "details_known_3" => 0, "age3" => nil },
          ],
        )
      end
    end
  end
end
