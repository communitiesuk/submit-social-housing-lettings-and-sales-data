require "rails_helper"

RSpec.describe Form::Sales::Pages::ManagingOrganisation, type: :model do
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
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
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

    context "when user is not support" do
      let(:user) { create(:user) }

      it "is not shown" do
        expect(page.routed_to?(log, nil)).to eq(false)
      end
    end

    context "when support" do
      let(:user) { create(:user, :support) }

      context "when owning_organisation not set" do
        let(:log) { create(:lettings_log, owning_organisation: nil) }

        it "is not shown" do
          expect(page.routed_to?(log, user)).to eq(false)
        end
      end

      context "with 0 managing_agents" do
        it "is not shown" do
          expect(page.routed_to?(log, user)).to eq(false)
        end
      end

      context "with >1 managing_agents" do
        before do
          create(:organisation_relationship, parent_organisation: log.owning_organisation)
          create(:organisation_relationship, parent_organisation: log.owning_organisation)
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
            child_organisation: managing_agent,
            parent_organisation: log.owning_organisation,
          )
        end

        it "is shown" do
          expect(page.routed_to?(log, user)).to eq(true)
        end
      end
    end

    context "when not support" do
      let(:user) { create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: false)) }

      it "is not shown" do
        expect(page.routed_to?(log, user)).to eq(false)
      end
    end
  end
end
