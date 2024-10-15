require "rails_helper"

RSpec.describe Form::Lettings::Questions::CreatedById, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("assigned_to_id")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct answer options" do
    expect(question.answer_options).to eq({ "" => "Select an option" })
  end

  it "is marked as derived" do
    expect(question.derived?(nil)).to be true
  end

  def expected_option_for_users(users)
    users.each_with_object({ "" => "Select an option" }) do |user, obj|
      obj[user.id] = "#{user.name} (#{user.email})"
    end
  end

  context "when the current user is support" do
    let(:owning_org_user) { create(:user) }
    let(:managing_org_user) { create(:user) }
    let(:support_user) { create(:user, :support, organisation: owning_org_user.organisation) }

    describe "#displayed_answer_options" do
      let(:lettings_log) do
        create(:lettings_log, assigned_to: support_user, owning_organisation: owning_org_user.organisation, managing_organisation: managing_org_user.organisation)
      end

      it "only displays users that belong to owning and managing organisations" do
        expect(question.displayed_answer_options(lettings_log, support_user)).to eq(expected_option_for_users(managing_org_user.organisation.users + owning_org_user.organisation.users))
      end

      context "when organisation has deleted users" do
        before do
          create(:user, name: "Deleted user", discarded_at: Time.zone.yesterday, organisation: owning_org_user.organisation)
          create(:user, name: "Deleted managing user", discarded_at: Time.zone.yesterday, organisation: managing_org_user.organisation)
        end

        it "does not display deleted users" do
          expect(question.displayed_answer_options(lettings_log, support_user)).to eq(expected_option_for_users(managing_org_user.organisation.users.visible + owning_org_user.organisation.users.visible))
        end
      end
    end
  end

  context "when the current user is data_coordinator" do
    let(:managing_org_user) { create(:user) }
    let(:data_coordinator) { create(:user, :data_coordinator) }

    describe "#displayed_answer_options" do
      let(:lettings_log) do
        create(:lettings_log, assigned_to: data_coordinator, owning_organisation: data_coordinator.organisation, managing_organisation: managing_org_user.organisation)
      end

      let(:user_in_same_org) { create(:user, organisation: data_coordinator.organisation) }

      it "only displays users that belong user's org" do
        expect(question.displayed_answer_options(lettings_log, data_coordinator)).to eq(expected_option_for_users(data_coordinator.organisation.users))
      end

      context "when organisation has deleted users" do
        before do
          create(:user, name: "Deleted user", discarded_at: Time.zone.yesterday, organisation: data_coordinator.organisation)
        end

        it "does not display deleted users" do
          expect(question.displayed_answer_options(lettings_log, data_coordinator)).to eq(expected_option_for_users(data_coordinator.organisation.users.visible))
        end
      end
    end
  end
end
