require "rails_helper"

RSpec.describe Form::Lettings::Pages::StockOwner, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[owning_organisation_id])
  end

  it "has the correct id" do
    expect(page.id).to eq("stock_owner")
  end

  it "has the correct header" do
    expect(page.header).to eq("")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to be nil
  end

  describe "#routed_to?" do
    let(:log) { create(:lettings_log, owning_organisation_id: nil) }

    context "when user nil" do
      it "is not shown" do
        expect(page.routed_to?(log, nil)).to eq(false)
      end

      it "does not update owning_organisation_id" do
        expect { page.routed_to?(log, nil) }.not_to change(log.reload, :owning_organisation).from(nil)
      end
    end

    context "when support" do
      let(:user) { create(:user, :support) }

      it "is shown" do
        expect(page.routed_to?(log, user)).to eq(true)
      end

      it "does not update owning_organisation_id" do
        expect { page.routed_to?(log, user) }.not_to change(log.reload, :owning_organisation).from(nil)
      end
    end

    context "when not support" do
      context "when does not hold own stock" do
        let(:user) do
          create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: false))
        end

        context "with 0 stock_owners" do
          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end

          it "does not update owning_organisation_id" do
            expect { page.routed_to?(log, user) }.not_to change(log.reload, :owning_organisation)
          end
        end

        context "with 1 stock_owners" do
          let(:stock_owner) { create(:organisation) }

          before do
            create(
              :organisation_relationship,
              child_organisation: user.organisation,
              parent_organisation: stock_owner,
            )
          end

          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end

          it "updates owning_organisation_id" do
            expect { page.routed_to?(log, user) }.to change(log.reload, :owning_organisation).from(nil).to(stock_owner)
          end
        end

        context "with >1 stock_owners" do
          let(:stock_owner1) { create(:organisation) }
          let(:stock_owner2) { create(:organisation) }

          before do
            create(
              :organisation_relationship,
              child_organisation: user.organisation,
              parent_organisation: stock_owner1,
            )
            create(
              :organisation_relationship,
              child_organisation: user.organisation,
              parent_organisation: stock_owner2,
            )
          end

          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(true)
          end

          it "updates owning_organisation_id" do
            expect { page.routed_to?(log, user) }.not_to change(log.reload, :owning_organisation)
          end
        end
      end

      context "when holds own stock" do
        let(:user) do
          create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: true))
        end

        context "with 0 stock_owners" do
          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end

          it "updates owning_organisation_id to user organisation" do
            expect { page.routed_to?(log, user) }.to change(log.reload, :owning_organisation).from(nil).to(user.organisation)
          end
        end

        context "with >0 stock_owners" do
          before do
            create(:organisation_relationship, child_organisation: user.organisation)
            create(:organisation_relationship, child_organisation: user.organisation)
          end

          it "is shown" do
            expect(page.routed_to?(log, user)).to eq(true)
          end

          it "does not update owning_organisation_id" do
            expect { page.routed_to?(log, user) }.not_to change(log.reload, :owning_organisation).from(nil)
          end
        end
      end
    end
  end
end
