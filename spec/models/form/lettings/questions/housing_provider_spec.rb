require "rails_helper"

RSpec.describe Form::Lettings::Questions::HousingProvider, type: :model do
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
    expect(question.check_answer_label).to eq("Housing provider")
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

    context "when user not support and owns own stock" do
      let(:user) { create(:user, :data_coordinator, organisation: create(:organisation, holds_own_stock: true)) }
      let(:options) do
        {
          "" => "Select an option",
          user.organisation.id => "#{user.organisation.name} (Your organisation)",
        }
      end

      before do
        question.current_user = user
      end

      it "shows housing providers with own org at the top" do
        expect(question.answer_options).to eq(options)
      end
    end

    context "when user support" do
      before do
        question.current_user = create(:user, :support)
      end

      let(:expected_opts) do
        Organisation.all.each_with_object(options) do |organisation, hsh|
          hsh[organisation.id] = organisation.name
          hsh
        end
      end

      it "shows all orgs" do
        expect(question.answer_options).to eq(expected_opts)
      end
    end
  end

  it "is marked as derived" do
    expect(question.derived?).to be true
  end

  describe "#hidden_in_check_answers?" do
    let(:user) { create(:user) }

    context "when housing providers >= 2" do
      it "is shown in check answers" do
        expect(question.hidden_in_check_answers?(nil, user)).to be true
      end
    end

    context "when housing providers < 2" do
      before do
        create(:organisation_relationship, :owning, child_organisation: user.organisation)
        create(:organisation_relationship, :owning, child_organisation: user.organisation)
      end

      it "is not shown in check answers" do
        expect(question.hidden_in_check_answers?(nil, user)).to be false
      end
    end
  end
end
