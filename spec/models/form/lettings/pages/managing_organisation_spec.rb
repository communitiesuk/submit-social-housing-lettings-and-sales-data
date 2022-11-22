require "rails_helper"

RSpec.describe Form::Lettings::Pages::ManagingOrganisation, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[managing_organisation_id])
  end

  it "has the correct id" do
    expect(page.id).to eq("managing_organisation")
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
    let(:log) { create(:lettings_log) }
    let(:organisation) { create(:organisation) }

    context "when user nil" do
      it "is not shown" do
        expect(page.routed_to?(log, nil)).to eq(false)
      end
    end

    context "when support" do
      context "when does not hold own stock" do
        let(:user) do
          create(:user, :support, organisation: create(:organisation, holds_own_stock: false))
        end
        let(:log) { create(:lettings_log, owning_organisation: user.organisation) }

        it "is shown" do
          expect(page.routed_to?(log, user)).to eq(true)
        end
      end

      context "when owning_organisation not set" do
        let(:user) { create(:user, :support) }
        let(:log) { create(:lettings_log, owning_organisation: nil) }

        it "is not shown" do
          expect(page.routed_to?(log, user)).to eq(false)
        end
      end

      context "when holds own stock" do
        let(:user) do
          create(:user, :support, organisation: create(:organisation, holds_own_stock: true))
        end

        context "with 0 managing_agents" do
          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end
        end

        context "with >1 managing_agents" do
          before do
            create(:organisation_relationship, :managing, parent_organisation: log.owning_organisation)
            create(:organisation_relationship, :managing, parent_organisation: log.owning_organisation)
          end

          it "is shown" do
            expect(page.routed_to?(log, user)).to eq(true)
          end
        end

        context "with 1 managing_agents" do
          let(:managing_agent) { create(:organisation) }

          before do
            create(
              :organisation_relationship,
              :managing,
              child_organisation: managing_agent,
              parent_organisation: log.owning_organisation,
            )
          end

          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end
        end
      end
    end

    context "when not support" do
      context "when does not hold own stock" do
        let(:user) do
          create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: false))
        end

        it "is shown" do
          expect(page.routed_to?(log, user)).to eq(true)
        end
      end

      context "when holds own stock" do
        let(:user) do
          create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: true))
        end

        context "with 0 managing_agents" do
          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end
        end

        context "with >1 managing_agents" do
          before do
            create(:organisation_relationship, :managing, parent_organisation: user.organisation)
            create(:organisation_relationship, :managing, parent_organisation: user.organisation)
          end

          it "is shown" do
            expect(page.routed_to?(log, user)).to eq(true)
          end
        end

        context "with 1 managing_agents" do
          let(:managing_agent) { create(:organisation) }

          before do
            create(
              :organisation_relationship,
              :managing,
              child_organisation: managing_agent,
              parent_organisation: user.organisation,
            )
          end

          it "is not shown" do
            expect(page.routed_to?(log, user)).to eq(false)
          end
        end
      end
    end
  end
end
