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

      it "shows stock owners with own org at the top" do
        expect(question.answer_options).to eq(options)
      end
    end

    context "when user support" do
      let!(:user) { create(:user, :support) }

      let!(:log) { create(:lettings_log) }

      let(:expected_opts) do
        Organisation.all.each_with_object(options) do |organisation, hsh|
          hsh[organisation.id] = organisation.name
          hsh
        end
      end

      it "shows all orgs" do
        expect(question.displayed_answer_options(log, user)).to eq(expected_opts)
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
