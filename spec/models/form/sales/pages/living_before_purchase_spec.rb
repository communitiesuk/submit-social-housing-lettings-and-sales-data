require "rails_helper"

RSpec.describe Form::Sales::Pages::LivingBeforePurchase, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, joint_purchase: false) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:start_year) { 2022 }
  let(:form) { Form.new(nil, start_year, [], "sales") }
  let(:subsection) { instance_double(Form::Subsection, depends_on: nil, form:) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  describe "questions" do
    let(:subsection) { instance_double(Form::Subsection, form:, depends_on: nil) }

    context "when 2022" do
      let(:start_year) { 2022 }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[proplen])
      end
    end

    context "when 2023" do
      let(:start_year) { 2023 }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[proplen_asked proplen])
      end
    end
  end

  it "has the correct id" do
    expect(page.id).to eq(nil)
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when routing" do
    context "with form before 2025" do
      let(:start_year) { 2024 }

      context "with joint purchase" do
        subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, joint_purchase: true) }

        it "routes to the page when joint purchase is true" do
          log = build(:sales_log, jointpur: 1)
          expect(page.routed_to?(log, nil)).to eq(true)
        end

        it "does not route to the page when joint purchase is false" do
          log = build(:sales_log, jointpur: 2)
          expect(page.routed_to?(log, nil)).to eq(false)
        end

        it "does not route to the page when joint purchase is missing" do
          log = build(:sales_log, jointpur: nil)
          expect(page.routed_to?(log, nil)).to eq(false)
        end
      end

      context "with non joint purchase" do
        subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, joint_purchase: false) }

        it "routes to the page when joint purchase is false" do
          log = build(:sales_log, jointpur: 2)
          expect(page.routed_to?(log, nil)).to eq(true)
        end

        it "does not route to the page when joint purchase is true" do
          log = build(:sales_log, jointpur: 1)
          expect(page.routed_to?(log, nil)).to eq(false)
        end

        it "routes to the page when joint purchase is missing" do
          log = build(:sales_log, jointpur: nil)
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end
    end

    context "with form on or after 2025" do
      subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, joint_purchase: true) }

      let(:start_year) { 2025 }

      it "routes to the page when resale is 2" do
        log = build(:sales_log, jointpur: 1, resale: 2)
        expect(page.routed_to?(log, nil)).to eq(true)
      end

      it "does not route to the page when resale is not 2" do
        log = build(:sales_log, jointpur: 1, resale: nil, ownershipsch: 1)
        expect(page.routed_to?(log, nil)).to eq(false)
      end
    end
  end
end
