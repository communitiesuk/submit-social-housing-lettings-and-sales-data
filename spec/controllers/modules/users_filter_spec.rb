require "rails_helper"

RSpec.describe Modules::UsersFilter do
  describe "filtered_users" do
    before do
      FactoryBot.create_list(:user, 5)
      FactoryBot.create(:user, name: "Joe Blogg")
      FactoryBot.create(:user, name: "Tom Blogg", active: false)
    end

    subject(:instance) { Class.new.include(described_class).new }
    let(:user_list) { User.all }

    context "when given a search term" do
      let(:search_term) { "Blogg" }

      it "filters the collection on search term and active users" do
        expect(instance.filtered_users(user_list, search_term).count).to eq(1)
      end
    end

    context "when not given a search term" do
      let(:search_term) { nil }

      it "filters the collection on active users" do
        expect(instance.filtered_users(user_list, search_term).count).to eq(6)
      end
    end
  end
end
