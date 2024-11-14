require "rails_helper"

RSpec.describe Form::Sales::Pages::Buyer2WorkingSituation, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { Form.new(nil, 2023, [], "sales") }
  let(:subsection) { instance_double(Form::Subsection, form:, depends_on: nil) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[ecstat2])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_2_working_situation")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "with year 2024" do
    let(:form) { Form.new(nil, 2024, [], "sales") }

    context "when routing" do
      before do
        allow(log).to receive(:form).and_return(form)
      end

      context "when buyer has seen privacy notice and buyer interviewed" do
        let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0, staircase: 2) }

        it "routes to the page" do
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end

      context "when buyer has seen privacy notice and buyer not interviewed" do
        let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 1, staircase: 2) }

        it "routes to the page" do
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end

      context "and buyer has not seen privacy notice and buyer interviewed" do
        let(:log) { build(:sales_log, privacynotice: nil, jointpur: 1, noint: 0, staircase: 2) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "and buyer has not seen privacy notice and buyer not interviewed" do
        let(:log) { build(:sales_log, privacynotice: nil, jointpur: 1, noint: 1, staircase: 2) }

        it "routes to the page" do
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end

      context "when it's not a joint purchase" do
        let(:log) { build(:sales_log, privacynotice: nil, jointpur: 2, noint: 1, staircase: 2) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end
    end
  end

  context "with year 2025" do
    let(:form) { Form.new(nil, 2025, [], "sales") }

    before do
      allow(log).to receive(:form).and_return(form)
    end

    context "when routing" do
      context "and staircase is not 1" do
        let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0, staircase: 2) }

        it "routes to the page" do
          expect(page.routed_to?(log, nil)).to eq(true)
        end
      end

      context "and staircase is 1" do
        let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0, staircase: 1) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end
    end
  end
end
