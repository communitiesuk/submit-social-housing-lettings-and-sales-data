require "rails_helper"

RSpec.describe "Schemes scheme Features" do
  context "when viewing list of schemes" do
    context "when I am signed as a coordinator user and there are schemes in the database" do
      let!(:user) { FactoryBot.create(:user, :data_coordinator, last_sign_in_at: Time.zone.now) }
      let!(:schemes) { FactoryBot.create_list(:scheme, 5, organisation: user.organisation) }
      let!(:scheme_to_search) { FactoryBot.create(:scheme, organisation: user.organisation) }

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
            expect(page).to have_content(scheme.code)
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
              fill_in("search", with: scheme_to_search.code)
              click_button("Search")
            end

            it "displays scheme matching the scheme code" do
              expect(page).to have_content(scheme_to_search.code)
            end

            context "when I want to clear results" do
              it "there is link to clear the search results" do
                expect(page).to have_link("Clear search")
              end

              it "displays all schemes after I clear the search results" do
                click_link("Clear search")
                expect(page).to have_content(scheme_to_search.code)
                schemes.each do |scheme|
                  expect(page).to have_content(scheme.code)
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

    context "when viewing list of schemes" do
      it "displays the link to the schemes" do
        expect(page).to have_link("Schemes", href: "/schemes")
      end

      context "when I click schemes" do
        before do
          click_link "Schemes", href: "/schemes"
        end

        it "shows list of schemes" do
          schemes.each do |scheme|
            expect(page).to have_content(scheme.code)
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
              fill_in("search", with: scheme_to_search.code)
              click_button("Search")
            end

            it "displays scheme matching the scheme code" do
              expect(page).to have_content(scheme_to_search.code)
            end

            context "when I want to clear results" do
              it "there is link to clear the search results" do
                expect(page).to have_link("Clear search")
              end

              it "displays all schemes after I clear the search results" do
                click_link("Clear search")
                expect(page).to have_content(scheme_to_search.code)
                schemes.each do |scheme|
                  expect(page).to have_content(scheme.code)
                end
              end
            end
          end
        end
      end
    end

    context "when viewing individual scheme" do
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

          before do
            click_link(scheme.service_name)
          end

          it "shows me details about the selected scheme" do
            expect(page).to have_content(schemes.first.code)
            expect(page).to have_content(schemes.first.service_name)
            expect(page).to have_content(schemes.first.sensitive)
            expect(page).to have_content(schemes.first.scheme_type)
            expect(page).to have_content(schemes.first.registered_under_care_act)
            expect(page).to have_content(schemes.first.total_units)
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
              expect(page).to have_link("#{scheme.locations.count} locations")
            end

            context "when I click locations link" do
              before do
                click_link("#{scheme.locations.count} locations")
              end

              it "shows details of those locations" do
                locations.each do |location|
                  expect(page).to have_content(location.location_code)
                end
              end
            end
          end
        end
      end
    end

    context "when creating a new scheme" do
      before do
        Scheme.destroy_all
        click_link "Schemes", href: "/schemes"
      end

      it "displays the link to create a new scheme" do
        expect(page).to have_current_path("/schemes")
        expect(page).to have_link("Create a new supported housing scheme")
      end

      context "when I press create a new scheme" do
        let!(:organisation) { FactoryBot.create(:organisation, name: "FooBar") }

        before do
          click_link "Create a new supported housing scheme"
        end

        it "lets me fill in the scheme details" do
          expect(page).to have_current_path("/schemes/new")
          expect(page).to have_content "Scheme name"
          expect(page).to have_content "This scheme contains confidential information"
          expect(page).to have_content "Which organisation manages this scheme"
          expect(page).to have_content "What is this type of scheme?"
          expect(page).to have_content "Is this scheme registered under the Care Standards Act 2000?"
          expect(page).to have_content "Total number of units"
        end

        context "when I fill in scheme details and I press save I see primary client group section" do
          let(:scheme) { Scheme.first }

          before do
            fill_in "Scheme name", with: "FooBar"
            check "This scheme contains confidential information"
            choose "Direct access hostel"
            choose "Yes – registered care home providing nursing care"
            fill_in "Total number of units", with: 1
            select organisation.name, from: "scheme-organisation-id-field"
            click_button "Save and continue"
          end

          it "lets me fill in the scheme details" do
            expect(page).to have_content "What client group is this scheme intended for?"
          end

          context "when I press the back button" do
            before do
              click_link "Back"
            end

            it "lets me fill in the scheme details" do
              expect(page).to have_current_path("/schemes/#{scheme.id}/details")
              expect(page).to have_content "Scheme name"
              expect(page).to have_content "This scheme contains confidential information"
              expect(page).to have_content "Which organisation manages this scheme"
              expect(page).to have_content "What is this type of scheme?"
              expect(page).to have_content "Is this scheme registered under the Care Standards Act 2000?"
              expect(page).to have_content "Total number of units"
            end
          end

          context "when I select primary client group details" do
            before do
              choose "Homeless families with support needs"
              click_button "Save and continue"
            end

            it "lets me confirm if I want to select secondary group details" do
              expect(page).to have_content "Does this scheme provide for another client group?"
            end

            context "when I press the back button" do
              before do
                click_link "Back"
              end

              it "lets me select the primary client group" do
                expect(page).to have_current_path("/schemes/#{scheme.id}/primary-client-group")
                expect(page).to have_content "What client group is this scheme intended for?"
              end
            end

            context "when I confirm the secondary group" do
              before do
                choose "Yes"
                click_button "Save and continue"
              end

              it "lets me select secondary client group" do
                expect(page).to have_content "What is the other client group?"
              end

              context "when I press the back button" do
                before do
                  click_link "Back"
                end

                it "lets me confirm the secondary group" do
                  expect(page).to have_current_path("/schemes/#{scheme.id}/confirm-secondary-client-group")
                  expect(page).to have_content "Does this scheme provide for another client group?"
                end
              end

              context "when I select the secondary group" do
                before do
                  choose "Homeless families with support needs"
                  click_button "Save and continue"
                end

                it "lets me select level of support" do
                  expect(page).to have_content "What support does this scheme provide?"
                end

                context "when I select the support answers" do
                  before do
                    choose "Floating support"
                    choose "Very short stay"
                    click_button "Save and continue"
                  end

                  it "lets me check my answers" do
                    expect(page).to have_content "Check your changes before updating this scheme"
                  end

                  context "when changing answers" do
                    it "displays change links" do
                      assert_selector "a", text: "Change", count: 12
                    end

                    it "allows changing details questions" do
                      click_link("Change", href: "/schemes/#{scheme.id}/details?check_answers=true", match: :first)
                      expect(page).to have_current_path("/schemes/#{scheme.id}/details?check_answers=true")

                      fill_in "Scheme name", with: "Example"
                      choose "Direct access hostel"
                      choose "Yes – registered care home providing nursing care"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
                      expect(page).to have_content "Example"
                      expect(page).to have_content "Yes – registered care home providing nursing care"
                    end

                    it "allows changing primary-client-group question" do
                      click_link("Change", href: "/schemes/#{scheme.id}/primary-client-group?check_answers=true")
                      expect(page).to have_current_path("/schemes/#{scheme.id}/primary-client-group?check_answers=true")

                      choose "Older people with support needs"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
                      expect(page).to have_content "Older people with support needs"
                    end

                    it "allows changing secondary-client-group question" do
                      click_link("Change", href: "/schemes/#{scheme.id}/secondary-client-group?check_answers=true")
                      expect(page).to have_current_path("/schemes/#{scheme.id}/secondary-client-group?check_answers=true")

                      choose "People at risk of domestic violence"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
                      expect(page).to have_content "People at risk of domestic violence"
                    end

                    it "allows changing confirm-secondary-client-group question to yes" do
                      click_link("Change", href: "/schemes/#{scheme.id}/confirm-secondary-client-group?check_answers=true")
                      expect(page).to have_current_path("/schemes/#{scheme.id}/confirm-secondary-client-group?check_answers=true")

                      choose "Yes"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/secondary-client-group?check_answers=true")

                      choose "People at risk of domestic violence"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
                      expect(page).to have_content "People at risk of domestic violence"
                    end

                    it "allows changing confirm-secondary-client-group question to no" do
                      click_link("Change", href: "/schemes/#{scheme.id}/confirm-secondary-client-group?check_answers=true")
                      expect(page).to have_current_path("/schemes/#{scheme.id}/confirm-secondary-client-group?check_answers=true")

                      choose "No"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
                      expect(page).to have_content "None"
                    end

                    it "allows changing support questions" do
                      click_link("Change", href: "/schemes/#{scheme.id}/support?check_answers=true", match: :first)
                      expect(page).to have_current_path("/schemes/#{scheme.id}/support?check_answers=true")

                      choose "Resettlement support"
                      choose "Medium stay"
                      click_button "Save and continue"

                      expect(page).to have_current_path("/schemes/#{scheme.id}/check-answers")
                      expect(page).to have_content "Resettlement support"
                      expect(page).to have_content "Medium stay"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
