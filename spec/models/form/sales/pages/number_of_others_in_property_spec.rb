require "rails_helper"

RSpec.describe Form::Sales::Pages::NumberOfOthersInProperty, type: :model do
  include CollectionTimeHelper

  subject(:page) { described_class.new(page_id, page_definition, subsection, joint_purchase:) }

  let(:page_id) { "number_of_others_in_property" }
  let(:page_definition) { nil }
  let(:joint_purchase) { false }
  let(:form) { instance_double(Form, start_date: current_collection_start_date, start_year_2026_or_later?: true, start_year_2025_or_later?: false, depends_on_met: true) }
  let(:subsection) { instance_double(Form::Subsection, enabled?: true, depends_on: nil) }

  before do
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[hholdcount])
  end

  it "has the correct id" do
    expect(page.id).to eq("number_of_others_in_property")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "with joint purchase" do
    let(:page_id) { "number_of_others_in_property_joint_purchase" }
    let(:joint_purchase) { true }

    it "has the correct id" do
      expect(page.id).to eq("number_of_others_in_property_joint_purchase")
    end

    context "when routing" do
      before do
        allow(log).to receive(:form).and_return(form)
      end

      context "with 2024 logs" do
        let(:form) { instance_double(Form, start_date: collection_start_date_for_year(2024), start_year_2026_or_later?: false, start_year_2025_or_later?: false, depends_on_met: true) }

        context "with joint purchase" do
          context "when buyer has seen privacy notice and buyer interviewed" do
            let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0) }

            it "routes to the page" do
              expect(page.routed_to?(log, nil)).to be(true)
            end
          end

          context "when buyer has seen privacy notice and buyer not interviewed" do
            let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 1) }

            it "routes to the page" do
              expect(page.routed_to?(log, nil)).to be(true)
            end
          end

          context "and buyer has not seen privacy notice and buyer interviewed" do
            let(:log) { build(:sales_log, privacynotice: nil, jointpur: 1, noint: 0) }

            it "does not route to the page" do
              expect(page).not_to be_routed_to(log, nil)
            end
          end

          context "and buyer has not seen privacy notice and buyer not interviewed" do
            let(:log) { build(:sales_log, privacynotice: nil, jointpur: 1, noint: 1) }

            it "routes to the page" do
              expect(page.routed_to?(log, nil)).to be(true)
            end
          end
        end

        context "with non joint purchase" do
          context "when buyer has seen privacy notice and buyer interviewed" do
            let(:log) { build(:sales_log, privacynotice: 1, jointpur: 2, noint: 0) }

            it "routes to the page" do
              expect(page).not_to be_routed_to(log, nil)
            end
          end

          context "when buyer has seen privacy notice and buyer not interviewed" do
            let(:log) { build(:sales_log, privacynotice: 1, jointpur: 2, noint: 1) }

            it "routes to the page" do
              expect(page).not_to be_routed_to(log, nil)
            end
          end

          context "and buyer has not seen privacy notice and buyer interviewed" do
            let(:log) { build(:sales_log, privacynotice: nil, jointpur: 2, noint: 0) }

            it "does not route to the page" do
              expect(page).not_to be_routed_to(log, nil)
            end
          end

          context "and buyer has not seen privacy notice and buyer not interviewed" do
            let(:log) { build(:sales_log, privacynotice: nil, jointpur: 2, noint: 1) }

            it "routes to the page" do
              expect(page).not_to be_routed_to(log, nil)
            end
          end
        end
      end

      context "with 2025 logs" do
        let(:form) { instance_double(Form, start_date: collection_start_date_for_year(2025), start_year_2026_or_later?: false, start_year_2025_or_later?: true, depends_on_met: true) }

        context "and staircase is not 1" do
          let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0, staircase: 2) }

          it "routes to the page" do
            expect(page.routed_to?(log, nil)).to be(true)
          end
        end

        context "and staircase is 1" do
          let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0, staircase: 1) }

          it "does not route to the page" do
            expect(page).not_to be_routed_to(log, nil)
          end
        end
      end

      context "with 2026 logs" do
        let(:form) { instance_double(Form, start_date: current_collection_start_date, start_year_2026_or_later?: true, start_year_2025_or_later?: true, depends_on_met: true) }

        context "and staircase is not 1" do
          let(:log) { build(:sales_log, privacynotice: 1, jointpur: 1, noint: 0, staircase: 2) }

          it "routes to the page" do
            expect(page.routed_to?(log, nil)).to be(true)
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
end
