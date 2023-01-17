require "rails_helper"

RSpec.describe Form::Lettings::Questions::ManagingOrganisation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("managing_organisation_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which organisation manages this letting?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Managing agent")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to be_nil
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
      let(:user) { create(:user, :data_coordinator, organisation: create(:organisation, name: "User org")) }

      let(:log) { create(:lettings_log, managing_organisation: create(:organisation, name: "Managing org 1")) }
      let!(:org_rel1) { create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: create(:organisation, name: "Managing org 2")) }
      let!(:org_rel2) { create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: create(:organisation, name: "Managing org 3")) }

      let(:options) do
        {
          "" => "Select an option",
          log.managing_organisation.id => "Managing org 1",
          user.organisation.id => "User org (Your organisation)",
          org_rel1.child_organisation.id => "Managing org 2",
          org_rel2.child_organisation.id => "Managing org 3",
        }
      end

      it "shows current managing agent at top, followed by user's org (with hint), followed by the managing agents of the user's org" do
        expect(question.displayed_answer_options(log, user)).to eq(options)
      end
    end

    context "when user is support" do
      let(:user) { create(:user, :support) }
      let(:log_owning_org) { create(:organisation, name: "Owning org") }
      let(:log) { create(:lettings_log, owning_organisation: log_owning_org, managing_organisation: create(:organisation, name: "Managing org 1"), created_by: nil) }
      let!(:org_rel1) { create(:organisation_relationship, parent_organisation: log_owning_org, child_organisation: create(:organisation, name: "Managing org 2")) }
      let!(:org_rel2) { create(:organisation_relationship, parent_organisation: log_owning_org, child_organisation: create(:organisation, name: "Managing org 3")) }

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

        it "shows current managing agent at top, followed by the current owning organisation (with hint), followed by the managing agents of the current owning organisation" do
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

        it "shows current managing agent at top, followed by the managing agents of the current owning organisation" do
          log_owning_org.update!(holds_own_stock: false)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end
    end

    context "when the owning-managing organisation relationship is deleted" do
      let(:user) { create(:user, :support) }

      let(:owning_org) { create(:organisation, name: "Owning org", holds_own_stock: true) }
      let(:managing_org) { create(:organisation, name: "Managing org", holds_own_stock: false) }
      let(:org_rel) { create(:organisation_relationship, parent_organisation: owning_org, child_organisation: managing_org) }
      let(:log) { create(:lettings_log, owning_organisation: owning_org, managing_organisation: managing_org, created_by: nil) }

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
  end

  it "is marked as derived" do
    expect(question.derived?).to be true
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
end
