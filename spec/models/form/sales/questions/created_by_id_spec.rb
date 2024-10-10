require "rails_helper"

RSpec.describe Form::Sales::Questions::CreatedById, type: :model do
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
    expect(question.id).to eq("assigned_to_id")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
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
    let(:support_user) { build(:user, :support) }

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, support_user)).to be false
    end

    describe "#displayed_answer_options" do
      let(:owning_org_user) { create(:user) }
      let(:sales_log) { create(:sales_log, owning_organisation: owning_org_user.organisation, managing_organisation: owning_org_user.organisation) }

      it "only displays users that belong to the managing organisation" do
        expect(question.displayed_answer_options(sales_log, support_user)).to eq(expected_option_for_users(owning_org_user.organisation.users))
      end

      context "when organisation has deleted users" do
        before do
          create(:user, name: "Deleted user", discarded_at: Time.zone.yesterday, organisation: owning_org_user.organisation)
        end

        it "does not display deleted users" do
          expect(question.displayed_answer_options(sales_log, support_user)).to eq(expected_option_for_users(owning_org_user.organisation.users.visible))
        end
      end
    end
  end

  context "when the current user is data_coordinator" do
    let(:data_coordinator) { create(:user, :data_coordinator) }

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, data_coordinator)).to be false
    end

    describe "#displayed_answer_options" do
      let(:owning_org_user) { create(:user) }
      let(:sales_log) { create(:sales_log, owning_organisation: owning_org_user.organisation, managing_organisation: owning_org_user.organisation) }

      before do
        create(:user, organisation: data_coordinator.organisation)
      end

      it "only displays users that belong to managing organisation" do
        expect(question.displayed_answer_options(sales_log, data_coordinator)).to eq(expected_option_for_users(owning_org_user.organisation.users))
      end

      context "when organisation has deleted users" do
        before do
          create(:user, name: "Deleted user", discarded_at: Time.zone.yesterday, organisation: owning_org_user.organisation)
        end

        it "does not display deleted users" do
          expect(question.displayed_answer_options(sales_log, data_coordinator)).to eq(expected_option_for_users(owning_org_user.organisation.users.visible))
        end
      end
    end
  end
end
