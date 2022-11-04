require "rails_helper"

RSpec.describe "Sales Log Features" do
  context "when searching for specific sales logs" do
    context "when I am signed in and there are sales logs in the database" do
      let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
      let!(:log_to_search) { FactoryBot.create(:sales_log, owning_organisation: user.organisation) }
      let!(:same_organisation_log) { FactoryBot.create(:sales_log, owning_organisation: user.organisation) }
      let!(:another_organisation_log) { FactoryBot.create(:sales_log) }

      before do
        login(user)
      end

      it "displays the logs belonging to the same organisation" do
        expect(page).to have_link(log_to_search.id.to_s)
        expect(page).to have_link(same_organisation_log.id.to_s)
        expect(page).not_to have_link(another_organisation_log.id.to_s)
      end

      context "when returning to the list of logs via breadcrumbs link" do
        before do
          visit("/sales-logs")
          click_button("Create a new sales log")
          click_link("Logs")
        end

        it "navigates you to the sales logs page" do
          expect(page).to have_current_path("/sales-logs")
        end
      end

      context "when completing the setup this sales log section" do
        it "includes the purchaser code and sale completion date questions" do
          visit("/sales-logs")
          click_button("Create a new sales log")
          click_link("Set up this sales log")
          fill_in("sales_log[saledate(1i)]", with: "2022")
          fill_in("sales_log[saledate(2i)]", with: "08")
          fill_in("sales_log[saledate(3i)]", with: "10")
          click_button("Save and continue")
          fill_in("sales_log[purchid]", with: "PC123")
          click_button("Save and continue")
          log_id = page.current_path.scan(/\d/).join
          visit("sales-logs/#{log_id}/setup/check-answers")
          expect(page).to have_content("Sale completion date")
          expect(page).to have_content("2022")
          expect(page).to have_content("Purchaser code")
          expect(page).to have_content("PC123")
        end
      end

      context "when the sales log feature flag is toggled" do
        before do
          allow(Rails.env).to receive(:production?).and_return(true)
        end

        it "hides the create sales log button in production" do
          visit("/sales-logs")
          expect(page).not_to have_content("Create a new sales log")
        end
      end
    end
  end

  describe "property information section" do
    let!(:user) { FactoryBot.create(:user, last_sign_in_at: Time.zone.now) }
    let!(:sales_log) do
      FactoryBot.create(
        :sales_log,
        :before_you_start_completed,
        created_by: user,
        owning_organisation: user.organisation,
      )
    end

    before do
      login(user)
    end

    # Question 14 Property Postcode
    context "when postcode is known then not known then known again" do
      it "sets correct log state", js: true do
        expect(sales_log.postcode_full).to be nil
        expect(sales_log.postcode_known).to be nil
        expect(sales_log.pcode1).to be nil
        expect(sales_log.pcode2).to be nil
        expect(sales_log.pcodenk).to be true
        expect(sales_log.la).to be nil
        expect(sales_log.la_known).to be nil

        visit("/sales-logs/#{sales_log.id}/postcode-known")

        # 1. User forgot to set postcode
        expect(page).to have_content("Do you know the property's postcode?")
        choose("Yes", allow_label_click: true)
        click_button("Save and continue")
        expect(page).to have_content("You must answer postcode")

        # 2. User enters valid postcode
        choose("Yes", allow_label_click: true)
        click_button("Save and continue")
        fill_in("sales_log[postcode_full]", with: "AA1 1AA")
        click_button("Save and continue")

        sales_log.reload
        expect(sales_log.postcode_full).to eq "AA1 1AA"
        expect(sales_log.postcode_known).to eq 1
        expect(sales_log.pcode1).to eq "AA1"
        expect(sales_log.pcode2).to eq "1AA"
        expect(sales_log.pcodenk).to be false
        expect(sales_log.la).to eq "Westminster"
        expect(sales_log.la_known).to be 1

        # 3. User decides they don't know the postcode
        visit("/sales-logs/#{sales_log.id}/postcode-known")
        choose("No", allow_label_click: true)
        click_button("Save and continue")

        sales_log.reload
        expect(sales_log.postcode_full).to be nil
        expect(sales_log.postcode_known).to eq 0
        expect(sales_log.pcode1).to be nil
        expect(sales_log.pcode2).to be nil
        expect(sales_log.pcodenk).to be true
        expect(sales_log.la).to be nil
        expect(sales_log.la_known).to be 0

        # 4. User decides they do know the password
        visit("/sales-logs/#{sales_log.id}/postcode-known")
        choose("Yes", allow_label_click: true)
        fill_in("sales_log[postcode_full]", with: "SW9 8LA")
        click_button("Save and continue")

        sales_log.reload
        expect(sales_log.postcode_full).to eq "SW9 8LA"
        expect(sales_log.postcode_known).to eq 1
        expect(sales_log.pcode1).to eq "SW9"
        expect(sales_log.pcode2).to eq "8LA"
        expect(sales_log.pcodenk).to be false
        expect(sales_log.la).to eq "Lambeth"
        expect(sales_log.la_known).to be 1
      end
    end

    # E.g. Postcode.io service unreachable or timed out
    # Note: B26 3QJ is not defined in request_helper.rb
    context "when postcode is known but not found by postocde.io" do
      it "sets correct log state", js: true do
        visit("/sales-logs/#{sales_log.id}/postcode-known")

        choose("Yes", allow_label_click: true)
        click_button("Save and continue")
        fill_in("sales_log[postcode_full]", with: "B26 3QJ")
        click_button("Save and continue")

        sales_log.reload
        expect(sales_log.postcode_full).to eq "B26 3QJ"
        expect(sales_log.postcode_known).to eq 1
        expect(sales_log.pcode1).to be nil
        expect(sales_log.pcode2).to be nil
        expect(sales_log.pcodenk).to be false
        expect(sales_log.la).to be nil
        expect(sales_log.la_known).to be 0
      end
    end
  end

  def login(user)
    visit("/sales-logs")
    fill_in("user[email]", with: user.email)
    fill_in("user[password]", with: user.password)
    click_button("Sign in")
  end
end
