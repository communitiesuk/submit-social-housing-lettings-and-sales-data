require "rails_helper"

RSpec.describe Form::Sales::Pages::Deposit, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1, optional:) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, enabled?: true) }
  let(:form) { instance_double(Form, start_year_after_2024?: false, start_date: Time.zone.local(2023, 4, 1)) }
  let(:optional) { false }

  before do
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[deposit])
  end

  it "has the correct id" do
    expect(page.id).to eq(nil)
  end

  it "has the correct header" do
    expect(page.header).to eq("About the deposit")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when routing with start year after 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    context "and optional is false" do
      context "and the log is shared ownership, not social homembuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 70) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, not social homembuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 100) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 80) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 100) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "and the log is discounted ownership" do
        let(:log) { build(:sales_log, ownershipsch: 2, type: 18) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is outright ownership and mortgage used is yes" do
        let(:log) { build(:sales_log, ownershipsch: 3, mortgageused: 1) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and ownership is outright sale and mortgage used is not yes" do
        let(:log) { build(:sales_log, ownershipsch: 3, mortgageused: 2) }

        it "doesn't route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end
    end

    context "and optional is true" do
      let(:optional) { true }

      context "and the log is shared ownership, not social homembuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 70) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, not social homembuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 100) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 80) }

        it "does not route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 100) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end
    end
  end

  context "when routing with start year before 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    context "and optional is false" do
      context "and the log is shared ownership, not social homembuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 70) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, not social homembuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 100) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 80) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 100) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is discounted ownership" do
        let(:log) { build(:sales_log, ownershipsch: 2, type: 18) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is outright ownership and mortgage used is yes" do
        let(:log) { build(:sales_log, ownershipsch: 3, mortgageused: 1) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and ownership is outright sale and mortgage used is not yes" do
        let(:log) { build(:sales_log, ownershipsch: 3, mortgageused: 2) }

        it "doesn't route to the page" do
          expect(page).not_to be_routed_to(log, nil)
        end
      end
    end

    context "and optional is true" do
      let(:optional) { true }

      context "and the log is shared ownership, not social homembuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 70) }

        it "does routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, not social homembuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 16, stairowned: 100) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is not 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 80) }

        it "does routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end

      context "and the log is shared ownership, social homebuy and stairowned is 100" do
        let(:log) { build(:sales_log, ownershipsch: 1, type: 18, stairowned: 100) }

        it "routes to the page" do
          expect(page).to be_routed_to(log, nil)
        end
      end
    end
  end
end
