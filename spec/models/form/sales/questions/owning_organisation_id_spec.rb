require "rails_helper"

RSpec.describe Form::Sales::Questions::OwningOrganisationId, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:user) { FactoryBot.create(:user, :data_coordinator) }
  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let!(:organisation_1) { FactoryBot.create(:organisation, name: "first test org") }
  let!(:organisation_2) { FactoryBot.create(:organisation, name: "second test org") }
  let(:lettings_log) { FactoryBot.create(:lettings_log) }
  let(:expected_answer_options) do
    {
      "" => "Select an option",
      organisation_1.id => organisation_1.name,
      organisation_2.id => organisation_2.name,
    }
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("owning_organisation_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which organisation owns this log?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Owning organisation")
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
      let(:non_stock_owner) { create(:organisation, name: "Non stock owner", holds_own_stock: false) }
      let(:log) { create(:lettings_log, owning_organisation: owning_org_1) }

      context "when user's org owns stock" do
        before do
          create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: owning_org_2)
          create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: non_stock_owner)
        end

        let(:options) do
          {
            "" => "Select an option",
            owning_org_1.id => "Owning org 1",
            owning_org_2.id => "Owning org 2",
            user.organisation.id => "User org (Your organisation)",
          }
        end

        it "shows user organisation, current owning organisation and the stock owners that hold their stock" do
          user.organisation.update!(holds_own_stock: true)
          expect(question.displayed_answer_options(log, user)).to eq(options)
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

        before do
          create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: owning_org_2)
          create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: non_stock_owner)
        end

        it "shows current owning organisation and the stock owners that hold their stock" do
          user.organisation.update!(holds_own_stock: false)
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has recently absorbed other orgs" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            user.organisation.id => "User org (Your organisation)",
            owning_org_1.id => "Owning org 1",
            merged_organisation.id => "Merged org (inactive as of 2 February 2023)",
          }
        end

        before do
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: user.organisation)
          Timecop.freeze(Time.zone.local(2023, 11, 10))
        end

        after do
          Timecop.return
        end

        it "shows merged organisation as an option" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has recently absorbed other orgs and it has available from date" do
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
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: user.organisation)
          user.organisation.update!(available_from: Time.zone.local(2021, 2, 2))
          Timecop.freeze(Time.zone.local(2023, 11, 10))
        end

        after do
          Timecop.return
        end

        it "shows available from date if it is given" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has recently absorbed other orgs with parent organisations" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            user.organisation.id => "User org (Your organisation)",
            owning_org_1.id => "Owning org 1",
            merged_organisation.id => "Merged org (inactive as of 2 February 2023)",
          }
        end

        before do
          create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: merged_organisation)
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: user.organisation)
          Timecop.freeze(Time.zone.local(2023, 11, 10))
        end

        after do
          Timecop.return
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
            merged_organisation.id => "Merged org",
            owning_org_1.id => "Owning org 1",
          }
        end

        before do
          Timecop.freeze(Time.zone.local(2023, 4, 2))
          create(:organisation_relationship, child_organisation: user.organisation, parent_organisation: merged_organisation)
          merged_organisation.update!(merge_date: Time.zone.local(2021, 6, 2), absorbing_organisation: user.organisation)
          user.organisation.update!(available_from: Time.zone.local(2021, 2, 2))
        end

        it "shows merged organisation as an option" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end
    end

    context "when user is support" do
      let(:user) { create(:user, :support, organisation: organisation_1) }

      let(:log) { create(:lettings_log, created_by: user) }

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

      context "when an org has recently absorbed other orgs" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            organisation_1.id => "first test org (active as of 2 February 2021)",
            organisation_2.id => "second test org",
            merged_organisation.id => "Merged org (inactive as of 2 February 2023)",
          }
        end

        before do
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: organisation_1)
          organisation_1.update!(created_at: Time.zone.local(2021, 3, 2), available_from: Time.zone.local(2021, 2, 2))
          Timecop.freeze(Time.zone.local(2023, 11, 10))
        end

        after do
          Timecop.return
        end

        it "shows merged organisation as an option" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when user's org has absorbed other orgs during closed collection periods" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            organisation_1.id => "first test org",
            organisation_2.id => "second test org",
          }
        end

        before do
          Timecop.freeze(Time.zone.local(2023, 4, 2))
          merged_organisation.update!(merge_date: Time.zone.local(2021, 6, 2), absorbing_organisation: user.organisation)
          user.organisation.update!(created_at: Time.zone.local(2021, 2, 2))
        end

        it "shows merged organisation as an option" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end

      context "when an existing org has recently absorbed other orgs" do
        let(:merged_organisation) { create(:organisation, name: "Merged org") }
        let(:options) do
          {
            "" => "Select an option",
            organisation_1.id => "first test org",
            organisation_2.id => "second test org",
            merged_organisation.id => "Merged org (inactive as of 2 February 2023)",
          }
        end

        before do
          merged_organisation.update!(merge_date: Time.zone.local(2023, 2, 2), absorbing_organisation: organisation_1)
          organisation_1.update!(created_at: Time.zone.local(2021, 2, 2), available_from: nil)
          Timecop.freeze(Time.zone.local(2023, 11, 10))
        end

        after do
          Timecop.return
        end

        it "does not show abailable from for absorbing organisation" do
          expect(question.displayed_answer_options(log, user)).to eq(options)
        end
      end
    end
  end

  it "is marked as derived" do
    expect(question.derived?).to be true
  end

  context "when the current user is support" do
    let(:support_user) { FactoryBot.build(:user, :support) }

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, support_user)).to be false
    end
  end

  context "when the current user is not support" do
    let(:user) { FactoryBot.build(:user) }

    it "is not shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, user)).to be true
    end
  end

  context "when the question is not answered" do
    it "returns 'select an option' as selected answer" do
      lettings_log.update!(owning_organisation: nil)
      answers = question.displayed_answer_options(lettings_log).map { |key, value| OpenStruct.new(id: key, name: nil, resource: value) }
      answers.each do |answer|
        if answer.resource == "Select an option"
          expect(question.answer_selected?(lettings_log, answer)).to eq(true)
        else
          expect(question.answer_selected?(lettings_log, answer)).to eq(false)
        end
      end
    end
  end

  context "when the question is answered" do
    it "returns 'select an option' as selected answer" do
      lettings_log.update!(owning_organisation: organisation_1)
      answers = question.displayed_answer_options(lettings_log).map { |key, value| OpenStruct.new(id: key, name: value.respond_to?(:service_name) ? value.service_name : nil, resource: value) }
      answers.each do |answer|
        if answer.id == organisation_1.id
          expect(question.answer_selected?(lettings_log, answer)).to eq(true)
        else
          expect(question.answer_selected?(lettings_log, answer)).to eq(false)
        end
      end
    end
  end
end
