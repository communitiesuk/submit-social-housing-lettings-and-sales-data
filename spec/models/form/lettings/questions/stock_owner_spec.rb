require "rails_helper"

RSpec.describe Form::Lettings::Questions::StockOwner, type: :model do
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
    expect(question.id).to eq("owning_organisation_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which organisation owns this property?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Stock owner")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to be_nil
  end

  describe "answer options" do
    let(:options) { { "" => "Select an option" } }

    context "when current_user nil" do
      it "shows default options" do
        expect(question.answer_options).to eq(options)
      end
    end

    context "when user is not support" do
      let(:user_org) { create(:organisation, name: "User org") }
      let(:user) { create(:user, :data_coordinator, organisation: user_org) }

      let(:owning_org_1) { create(:organisation, name: "Owning org 1") }
      let(:owning_org_2) { create(:organisation, name: "Owning org 2") }
      let!(:org_rel) do
        create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: owning_org_2)
      end
      let(:log) { create(:lettings_log, owning_organisation: owning_org_1) }

      context "when user's org owns stock" do
        let(:options) do
          {
            "" => "Select an option",
            owning_org_1.id => "Owning org 1",
            user.organisation.id => "User org (Your organisation)",
            owning_org_2.id => "Owning org 2",
          }
        end

        it "shows current stock owner at top, followed by user's org (with hint), followed by the stock owners of the user's org" do
          user.organisation.update!(holds_own_stock: true)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end

        context "when the owning-managing organisation relationship is deleted" do
          let(:options) do
            {
              "" => "Select an option",
              user.organisation.id => "User org (Your organisation)",
              owning_org_2.id => "Owning org 2",
            }
          end

          it "doesn't remove the housing provider from the list of allowed housing providers" do
            log.update!(owning_organisation: owning_org_2)
            expect(question.displayed_answer_options(log, user)).to eq(options)
            org_rel.destroy!
            expect(question.displayed_answer_options(log, user)).to eq(options)
          end
        end
      end

      context "when user's org doesn't own stock" do
        let(:options) do
          {
            "" => "Select an option",
            owning_org_1.id => "Owning org 1",
            owning_org_2.id => "Owning org 2",
          }
        end

        it "shows current stock owner at top, followed by the stock owners of the user's org" do
          user.organisation.update!(holds_own_stock: false)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has recently absorbed other orgs" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            user.organisation.id => "User org (Your organisation, active as of 2 February 2021)",
            owning_org_2.id => "Owning org 2",
            owning_org_1.id => "Owning org 1",
            merged_organisation.id => "Merged org (inactive as of 2 February 2023)",
          }
        end

        before do
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: user.organisation)
          user.organisation.update!(created_at: Time.zone.local(2021, 2, 2))
        end

        it "shows merged organisation as an option" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has recently absorbed other orgs with parent organisations" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            user.organisation.id => "User org (Your organisation, active as of 2 February 2021)",
            owning_org_1.id => "Owning org 1",
            merged_organisation.id => "Merged org (inactive as of 2 February 2023)",
          }
        end

        before do
          org_rel.update!(child_organisation: merged_organisation)
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: user.organisation)
          user.organisation.update!(created_at: Time.zone.local(2021, 2, 2))
        end

        it "does not show merged organisations stock owners as options" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has absorbed other orgs with parent organisations during closed collection periods" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            user.organisation.id => "User org (Your organisation)",
            owning_org_1.id => "Owning org 1",
          }
        end

        before do
          Timecop.freeze(Time.zone.local(2023, 4, 2))
          org_rel.update!(child_organisation: merged_organisation)
          merged_organisation.update!(merge_date: Time.zone.local(2021, 6, 2), absorbing_organisation: user.organisation)
          user.organisation.update!(created_at: Time.zone.local(2021, 2, 2))
        end

        it "shows merged organisation as an option" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end
    end

    context "when user is support" do
      let(:user) { create(:user, :support) }

      let(:log) { create(:lettings_log) }

      let(:non_stock_organisation) { create(:organisation, holds_own_stock: false) }
      let(:expected_opts) do
        Organisation.where(holds_own_stock: true).each_with_object(options) do |organisation, hsh|
          hsh[organisation.id] = organisation.name
          hsh
        end
      end

      it "shows orgs where organisation holds own stock" do
        expect(question.displayed_answer_options(log, user)).to eq(expected_opts)
        expect(question.displayed_answer_options(log, user)).not_to include(non_stock_organisation.id)
      end
    end
  end

  it "is marked as derived" do
    expect(question.derived?).to be true
  end

  describe "#hidden_in_check_answers?" do
    context "when support" do
      let(:user) { create(:user, :support) }

      it "is not hidden in check answers" do
        expect(question.hidden_in_check_answers?(nil, user)).to be false
      end
    end

    context "when org holds own stock", :aggregate_failures do
      let(:user) { create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: true)) }

      context "when stock owners == 0" do
        before do
          user.organisation.stock_owners.delete_all
        end

        it "is hidden in check answers" do
          expect(user.organisation.stock_owners.count).to eq(0)
          expect(question.hidden_in_check_answers?(nil, user)).to be true
        end
      end

      context "when stock owners != 0" do
        before do
          create(:organisation_relationship, child_organisation: user.organisation)
        end

        it "is visible in check answers" do
          expect(user.organisation.stock_owners.count).to eq(1)
          expect(question.hidden_in_check_answers?(nil, user)).to be false
        end
      end
    end

    context "when org does not hold own stock", :aggregate_failures do
      let(:user) { create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: false)) }

      context "when stock owners <= 1" do
        before do
          create(:organisation_relationship, child_organisation: user.organisation)
        end

        it "is hidden in check answers" do
          expect(user.organisation.stock_owners.count).to eq(1)
          expect(question.hidden_in_check_answers?(nil, user)).to be true
        end
      end

      context "when stock owners >= 2" do
        before do
          create(:organisation_relationship, child_organisation: user.organisation)
          create(:organisation_relationship, child_organisation: user.organisation)
        end

        it "is visible in check answers" do
          expect(user.organisation.stock_owners.count).to eq(2)
          expect(question.hidden_in_check_answers?(nil, user)).to be false
        end
      end
    end
  end
end
