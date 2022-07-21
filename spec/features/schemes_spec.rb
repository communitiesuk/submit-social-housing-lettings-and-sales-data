require "rails_helper"
require_relative "schemes_helpers"

RSpec.describe "Schemes scheme Features" do
  include SchemesHelpers
  context "when viewing list of schemes" do
    context "when I am signed as a coordinator user and there are schemes in the database" do
      let!(:user) { FactoryBot.create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
      let!(:schemes) { FactoryBot.create_list(:scheme, 5, owning_organisation: user.organisation) }
      let!(:scheme_to_search) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }

      before do
        visit("/logs")
        fill_in("user[email]", with: user.email)
        fill_in("user[password]", with: user.password)
        click_button("Sign in")
      end

      it "displays the link to the schemes" do
        expect(page).to have_link("Schemes", href: "/schemes")
      end

      context "when I click schemes" do
        before do
          click_link "Schemes", href: "/schemes"
        end

        it "shows list of schemes" do
          schemes.each do |scheme|
            expect(page).to have_content(scheme.id)
          end
        end

        context "when I search for a specific scheme" do
          it "there is a search bar with a message and search button for schemes" do
            expect(page).to have_field("search")
            expect(page).to have_content("Search by scheme name, code or postcode")
            expect(page).to have_button("Search")
          end

          context "when I fill in search information and press the search button" do
            before do
              fill_in("search", with: scheme_to_search.id_to_display)
              click_button("Search")
            end

            it "displays scheme matching the scheme code" do
              expect(page).to have_content(scheme_to_search.id_to_display)
            end

            context "when I want to clear results" do
              it "there is link to clear the search results" do
                expect(page).to have_link("Clear search")
              end

              it "displays all schemes after I clear the search results" do
                click_link("Clear search")
                expect(page).to have_content(scheme_to_search.id)
                schemes.each do |scheme|
                  expect(page).to have_content(scheme.id)
                end
              end
            end
          end
        end
      end
    end
  end

  context "when I am signed as a support user and there are schemes in the database" do
    let(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
    let!(:schemes) { FactoryBot.create_list(:scheme, 5) }
    let!(:scheme_to_search) { FactoryBot.create(:scheme) }
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:confirmation_token) { "MCDH5y6Km-U7CFPgAMVS" }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:otp) { "999111" }

    before do
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(Devise).to receive(:friendly_token).and_return(confirmation_token)
      allow(notify_client).to receive(:send_email).and_return(true)
      allow(SecureRandom).to receive(:random_number).and_return(otp)
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
    end

    it "allows navigating to the schemes from the home page" do
      expect(page).to have_link("Schemes", href: "/schemes")
    end

    context "when viewing list of schemes" do
      before do
        click_link "Schemes", href: "/schemes"
      end

      it "shows a list of schemes" do
        schemes.each do |scheme|
          expect(page).to have_content(scheme.id)
          expect(page).to have_link(scheme.service_name)
          expect(page).to have_content(scheme.primary_client_group)
        end
      end

      it "displays a search bar" do
        expect(page).to have_field("search")
        expect(page).to have_content("Search by scheme name, code or postcode")
        expect(page).to have_button("Search")
      end

      it "allows searching the schemes by scheme code" do
        fill_in("search", with: scheme_to_search.id_to_display)
        click_button("Search")
        expect(page).to have_content(scheme_to_search.id_to_display)
      end

      it "allows clearing the search results" do
        fill_in("search", with: scheme_to_search.id_to_display)
        click_button("Search")
        click_link("Clear search")
        expect(page).to have_content(scheme_to_search.id_to_display)
        schemes.each do |scheme|
          expect(page).to have_content(scheme.id_to_display)
        end
      end
    end

    context "when viewing individual scheme" do
      let!(:schemes) { FactoryBot.create_list(:scheme, 5) }

      context "when I visit schemes page" do
        before do
          visit("schemes")
        end

        context "when I click to see individual scheme" do
          let(:scheme) { schemes.first }

          before do
            click_link(scheme.service_name)
          end

          it "shows me details about the selected scheme" do
            expect(page).to have_content(schemes.first.id_to_display)
            expect(page).to have_content(schemes.first.service_name)
            expect(page).to have_content(schemes.first.sensitive)
            expect(page).to have_content(schemes.first.scheme_type)
            expect(page).to have_content(schemes.first.registered_under_care_act)
            expect(page).to have_content(schemes.first.primary_client_group)
            expect(page).to have_content(schemes.first.secondary_client_group)
            expect(page).to have_content(schemes.first.support_type)
            expect(page).to have_content(schemes.first.intended_stay)
          end

          context "when I click to go back" do
            before do
              visit("schemes")
              click_link(scheme.service_name)
            end

            it "shows list of links to schemes" do
              click_on("Back")
              schemes.each do |scheme|
                expect(page).to have_link(scheme.service_name)
                expect(page).to have_content(scheme.primary_client_group)
              end
            end
          end

          context "when there are locations that belong to the selected scheme" do
            let!(:schemes) { FactoryBot.create_list(:scheme, 5) }
            let(:scheme)     { schemes.first }
            let!(:locations) { FactoryBot.create_list(:location, 3, scheme:) }

            before do
              visit("schemes")
              click_link(scheme.service_name)
            end

            it "shows service and locations tab" do
              expect(page).to have_link("Scheme")
              expect(page).to have_link("Locations")
            end

            context "when I click locations link" do
              before do
                click_link("Locations")
              end

              it "shows details of those locations" do
                locations.each do |location|
                  expect(page).to have_content(location.id)
                  expect(page).to have_content(location.postcode)
                  expect(page).to have_content(location.units)
                  expect(page).to have_content(location.type_of_unit)
                  expect(page).to have_content(location.mobility_type)
                end
              end
            end

            context "when I search for a specific location" do
              before do
                click_link("Locations")
              end

              it "there is a search bar with a message and search button for locations" do
                expect(page).to have_field("search")
                expect(page).to have_content("Search by location name or postcode")
                expect(page).to have_button("Search")
              end

              context "when I fill in search information and press the search button" do
                let(:postcode_to_search) { "NW38RR" }
                let(:location_name_to_search) { "search name location" }
                let(:location_to_search) { FactoryBot.create(:location, postcode: postcode_to_search, name: location_name_to_search, scheme:) }

                before do
                  fill_in("search", with: location_to_search.name)
                  click_button("Search")
                end

                it "displays scheme matching the location name" do
                  expect(page).to have_content(location_name_to_search)
                end

                context "when I want to clear results" do
                  it "there is link to clear the search results" do
                    expect(page).to have_link("Clear search")
                  end

                  it "displays all schemes after I clear the search results" do
                    click_link("Clear search")
                    Location.all.each do |location|
                      expect(page).to have_content(location.name)
                    end
                  end
                end
              end
            end

            context "when the user clicks add location" do
              before do
                click_link("Locations")
                click_link("Add a location")
              end

              it "shows the new location form" do
                expect(page).to have_content("Add a location to this scheme")
              end

              context "when the user completes the new location form" do
                let(:location_name) { "Area 42" }

                before do
                  fill_in "Postcode", with: "NW1L 5DP"
                  fill_in "Location name (optional)", with: location_name
                  fill_in "Total number of units at this location", with: 1
                  choose "Bungalow"
                  choose "location-wheelchair-adaptation-no-field"
                  choose "location-add-another-location-no-field"
                  click_button "Save and continue"
                end

                it "shows the check answers page location tab" do
                  expect(page.current_url.split("/").last).to eq("check-answers#locations")
                  expect(page).to have_content(location_name)
                end
              end
            end
          end
        end
      end
    end

    context "when creating a new scheme" do
      let(:organisation_name) { "FooBar" }
      let(:scheme) { Scheme.first }

      before do
        FactoryBot.create(:organisation, name: organisation_name)
        Scheme.destroy_all
        click_link "Schemes", href: "/schemes"
      end

      it "displays the link to create a new scheme" do
        expect(page).to have_current_path("/schemes")
        expect(page).to have_link("Create a new supported housing scheme")
      end

      context "when I press create a new scheme" do
        before do
          click_link "Create a new supported housing scheme"
        end

        it "lets me fill in the scheme details" do
          expect(page).to have_current_path("/schemes/new")
          expect(page).to have_content "Scheme name"
          expect(page).to have_content "This scheme contains confidential information"
          expect(page).to have_content "Which organisation owns the housing stock for this scheme?"
          expect(page).to have_content "What is this type of scheme?"
          expect(page).to have_content "Is this scheme registered under the Care Standards Act 2000?"
          expect(page).to have_content "Who provides the support services used by this scheme?"
        end

        it "lets me fill in the primary client group" do
          fill_in_and_save_scheme_details
          expect(page).to have_content "What client group is this scheme intended for?"
        end

        it "allows to navigate back and fill in the scheme details" do
          fill_in_and_save_scheme_details
          click_link "Back"
          expect(page).to have_current_path("/schemes/#{scheme.id}/details")
          expect(page).to have_content "Scheme name"
          expect(page).to have_content "This scheme contains confidential information"
          expect(page).to have_content "What is this type of scheme?"
          expect(page).to have_content "Who provides the support services used by this scheme?"
          expect(page).to have_content "Is this scheme registered under the Care Standards Act 2000?"
        end

        it "returns to the primary client group question after amending scheme details" do
          fill_in_and_save_scheme_details
          click_link "Back"
          click_button "Save and continue"
          expect(page).to have_current_path("/schemes/#{scheme.id}/primary-client-group")
        end

        it "allows confirming if the scheme provides for secondary group details" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          expect(page).to have_content "Does this scheme provide for another client group?"
        end

        it "allows amending primary client group after navigating back from secondary client group confirmation question" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          click_link "Back"
          expect(page).to have_current_path("/schemes/#{scheme.id}/primary-client-group")
          expect(page).to have_content "What client group is this scheme intended for?"
        end

        it "returns to the secondary group details confirmation question after amending primary client group" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          click_link "Back"
          click_button "Save and continue"
          expect(page).to have_current_path("/schemes/#{scheme.id}/confirm-secondary-client-group")
        end

        it "allows selecting secondary client group if the scheme provides for it" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          fill_in_and_save_secondary_client_group_confirmation
          expect(page).to have_content "What is the other client group?"
        end

        it "allows amending secondary client group confirmation question after navigating from secondary client group question" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          fill_in_and_save_secondary_client_group_confirmation
          click_link "Back"
          expect(page).to have_current_path("/schemes/#{scheme.id}/confirm-secondary-client-group")
          expect(page).to have_content "Does this scheme provide for another client group?"
        end

        it "returns to the secondary group details question after amending secondary group details confirmation" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          fill_in_and_save_secondary_client_group_confirmation
          click_link "Back"
          click_button "Save and continue"
          expect(page).to have_current_path("/schemes/#{scheme.id}/secondary-client-group")
        end

        it "allows selecting the level of support" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          fill_in_and_save_secondary_client_group_confirmation
          fill_in_and_save_secondary_client_group
          expect(page).to have_content "What support does this scheme provide?"
        end

        it "allows amending secondary client group question after navigating from level of support" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          fill_in_and_save_secondary_client_group_confirmation
          fill_in_and_save_secondary_client_group
          click_link "Back"
          expect(page).to have_current_path("/schemes/#{scheme.id}/secondary-client-group")
          expect(page).to have_content "What is the other client group?"
        end

        it "returns to the level of support question after amending secondary group details" do
          fill_in_and_save_scheme_details
          fill_in_and_save_primary_client_group
          fill_in_and_save_secondary_client_group_confirmation
          fill_in_and_save_secondary_client_group
          click_link "Back"
          click_button "Save and continue"
          expect(page).to have_current_path("/schemes/#{scheme.id}/support")
        end

        context "when adding a location" do
          before do
            create_and_save_a_scheme
          end

          it "lets me add location" do
            expect(page).to have_content "Add a location to this scheme"
          end

          it "lets me navigate back to support questions" do
            click_link "Back"
            expect(page).to have_current_path("/schemes/#{scheme.id}/support")
            expect(page).to have_content "What support does this scheme provide?"
          end

          it "returns to the add location page after amending the support question" do
            click_link "Back"
            click_button "Save and continue"
            expect(page).to have_current_path("/schemes/#{scheme.id}/locations/new")
          end

          it "lets me check my answers after adding a location" do
            fill_in_and_save_location
            expect(page).to have_content "Check your changes before creating this scheme"
          end

          it "lets me check my answers after adding a second location" do
            fill_in_and_save_location
            click_link "Add a location"
            fill_in_and_save_second_location
            expect(page).to have_content "Check your changes before creating this scheme"
          end
        end

        context "when viewing locations" do
          before do
            create_and_save_a_scheme

            fill_in_and_save_location
            click_link "Locations"
          end

          it "displays information about a single location" do
            expect(page).to have_content "Locations"
            expect(page).to have_content "#{scheme.locations.count} location"
          end

          it "displays information about the first created location" do
            expect(page).to have_content "SW1P4DF"
            expect(page).to have_content "Some name"
            expect(page).to have_content "Self-contained house"
            expect(page).to have_content "None"
          end

          it "displays information about another location" do
            click_link "Add a location"
            fill_in_and_save_second_location
            expect(page).to have_content "Locations"
            expect(page).to have_content "#{scheme.locations.count} location"
          end

          it "displays information about newly created location" do
            click_link "Add a location"
            fill_in_and_save_second_location
            expect(page).to have_content "XX11XX"
            expect(page).to have_content "Other name"
            expect(page).to have_content "Self-contained house"
          end
        end

        context "when changing location details" do
          before do
            create_and_save_a_scheme
            fill_in_and_save_second_location
            click_link "Locations"
          end

          it "displays changed location" do
            click_link "XX11XX"
            fill_in "Postcode", with: "ZZ1 1ZZ"
            choose "location-mobility-type-wheelchair-user-standard-field"
            click_button "Save and continue"
            expect(page).to have_content "Locations"
            expect(page).to have_content "#{scheme.locations.count} location"
            expect(page).to have_content "ZZ11ZZ"
            expect(page).to have_content("Wheelchair-user standard")
          end
        end

        context "when changing scheme answers" do
          before do
            create_and_save_a_scheme
            fill_in_and_save_location
          end

          it "displays change links" do
            assert_selector "a", text: "Change", count: 13
          end

          it "allows changing details questions" do
            click_link("Change", href: "/schemes/#{scheme.id}/details?check_answers=true", match: :first)
            expect(page).to have_current_path("/schemes/#{scheme.id}/details?check_answers=true")

            fill_in "Scheme name", with: "Example"
            click_button "Save and continue"

            expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
            expect(page).to have_content "Example"
          end

          it "lets me select the support answers after navigating back" do
            click_link("Change", href: "/schemes/#{scheme.id}/details?check_answers=true", match: :first)
            click_link "Back"
            expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
            expect(page).to have_content "Check your changes before creating this scheme"
          end
        end

        context "when selecting 'create a scheme'" do
          before do
            create_and_save_a_scheme
            fill_in_and_save_location
            click_button "Create scheme"
          end

          it "adds scheme to the list of schemes" do
            expect(page).to have_content "Supported housing schemes"
            expect(page).to have_content scheme.id_to_display
            expect(page).to have_content scheme.service_name
            expect(page).to have_content scheme.owning_organisation.name
            expect(page).to have_content "#{scheme.service_name} has been created."
          end
        end

        context "when I fill in scheme details indicating that supported services provided by a different organisation and I press save I see primary client group section" do
          let(:scheme) { Scheme.first }
          let!(:another_organisation) { FactoryBot.create(:organisation, name: "Another Org") }

          before do
            fill_in_and_save_scheme_details({ "housing_stock_owners" => "Another registered housing provider" })
          end

          it "lets me fill in the managing organisation details" do
            expect(page).to have_content "Which organisation provides the support services used by this scheme?"
          end

          it "lets me fill in the scheme details after navigating back" do
            click_link "Back"
            expect(page).to have_current_path("/schemes/#{scheme.id}/details")
            expect(page).to have_content "Scheme name"
            expect(page).to have_content "This scheme contains confidential information"
            expect(page).to have_content "What is this type of scheme?"
            expect(page).to have_content "Who provides the support services used by this scheme?"
            expect(page).to have_content "Is this scheme registered under the Care Standards Act 2000?"
          end

          it "returns to the support service provider after amending the question" do
            click_link "Back"
            click_button "Save and continue"
            expect(page).to have_current_path("/schemes/#{scheme.id}/support-services-provider")
          end

          it "lets the primary client group to be selected" do
            select another_organisation.name, from: "scheme-managing-organisation-id-field"
            click_button "Save and continue"
            expect(page).to have_content "What client group is this scheme intended for?"
          end

          context "when changing scheme answers" do
            before do
              select another_organisation.name, from: "scheme-managing-organisation-id-field"
              click_button "Save and continue"
              fill_in_and_save_primary_client_group
              fill_in_and_save_secondary_client_group_confirmation
              fill_in_and_save_secondary_client_group
              fill_in_and_save_support
              fill_in_and_save_location
            end

            it "displays change links" do
              assert_selector "a", text: "Change", count: 13
            end

            it "allows changing details questions" do
              click_link("Change", href: "/schemes/#{scheme.id}/details?check_answers=true", match: :first)
              expect(page).to have_current_path("/schemes/#{scheme.id}/details?check_answers=true")

              fill_in "Scheme name", with: "Example"
              click_button "Save and continue"

              expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
              expect(page).to have_content "Example"
            end

            it "lets me select the support answers after navigating back" do
              click_link("Change", href: "/schemes/#{scheme.id}/details?check_answers=true", match: :first)
              click_link "Back"
              expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
              expect(page).to have_content "Check your changes before creating this scheme"
            end
          end
        end
      end
    end

    context "when editing a scheme" do
      context "when I visit schemes page" do
        before do
          visit("schemes")
        end

        it "shows list of links to schemes" do
          schemes.each do |scheme|
            expect(page).to have_link(scheme.service_name)
            expect(page).to have_content(scheme.primary_client_group)
          end
        end

        context "when I click to see individual scheme" do
          let(:scheme) { schemes.first }
          let!(:location) { FactoryBot.create(:location, scheme:) }

          before do
            click_link(scheme.service_name)
          end

          it "shows me details about the selected scheme" do
            expect(page).to have_content(schemes.first.id_to_display)
            expect(page).to have_content(schemes.first.service_name)
            expect(page).to have_content(schemes.first.sensitive)
            expect(page).to have_content(schemes.first.scheme_type)
            expect(page).to have_content(schemes.first.registered_under_care_act)
            expect(page).to have_content(schemes.first.primary_client_group)
            expect(page).to have_content(schemes.first.secondary_client_group)
            expect(page).to have_content(schemes.first.support_type)
            expect(page).to have_content(schemes.first.intended_stay)
          end

          context "when I click to change scheme name" do
            before do
              click_link("Change", href: "/schemes/#{scheme.id}/edit-name", match: :first)
            end

            it "shows available fields to edit" do
              expect(page).to have_current_path("/schemes/#{scheme.id}/edit-name")
              expect(page).to have_content "Scheme details"
            end

            context "when I edit details" do
              before do
                fill_in "Scheme name", with: "FooBar"
                check "This scheme contains confidential information"
                click_button "Save changes"
              end

              it "lets me see amended details on the show page" do
                expect(page).to have_content "FooBar"
                expect(page).to have_current_path("/schemes/#{scheme.id}")
              end
            end
          end

          context "when I click to see locations" do
            before do
              click_link "Locations"
            end

            it "I see location details" do
              expect(page).to have_content scheme.locations.first.id
              expect(page).to have_current_path("/schemes/#{scheme.id}/locations")
            end

            context "when I click to change location name" do
              before do
                click_link(location.postcode)
              end

              it "shows available fields to edit" do
                expect(page).to have_current_path("/schemes/#{scheme.id}/locations/#{location.id}/edit-name")
                expect(page).to have_content "Location name for #{location.postcode}"
              end

              context "when I press the back button" do
                before do
                  click_link "Back"
                end

                it "I see location details" do
                  expect(page).to have_content scheme.locations.first.id
                  expect(page).to have_current_path("/schemes/#{scheme.id}/locations")
                end
              end

              context "and I change the location name" do
                before do
                  fill_in "location-name-field", with: "NewName"
                  click_button "Save and continue"
                end

                it "returns to locations page and shows the new name" do
                  expect(page).to have_content location.id
                  expect(page).to have_content "NewName"
                  expect(page).to have_current_path("/schemes/#{scheme.id}/locations")
                end
              end
            end

            context "when I search for a specific location" do
              before do
                click_link("Locations")
              end

              it "there is a search bar with a message and search button for locations" do
                expect(page).to have_field("search")
                expect(page).to have_content("Search by location name or postcode")
                expect(page).to have_button("Search")
              end

              context "when I fill in search information and press the search button" do
                let(:postcode_to_search) { "NW38RR" }
                let(:location_name_to_search) { "search name location" }
                let(:location_to_search) { FactoryBot.create(:location, postcode: postcode_to_search, name: location_name_to_search, scheme:) }

                before do
                  fill_in("search", with: location_to_search.name)
                  click_button("Search")
                end

                it "displays scheme matching the location name" do
                  expect(page).to have_content(location_name_to_search)
                end

                context "when I want to clear results" do
                  it "there is link to clear the search results" do
                    expect(page).to have_link("Clear search")
                  end

                  it "displays all schemes after I clear the search results" do
                    click_link("Clear search")
                    Location.all.each do |location|
                      expect(page).to have_content(location.name)
                    end
                  end
                end
              end
            end

            context "when the user clicks add location" do
              before do
                click_link("Locations")
                click_link("Add a location")
              end

              it "shows the new location form" do
                expect(page).to have_content("Add a location to this scheme")
              end

              context "when the user completes the new location form" do
                let(:location_name) { "Area 42" }

                before do
                  fill_in "Postcode", with: "NW1L 5DP"
                  fill_in "Location name (optional)", with: location_name
                  fill_in "Total number of units at this location", with: 1
                  choose "Bungalow"
                  choose "location-wheelchair-adaptation-no-field"
                  choose "location-add-another-location-no-field"
                  click_button "Save and continue"
                end

                it "shows the check answers page location tab" do
                  expect(page.current_url.split("/").last).to eq("check-answers#locations")
                  expect(page).to have_content(location_name)
                end

                it "has the correct action button text" do
                  expect(page).to have_button("Save")
                  expect(page).not_to have_button("Create scheme")
                end

                context "when you click to view the scheme details" do
                  before do
                    click_link("Scheme")
                  end

                  it "does not let you change details other than the name" do
                    assert_selector "a", text: "Change", count: 1
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  context "when selecting a scheme" do
    let!(:user) { FactoryBot.create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
    let!(:schemes) { FactoryBot.create_list(:scheme, 5, owning_organisation: user.organisation) }
    let(:location) { FactoryBot.create(:location, scheme: schemes[2]) }
    let!(:case_log) { FactoryBot.create(:case_log, created_by: user, needstype: 2) }

    before do
      Timecop.freeze(Time.utc(2022, 6, 3))
      location.update!(startdate: nil)
      FactoryBot.create(:location, scheme: schemes[0], startdate: nil)
      FactoryBot.create(:location, scheme: schemes[1], startdate: nil)
      FactoryBot.create(:location, scheme: schemes[1], startdate: nil)
      FactoryBot.create(:location, scheme: schemes[1], startdate: Time.utc(2023, 6, 3))
      visit("/logs")
      fill_in("user[email]", with: user.email)
      fill_in("user[password]", with: user.password)
      click_button("Sign in")
    end

    after do
      Timecop.unfreeze
    end

    it "does not display the schemes without a location" do
      visit("/logs/#{case_log.id}/scheme")
      expect(find("#case-log-scheme-id-field").all("option").count).to eq(4)
    end

    it "does not display the schemes with a location with a startdate in the future" do
      location.update!(startdate: Time.utc(2022, 7, 4))
      visit("/logs/#{case_log.id}/scheme")
      expect(find("#case-log-scheme-id-field").all("option").count).to eq(3)
    end

    it "does display the schemes with a location with a startdate in the past" do
      location.update!(startdate: Time.utc(2022, 5, 2))
      visit("/logs/#{case_log.id}/scheme")
      expect(find("#case-log-scheme-id-field").all("option").count).to eq(4)
    end

    it "does display the schemes with a location with a startdate being today" do
      location.update!(startdate: Time.utc(2022, 6, 3))
      visit("/logs/#{case_log.id}/scheme")
      expect(find("#case-log-scheme-id-field").all("option").count).to eq(4)
    end
  end
end
