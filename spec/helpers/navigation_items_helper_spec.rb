require "rails_helper"

RSpec.describe NavigationItemsHelper do
  let(:current_user) { FactoryBot.create(:user, :data_coordinator) }

  let(:users_path) { "/organisations/#{current_user.organisation.id}/users" }
  let(:organisation_path) { "/organisations/#{current_user.organisation.id}" }

  describe "#primary items" do
    context "when the sales log feature flag is enabled" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      context "when the user is a data coordinator" do
        context "when the user is on the logs page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", true),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", users_path, false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/lettings-logs", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the users page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/account", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual user's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", true),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/users/1", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual scheme's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with Schemes item set as current" do
            expect(primary_items("/schemes/1", current_user)).to eq(expected_navigation_items)
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", true),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/lettings-logs", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the users page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", true),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/account", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the Schemes page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/schemes", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual user's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", true),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/users/1", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual scheme's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
            ]
          end

          let(:expected_scheme_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Scheme", "/schemes/1", true),
              NavigationItemsHelper::NavigationItem.new("Locations", "/schemes/1/locations", false),
            ]
          end

          it "returns navigation items with Schemes item set as current" do
            expect(primary_items("/schemes/1", current_user)).to eq(expected_navigation_items)
            expect(scheme_items("/schemes/1", 1, "Locations")).to eq(expected_scheme_items)
          end
        end

        context "when the user is on the scheme locations page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
            ]
          end

          let(:expected_scheme_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Scheme", "/schemes/1", false),
              NavigationItemsHelper::NavigationItem.new("Locations", "/schemes/1/locations", true),
            ]
          end

          it "returns navigation items with Schemes item set as current" do
            expect(primary_items("/schemes/1/locations", current_user)).to eq(expected_navigation_items)
            expect(scheme_items("/schemes/1/locations", 1, "Locations")).to eq(expected_scheme_items)
          end
        end

        context "when the user is on the specific organisation's page" do
          context "when the user is on organisation logs page" do
            let(:required_sub_path) { "lettings-logs" }
            let(:expected_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
                NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", true),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", false),
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
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", false),
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
            let(:required_sub_path) { "schemes" }
            let(:expected_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
                NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", true),
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
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", false),
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

    context "when the sales log feature flag is disabled" do
      context "when the user is a data coordinator" do
        context "when the user is on the lettings logs page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", true),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", users_path, false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/lettings-logs", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the sales logs page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", true),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", users_path, false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/sales-logs", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the users page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/account", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual user's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", true),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/users/1", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual scheme's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
              NavigationItemsHelper::NavigationItem.new("Users", "/organisations/#{current_user.organisation.id}/users", false),
              NavigationItemsHelper::NavigationItem.new("About your organisation", organisation_path, false),
            ]
          end

          it "returns navigation items with Schemes item set as current" do
            expect(primary_items("/schemes/1", current_user)).to eq(expected_navigation_items)
          end
        end
      end

      context "when the user is a support user" do
        let(:current_user) { FactoryBot.create(:user, :support) }

        context "when the user is on the lettings logs page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", true),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/lettings-logs", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the sales logs page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", true),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/sales-logs", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the users page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", true),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
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
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/account", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the Schemes page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/schemes", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual user's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", true),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
            ]
          end

          it "returns navigation items with the users item set as current" do
            expect(primary_items("/users/1", current_user)).to eq(expected_navigation_items)
          end
        end

        context "when the user is on the individual scheme's page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
            ]
          end

          let(:expected_scheme_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Scheme", "/schemes/1", true),
              NavigationItemsHelper::NavigationItem.new("Locations", "/schemes/1/locations", false),
            ]
          end

          it "returns navigation items with Schemes item set as current" do
            expect(primary_items("/schemes/1", current_user)).to eq(expected_navigation_items)
            expect(scheme_items("/schemes/1", 1, "Locations")).to eq(expected_scheme_items)
          end
        end

        context "when the user is on the scheme locations page" do
          let(:expected_navigation_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", false),
              NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
              NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
              NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
              NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", true),
            ]
          end

          let(:expected_scheme_items) do
            [
              NavigationItemsHelper::NavigationItem.new("Scheme", "/schemes/1", false),
              NavigationItemsHelper::NavigationItem.new("Locations", "/schemes/1/locations", true),
            ]
          end

          it "returns navigation items with Schemes item set as current" do
            expect(primary_items("/schemes/1/locations", current_user)).to eq(expected_navigation_items)
            expect(scheme_items("/schemes/1/locations", 1, "Locations")).to eq(expected_scheme_items)
          end
        end

        context "when the user is on the specific organisation's page" do
          context "when the user is on organisation logs page" do
            let(:required_sub_path) { "lettings-logs" }
            let(:expected_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
                NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", true),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/organisations/#{current_user.organisation.id}/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", false),
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
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/organisations/#{current_user.organisation.id}/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", false),
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
            let(:required_sub_path) { "schemes" }
            let(:expected_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
                NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/organisations/#{current_user.organisation.id}/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", true),
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
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/schemes", false),
              ]
            end

            let(:expected_secondary_navigation_items) do
              [
                NavigationItemsHelper::NavigationItem.new("Lettings Logs", "/organisations/#{current_user.organisation.id}/lettings-logs", false),
                NavigationItemsHelper::NavigationItem.new("Sales logs", "/organisations/#{current_user.organisation.id}/sales-logs", false),
                NavigationItemsHelper::NavigationItem.new("Schemes", "/organisations/#{current_user.organisation.id}/schemes", false),
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
end
