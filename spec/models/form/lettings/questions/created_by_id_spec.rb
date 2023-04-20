require "rails_helper"

RSpec.describe Form::Lettings::Questions::CreatedById, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let(:user_1) { create(:user, name: "first user") }
  let(:user_2) { create(:user, name: "second user") }
  let(:user_3) { create(:user, name: "third user") }
  let!(:expected_answer_options) do
    {
      "" => "Select an option",
      user_1.id => "#{user_1.name} (#{user_1.email})",
      user_2.id => "#{user_2.name} (#{user_2.email})",
    }
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("created_by_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which user are you creating this log for?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Log owner")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to be_nil
  end

  it "has the correct answer options" do
    expect(question.answer_options).to eq(expected_answer_options)
  end

  it "is marked as derived" do
    expect(question.derived?).to be true
  end

  context "when the current user is support" do
    let(:owning_org_user) { create(:user) }
    let(:managing_org_user) { create(:user) }
    let(:support_user) { create(:user, :support, organisation: owning_org_user.organisation) }

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, support_user)).to be false
    end

    describe "#displayed_answer_options" do
      let(:lettings_log) do
        create(:lettings_log, created_by: support_user, owning_organisation: owning_org_user.organisation, managing_organisation: managing_org_user.organisation)
      end

      let(:expected_answer_options) do
        {
          "" => "Select an option",
          managing_org_user.id => "#{managing_org_user.name} (#{managing_org_user.email})",
          owning_org_user.id => "#{owning_org_user.name} (#{owning_org_user.email})",
          support_user.id => "#{support_user.name} (#{support_user.email})",
        }
      end

      it "only displays users that belong to owning and managing organisations" do
        expect(question.displayed_answer_options(lettings_log, support_user)).to eq(expected_answer_options)
      end
    end
  end

  context "when the current user is data_coordinator" do
    let(:managing_org_user) { create(:user) }
    let(:data_coordinator) { create(:user, :data_coordinator) }

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, data_coordinator)).to be false
    end

    describe "#displayed_answer_options" do
      let(:lettings_log) do
        create(:lettings_log, created_by: data_coordinator, owning_organisation: data_coordinator.organisation, managing_organisation: managing_org_user.organisation)
      end

      let(:user_in_same_org) { create(:user, organisation: data_coordinator.organisation) }

      let(:expected_answer_options) do
        {
          "" => "Select an option",
          data_coordinator.id => "#{data_coordinator.name} (#{data_coordinator.email})",
        }
      end

      it "only displays users that belong user's org" do
        expect(question.displayed_answer_options(lettings_log, data_coordinator)).to eq(expected_answer_options)
      end
    end
  end

  context "when the current user is data_provider" do
    let(:data_provider) { create(:user, :data_provider) }

    it "is not shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, data_provider)).to be true
    end

    describe "#displayed_answer_options" do
      let(:owning_org_user) { create(:user) }
      let(:lettings_log) { create(:lettings_log, owning_organisation: owning_org_user.organisation) }
      let(:user_in_same_org) { create(:user, organisation: data_provider.organisation) }

      let(:expected_answer_options) do
        {
          "" => "Select an option",
          user_in_same_org.id => "#{user_in_same_org.name} (#{user_in_same_org.email})",
          data_provider.id => "#{data_provider.name} (#{data_provider.email})",
        }
      end

      it "only displays users that belong user's org" do
        expect(question.displayed_answer_options(lettings_log, data_provider)).to eq(Form::Lettings::Questions::CreatedById::ANSWER_OPTS)
      end
    end
  end
end
