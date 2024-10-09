require "rails_helper"

RSpec.describe Form::Page, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) { FactoryBot.build(:lettings_log) }
  let(:depends_on) { nil }
  let(:enabled) { true }
  let(:depends_on_met) { true }
  let(:form) { instance_double(Form, depends_on_met:, type: "form-type") }
  let(:subsection) { instance_double(Form::Subsection, depends_on:, enabled?: enabled, form:, id: "subsection-id") }
  let(:page_id) { "net_income" }
  let(:questions) { [["earnings", { "conditional_for" => { "age1": nil }, "type" => "radio" }], %w[incfreq]] }
  let(:page_definition) do
    {
      "header" => "Test header",
      "description" => "Some extra text for the page",
      "questions" => questions,
    }
  end

  it "has an id" do
    expect(page.id).to eq(page_id)
  end

  it "sets copy_key in the default style" do
    expect(page.copy_key).to eq("#{form.type}.#{subsection.id}.#{questions[0].id}")
  end

  context "when header is not provided" do
    let(:page_definition) do
      {
        "questions" => questions,
      }
    end

    context "and translation is present" do
      before do
        allow(I18n).to receive(:t).and_return("page header copy")
        allow(I18n).to receive(:exists?).and_return(true)
      end

      it "uses header from translations" do
        expect(page.header).to eq("page header copy")
      end
    end

    context "and translation is not present" do
      before do
        allow(I18n).to receive(:exists?).and_return(false)
      end

      it "uses empty header" do
        expect(page.header).to eq("")
      end
    end
  end

  it "has a header" do
    expect(page.header).to eq("Test header")
  end

  it "has a description" do
    expect(page.description).to eq("Some extra text for the page")
  end

  it "has questions" do
    expected_questions = %w[earnings incfreq]
    expect(page.questions.map(&:id)).to eq(expected_questions)
  end

  it "knows which questions are not conditional" do
    expected_non_conditional_questions = %w[earnings incfreq]
    expect(page.non_conditional_questions.map(&:id))
      .to eq(expected_non_conditional_questions)
  end

  describe "#interruption_screen?" do
    context "when it has regular questions" do
      it "returns false" do
        expect(page.interruption_screen?).to be false
      end
    end

    context "when it has interruption_screen question" do
      let(:questions) { [["earnings", { "type" => "interruption_screen" }]] }

      it "returns true" do
        expect(page.interruption_screen?).to be true
      end
    end
  end

  context "with a lettings log" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }

    it "knows if it's been routed to" do
      expect(page.routed_to?(lettings_log, user)).to be true
    end

    context "with routing conditions" do
      let(:depends_on) { true }

      context "when the conditions are not met" do
        let(:depends_on_met) { false }

        it "evaluates conditions correctly" do
          expect(page.routed_to?(lettings_log, user)).to be false
        end
      end

      context "when the conditions are met" do
        let(:depends_on_met) { true }

        it "evaluates met conditions correctly" do
          lettings_log.incfreq = 1
          expect(page.routed_to?(lettings_log, user)).to be true
        end
      end
    end

    context "when the page's subsection has routing conditions" do
      let(:depends_on) { true }
      let(:depends_on_met) { true }
      let(:enabled) { false }

      it "evaluates the sections dependencies" do
        expect(page.routed_to?(lettings_log, user)).to be false
      end
    end
  end
end
