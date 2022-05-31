require "rails_helper"

RSpec.describe Modules::SearchFilter do
  subject(:instance) { Class.new.include(described_class).new }

  describe "filtered_collection" do
    before do
      FactoryBot.create_list(:organisation, 5)
      FactoryBot.create(:organisation, name: "Acme LTD")
    end

    let(:organisation_list) { Organisation.all }

    context "when given a search term" do
      let(:search_term) { "Acme" }

      it "filters the collection on search term" do
        expect(instance.filtered_collection(organisation_list, search_term).count).to eq(1)
      end
    end

    context "when not given a search term" do
      let(:search_term) { nil }

      it "does not filter the given collection" do
        expect(instance.filtered_collection(organisation_list, search_term).count).to eq(6)
      end
    end
  end

  describe "filtered_users" do
    before do
      FactoryBot.create_list(:user, 5)
      FactoryBot.create(:user, name: "Joe Blogg")
      FactoryBot.create(:user, name: "Tom Blogg", active: false)
    end

    let(:user_list) { User.all }

    context "when given a search term" do
      let(:search_term) { "Blogg" }

      it "filters the collection on search term" do
        expect(instance.filtered_users(user_list, search_term).count).to eq(2)
      end
    end

    context "when not given a search term" do
      let(:search_term) { nil }

      it "returns all the users" do
        expect(instance.filtered_users(user_list, search_term).count).to eq(7)
      end
    end
  end
end
