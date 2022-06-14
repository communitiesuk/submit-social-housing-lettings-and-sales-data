require "rails_helper"

RSpec.describe "Supported housing scheme Features" do
  context "when viewing list of schemes" do
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

      it "displays the link to the supported housing" do
        expect(page).to have_link("Supported housing", href: "/supported-housing")
      end

      context "when I click Supported housing" do
        before do
          click_link "Supported housing", href: "/supported-housing"
        end

        it "shows list of schemes" do
          schemes.each do |scheme|
            expect(page).to have_content(scheme.code)
          end
        end

        context "when I search for a specific scheme" do
          it "there is a search bar with a message and search button for schemes" do
            expect(page).to have_field("search")
            expect(page).to have_content("Search by service name or code")
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

  context "when viewing individual scheme" do
    context "when I am signed as a support user and there are schemes in the database" do
      let(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now) }
      let!(:schemes) { FactoryBot.create_list(:scheme, 5) }
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

      context "when I visit supported housing page" do
        before do
          visit("supported-housing")
        end

        it "shows list of links to schemes" do
          schemes.each do |scheme|
            expect(page).to have_link(scheme.service_name)
            expect(page).to have_content(scheme.primary_client_group_display)
          end
        end

        context "when I click to see individual scheme" do
          before do
            click_link(schemes.first.service_name)
          end

          it "shows me details about the selected scheme" do
            expect(page).to have_content(schemes.first.code)
            expect(page).to have_content(schemes.first.service_name)
            expect(page).to have_content(schemes.first.sensitive_display)
            expect(page).to have_content(schemes.first.scheme_type_display)
            expect(page).to have_content(schemes.first.registered_under_care_act_display)
            expect(page).to have_content(schemes.first.total_units)
            expect(page).to have_content(schemes.first.primary_client_group_display)
            expect(page).to have_content(schemes.first.secondary_client_group_display)
            expect(page).to have_content(schemes.first.support_type_display)
            expect(page).to have_content(schemes.first.intended_stay_display)
          end

          it "shows service and locations tab" do
            expect(page).to have_content("Service")
            expect(page).to have_content("locations")
          end
        end
      end
    end
  end
end
