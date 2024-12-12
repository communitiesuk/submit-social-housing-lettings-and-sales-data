require "rails_helper"

RSpec.describe Form::Lettings::Questions::ManagingOrganisation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("managing_organisation_id")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  describe "#displayed_answer_options" do
    let(:options) { { "" => "Select an option" } }

    context "when current_user nil" do
      let(:log) { create(:lettings_log) }

      it "shows default options" do
        expect(question.displayed_answer_options(log, nil)).to eq(options)
      end
    end

    context "when log nil" do
      let(:user) { create(:user) }

      it "shows default options" do
        expect(question.displayed_answer_options(nil, user)).to eq(options)
      end
    end

    context "when user is not support" do
      let(:user_org) { create(:organisation, name: "User org") }
      let(:user) { create(:user, :data_coordinator, organisation: user_org) }

      let(:managing_org1) { create(:organisation, name: "Managing org 1") }
      let(:managing_org2) { create(:organisation, name: "Managing org 2") }
      let(:managing_org3) { create(:organisation, name: "Managing org 3") }
      let(:inactive_managing_org) { create(:organisation, name: "Inactive managing org", active: false) }
      let(:deleted_managing_org) { create(:organisation, name: "Deleted managing org", discarded_at: Time.zone.yesterday) }

      let(:log) { create(:lettings_log, managing_organisation: managing_org1) }
      let!(:org_rel1) do
        create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: managing_org2)
      end
      let!(:org_rel2) do
        create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: managing_org3)
      end

      let(:options) do
        {
          "" => "Select an option",
          log.managing_organisation.id => "Managing org 1",
          user.organisation.id => "User org (Your organisation)",
          org_rel1.child_organisation.id => "Managing org 2",
          org_rel2.child_organisation.id => "Managing org 3",
        }
      end

      it "shows current managing agent at top, followed by user's org (with hint), followed by the active managing agents of the user's org" do
        create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: inactive_managing_org)
        create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: deleted_managing_org)

        expect(question.displayed_answer_options(log, user)).to eq(options)
      end
    end

    context "when user is support" do
      let(:user) { create(:user, :support) }
      let(:log_owning_org) { create(:organisation, name: "Owning org") }

      let(:managing_org1) { create(:organisation, name: "Managing org 1") }
      let(:managing_org2) { create(:organisation, name: "Managing org 2") }
      let(:managing_org3) { create(:organisation, name: "Managing org 3") }

      let(:log) do
        create(:lettings_log, owning_organisation: log_owning_org, managing_organisation: managing_org1,
                              assigned_to: nil)
      end
      let!(:org_rel1) do
        create(:organisation_relationship, parent_organisation: log_owning_org, child_organisation: managing_org2)
      end
      let!(:org_rel2) do
        create(:organisation_relationship, parent_organisation: log_owning_org, child_organisation: managing_org3)
      end

      before do
        inactive_managing_org = create(:organisation, name: "Inactive managing org", active: false)
        create(:organisation_relationship, parent_organisation: log_owning_org, child_organisation: inactive_managing_org)
        deleted_managing_org = create(:organisation, name: "Deleted managing org", discarded_at: Time.zone.yesterday)
        create(:organisation_relationship, parent_organisation: log_owning_org, child_organisation: deleted_managing_org)
      end

      context "when org owns stock" do
        let(:options) do
          {
            "" => "Select an option",
            log.managing_organisation.id => "Managing org 1",
            log_owning_org.id => "Owning org (Owning organisation)",
            org_rel1.child_organisation.id => "Managing org 2",
            org_rel2.child_organisation.id => "Managing org 3",
          }
        end

        it "shows current managing agent at top, followed by the current owning organisation (with hint), followed by the active managing agents of the current owning organisation" do
          log_owning_org.update!(holds_own_stock: true)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when org owns stock and has merged managing agents" do
        let(:options) do
          {
            "" => "Select an option",
            log.managing_organisation.id => "Managing org 1",
            log_owning_org.id => "Owning org (Owning organisation)",
            org_rel1.child_organisation.id => "Managing org 2 (inactive as of 2 August 2023)",
            org_rel2.child_organisation.id => "Managing org 3 (inactive as of 2 August 2023)",
          }
        end

        before do
          org_rel1.child_organisation.update!(merge_date: Time.zone.local(2023, 8, 2), absorbing_organisation_id: log_owning_org.id)
          org_rel2.child_organisation.update!(merge_date: Time.zone.local(2023, 8, 2), absorbing_organisation_id: log_owning_org.id)
        end

        it "shows current managing agent at top, followed by the current owning organisation (with hint), followed by the active managing agents of the current owning organisation" do
          log_owning_org.update!(holds_own_stock: true)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when org does not own stock" do
        let(:options) do
          {
            "" => "Select an option",
            log.managing_organisation.id => "Managing org 1",
            org_rel1.child_organisation.id => "Managing org 2",
            org_rel2.child_organisation.id => "Managing org 3",
          }
        end

        it "shows current managing agent at top, followed by the active managing agents of the current owning organisation" do
          log_owning_org.update!(holds_own_stock: false)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end
    end

    context "when the owning-managing organisation relationship is deleted" do
      let(:user) { create(:user, :support) }

      let(:owning_org) { create(:organisation, name: "Owning org", holds_own_stock: true) }
      let(:managing_org) { create(:organisation, name: "Managing org", holds_own_stock: false) }
      let(:org_rel) do
        create(:organisation_relationship, parent_organisation: owning_org, child_organisation: managing_org)
      end
      let(:log) do
        create(:lettings_log, owning_organisation: owning_org, managing_organisation: managing_org, assigned_to: nil)
      end

      let(:options) do
        {
          "" => "Select an option",
          owning_org.id => "Owning org (Owning organisation)",
          managing_org.id => "Managing org",
        }
      end

      it "doesn't remove the managing org from the list of allowed managing orgs" do
        org_rel.destroy!
        expect(question.displayed_answer_options(log, user)).to eq(options)
      end
    end

    context "when organisation has merged" do
      let(:absorbing_org) { create(:organisation, name: "Absorbing org", holds_own_stock: true) }
      let!(:merged_org) { create(:organisation, name: "Merged org", holds_own_stock: false) }
      let!(:merged_deleted_org) { create(:organisation, name: "Merged org 2", holds_own_stock: false, discarded_at: Time.zone.yesterday) }
      let(:user) { create(:user, :data_coordinator, organisation: absorbing_org) }

      let(:log) do
        merged_org.update!(merge_date: Time.zone.local(2023, 8, 2), absorbing_organisation_id: absorbing_org.id)
        merged_deleted_org.update!(merge_date: Time.zone.local(2023, 8, 2), absorbing_organisation_id: absorbing_org.id)
        create(:lettings_log, owning_organisation: absorbing_org, managing_organisation: nil)
      end

      it "displays merged organisation on the list of choices" do
        options = {
          "" => "Select an option",
          absorbing_org.id => "Absorbing org (Your organisation)",
          merged_org.id => "Merged org (inactive as of 2 August 2023)",
          merged_org.id => "Merged org (inactive as of 2 August 2023)",
        }
        expect(question.displayed_answer_options(log, user)).to eq(options)
      end

      it "displays active date for absorbing organisation if available from is given" do
        absorbing_org.update!(available_from: Time.zone.local(2023, 8, 3))
        options = {
          "" => "Select an option",
          absorbing_org.id => "Absorbing org (Your organisation, active as of 3 August 2023)",
          merged_org.id => "Merged org (inactive as of 2 August 2023)",
          merged_org.id => "Merged org (inactive as of 2 August 2023)",
        }
        expect(question.displayed_answer_options(log, user)).to eq(options)
      end

      it "displays managing agents of merged organisation selected as owning org" do
        managing_agent = create(:organisation, name: "Managing org 1")
        create(:organisation_relationship, parent_organisation: merged_org, child_organisation: managing_agent)

        options = {
          "" => "Select an option",
          merged_org.id => "Merged org (inactive as of 2 August 2023)",
          absorbing_org.id => "Absorbing org (Your organisation)",
          managing_agent.id => "Managing org 1",
        }

        log.update!(owning_organisation: merged_org)
        expect(question.displayed_answer_options(log, user)).to eq(options)
      end
    end
  end

  it "is marked as derived" do
    expect(question.derived?(nil)).to be true
  end

  describe "#hidden_in_check_answers?" do
    before do
      allow(page).to receive(:routed_to?).and_return(true)
    end

    context "when user present" do
      let(:user) { create(:user) }

      it "is hidden in check answers" do
        expect(question.hidden_in_check_answers?(nil, user)).to be false
      end
    end

    context "when user not provided" do
      it "is not hidden in check answers" do
        expect(question.hidden_in_check_answers?(nil)).to be true
      end
    end

    context "when the page is not routed to" do
      let(:user) { create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: true)) }
      let(:log) { create(:lettings_log, owning_organisation: user.organisation) }

      before do
        allow(page).to receive(:routed_to?).and_return(false)
      end

      it "is hidden in check answers" do
        expect(question.hidden_in_check_answers?(log, user)).to be true
      end
    end
  end

  describe "#answer_label" do
    context "when answered" do
      let(:managing_organisation) { create(:organisation) }
      let(:log) { create(:lettings_log, managing_organisation:) }

      it "returns org name" do
        expect(question.answer_label(log)).to eq(managing_organisation.name)
      end
    end

    context "when unanswered" do
      let(:log) { create(:lettings_log, managing_organisation: nil) }

      it "returns nil" do
        expect(question.answer_label(log)).to be_nil
      end
    end

    context "when org does not exist" do
      let(:managing_organisation) { create(:organisation) }
      let(:log) { create(:lettings_log, managing_organisation:) }

      before do
        allow(Organisation).to receive(:find_by).and_return(nil)
      end

      it "returns nil" do
        expect(question.answer_label(log)).to be_nil
      end
    end
  end
end
