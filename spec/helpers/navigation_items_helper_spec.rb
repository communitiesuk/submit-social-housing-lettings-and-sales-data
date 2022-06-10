require "rails_helper"

RSpec.describe NavigationItemsHelper do
  let(:current_user) { FactoryBot.create(:user, :data_coordinator) }

  let(:users_path) { "/organisations/#{current_user.organisation.id}/users" }
  let(:organisation_path) { "/organisations/#{current_user.organisation.id}" }

  describe "#primary items" do
    context "when the user is a data coordinator" do
      context "when the user is on the logs page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", true),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            NavigationItemsHelper::NavigationItem.new("Users", users_path, false),
            NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("/logs", current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on the users page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            NavigationItemsHelper::NavigationItem.new("Users", users_path, true),
            NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items(users_path, current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on their organisation details page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            NavigationItemsHelper::NavigationItem.new("Users", users_path, false),
            NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, true),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("#{organisation_path}/details", current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on the account page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
            NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("/account", current_user)).to eq(expected_navigation_items)
        end
      end
    end

    context "when the user is a support user" do
      let(:current_user) { FactoryBot.create(:user, :support) }

      context "when the user is on the logs page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
            NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", true),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("/logs", current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on the users page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
            NavigationItemsHelper::NavigationItem.new("Users", "/users", true),
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("/users", current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on the account page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
            NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("/account", current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on the supported housing page" do
        let(:expected_navigation_items) do
          [
            NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
            NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
            NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
            NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", true),
          ]
        end

        it "returns navigation items with the users item set as current" do
          expect(primary_items("/supported-housing", current_user)).to eq(expected_navigation_items)
        end
      end

      context "when the user is on the specific organisation's page" do
        context "when the user is on organisation logs page" do
          let(:required_sub_path) { "logs" }
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            ]
          end

          let(:expected_secondary_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Logs", "/organisations/#{current_user.organisation.id}/logs", true),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/organisations/#{current_user.organisation.id}/supported-housing", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About this organisation", "/organisations/#{current_user.organisation.id}", false),
            ]
          end

          it "returns navigation items with the logs item set as current" do
            expect(primary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user)).to eq(expected_navigation_items)
            expect(secondary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user.organisation.id)).to eq(expected_secondary_navigation_items)
          end
        end

        context "when the user is on organisation users page" do
          let(:required_sub_path) { "users" }
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            ]
          end

          let(:expected_secondary_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Logs", "/organisations/#{current_user.organisation.id}/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/organisations/#{current_user.organisation.id}/supported-housing", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", true),
              NavigationItemsHelper::NavigationItem.new("About this organisation", "/organisations/#{current_user.organisation.id}", false),
            ]
          end

          it "returns navigation items with the logs item set as current" do
            expect(primary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user)).to eq(expected_navigation_items)
            expect(secondary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user.organisation.id)).to eq(expected_secondary_navigation_items)
          end
        end

        context "when the user is on organisation schemes page" do
          let(:required_sub_path) { "supported-housing" }
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            ]
          end

          let(:expected_secondary_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Logs", "/organisations/#{current_user.organisation.id}/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/organisations/#{current_user.organisation.id}/supported-housing", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About this organisation", "/organisations/#{current_user.organisation.id}", false),
            ]
          end

          it "returns navigation items with the schemes item set as current" do
            expect(primary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user)).to eq(expected_navigation_items)
            expect(secondary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user.organisation.id)).to eq(expected_secondary_navigation_items)
          end
        end

        context "when the user is on organisation details page" do
          let(:required_sub_path) { "details" }
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Logs", "/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/supported-housing", false),
            ]
          end

          let(:expected_secondary_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Logs", "/organisations/#{current_user.organisation.id}/logs", false),
              NavigationItemsHelper::NavigationItem.new("Supported housing", "/organisations/#{current_user.organisation.id}/supported-housing", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About this organisation", "/organisations/#{current_user.organisation.id}", true),
            ]
          end

          it "returns navigation items with the logs item set as current" do
            expect(primary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user)).to eq(expected_navigation_items)
            expect(secondary_items("/organisations/#{current_user.organisation.id}/#{required_sub_path}", current_user.organisation.id)).to eq(expected_secondary_navigation_items)
          end
        end
      end
    end
  end
end
