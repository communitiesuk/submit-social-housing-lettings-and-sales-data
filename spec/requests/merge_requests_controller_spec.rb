require "rails_helper"

RSpec.describe MergeRequestsController, type: :request do
  let(:organisation) { user.organisation }
  let(:other_organisation) { create(:organisation, name: "Other Test Org") }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, :data_coordinator) }
  let(:support_user) { create(:user, :support, organisation:) }
  let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation) }
  let(:other_merge_request) { MergeRequest.create!(requesting_organisation: other_organisation) }

  context "when user is signed in with a support user" do
    before do
      allow(support_user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in support_user
    end

    describe "#organisations" do
      let(:params) { { merge_request: { requesting_organisation_id: support_user.organisation_id, status: "incomplete" } } }

      context "when creating a new merge request" do
        before do
          post "/merge-request", headers:, params:
        end

        it "creates merge request with requesting organisation" do
          follow_redirect!
          expect(page).to have_content("Which organisation is absorbing the others?")
          expect(page).to have_content(support_user.organisation.name)
        end

        context "when passing a different requesting organisation id" do
          let(:params) { { merge_request: { requesting_organisation_id: other_organisation.id, status: "incomplete" } } }

          it "creates merge request with current user organisation" do
            follow_redirect!
            expect(MergeRequest.count).to eq(1)
            expect(MergeRequest.first.requesting_organisation_id).to eq(support_user.organisation_id)
            expect(MergeRequest.first.merging_organisations.count).to eq(0)
          end
        end
      end

      context "when viewing existing merge request" do
        before do
          get "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "shows merge request with requesting organisation" do
          expect(page).to have_content("Which organisations are merging?")
          expect(page).to have_content(organisation.name)
        end
      end
    end

    describe "#update_organisations" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      context "when updating a merge request with a new organisation" do
        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "updates the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(1)
          expect(page).to have_content("Test Org")
          expect(page).to have_content("Other Test Org")
          expect(page).to have_link("Remove")
        end
      end

      context "when the user selects an organisation that requested another merge" do
        let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

        before do
          MergeRequest.create!(requesting_organisation_id: other_organisation.id, status: "request_merged")
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
        end
      end

      context "when the user selects an organisation that has another non submitted merge" do
        let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

        before do
          MergeRequest.create!(requesting_organisation_id: other_organisation.id, status: "incomplete")
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "updates the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(1)
          expect(page).not_to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
        end
      end

      context "when the user selects an organisation that is a part of another merge" do
        let(:another_organisation) { create(:organisation) }
        let(:params) { { merge_request: { merging_organisation: another_organisation.id } } }

        before do
          existing_merge_request = MergeRequest.create!(requesting_organisation_id: other_organisation.id, status: "request_merged")
          MergeRequestOrganisation.create!(merge_request_id: existing_merge_request.id, merging_organisation_id: another_organisation.id)
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
        end
      end

      context "when the user selects an organisation that is a part of another unsubmitted merge" do
        let(:another_organisation) { create(:organisation) }
        let(:params) { { merge_request: { merging_organisation: another_organisation.id } } }

        before do
          existing_merge_request = MergeRequest.create!(requesting_organisation_id: other_organisation.id, status: "incomplete")
          MergeRequestOrganisation.create!(merge_request_id: existing_merge_request.id, merging_organisation_id: another_organisation.id)
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(1)
          expect(page).not_to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
        end
      end

      context "when the user selects an organisation that is a part of current merge" do
        let(:another_organisation) { create(:organisation) }
        let(:params) { { merge_request: { merging_organisation: another_organisation.id } } }

        before do
          merge_request.merging_organisations << another_organisation
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(1)
        end
      end

      context "when the user selects an organisation that is requesting this merge" do
        let(:params) { { merge_request: { merging_organisation: merge_request.requesting_organisation_id } } }

        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(page).not_to have_content(I18n.t("validations.merge_request.organisation_part_of_another_merge"))
          expect(merge_request.merging_organisations.count).to eq(1)
        end
      end

      context "when the user does not select an organisation" do
        let(:params) { { merge_request: { merging_organisation: nil } } }

        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_not_selected"))
        end
      end

      context "when the user selects non existent id" do
        let(:params) { { merge_request: { merging_organisation: "clearly_not_an_id" } } }

        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not update the merge request" do
          merge_request.reload
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_content(I18n.t("validations.merge_request.organisation_not_selected"))
        end
      end
    end

    describe "#remove_organisation" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      context "when removing an organisation from merge request" do
        before do
          MergeRequestOrganisation.create!(merge_request_id: merge_request.id, merging_organisation_id: other_organisation.id)
          get "/merge-request/#{merge_request.id}/organisations/remove", headers:, params:
        end

        it "updates the merge request" do
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(page).not_to have_link("Remove")
        end
      end

      context "when removing an organisation that is not part of a merge from merge request" do
        before do
          get "/merge-request/#{merge_request.id}/organisations/remove", headers:, params:
        end

        it "does not throw an error" do
          expect(merge_request.merging_organisations.count).to eq(0)
          expect(page).not_to have_link("Remove")
        end
      end
    end

    describe "#confirm_telephone_number" do
      let(:merge_request) do
        MergeRequest.create!(
          absorbing_organisation: create(:organisation, phone: phone_number),
          requesting_organisation: organisation,
        )
      end

      before { get "/merge-request/#{merge_request.id}/confirm-telephone-number", headers: }

      context "when org has phone number" do
        let(:phone_number) { 123 }

        it "asks to confirm or provide new number" do
          expect(page).to have_content("This telephone number is correct")
          expect(page).to have_content("Confirm the telephone number on file, or enter a new one.")
          expect(page).to have_content(phone_number)
          expect(page).to have_content("What is #{merge_request.absorbing_organisation.name}'s telephone number?")
        end
      end

      context "when org does not have a phone number set" do
        let(:phone_number) { nil }

        it "asks provide new number" do
          expect(page).not_to have_content("This telephone number is correct")
          expect(page).not_to have_content("Confirm the telephone number on file, or enter a new one.")
          expect(page).to have_content("What is #{merge_request.absorbing_organisation.name}'s telephone number?")
        end
      end
    end

    describe "#absorbing_organisation" do
      let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation) }

      before { get "/merge-request/#{merge_request.id}/absorbing-organisation", headers: }

      it "asks for the absorbing organisation" do
        expect(page).to have_content("Which organisation is absorbing the others?")
        expect(page).to have_content("Select organisation name")
      end

      it "has the correct back button" do
        expect(page).to have_link("Back", href: organisations_path(anchor: "merge-requests"))
      end
    end

    describe "#update" do
      describe "from absorbing_organisation page" do
        context "when not answering the question" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: other_organisation) }
          let(:params) do
            { merge_request: { page: "absorbing_organisation" } }
          end
          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request

            expect(page).to have_content("Select the organisation absorbing the others")
          end

          it "does not update the request" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end

        context "when absorbing_organisation_id set to id" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_absorbing_organisation: true) }
          let(:params) do
            { merge_request: { absorbing_organisation_id: other_organisation.id, page: "absorbing_organisation" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "redirects to merging organisations path" do
            request

            expect(response).to redirect_to(organisations_merge_request_path(merge_request))
          end

          it "updates absorbing_organisation_id and sets new_absorbing_organisation to false" do
            expect { request }.to change {
              merge_request.reload.absorbing_organisation
            }.from(nil).to(other_organisation).and change {
              merge_request.reload.new_absorbing_organisation
            }.from(true).to(false)
          end
        end
      end

      describe "#other_merging_organisations" do
        let(:other_merging_organisations) { "A list of other merging organisations" }
        let(:params) { { merge_request: { other_merging_organisations:, page: "organisations" } } }
        let(:request) do
          patch "/merge-request/#{merge_request.id}", headers:, params:
        end

        context "when adding other merging organisations" do
          before do
            MergeRequestOrganisation.create!(merge_request_id: merge_request.id, merging_organisation_id: other_organisation.id)
          end

          it "updates the merge request" do
            expect { request }.to change { merge_request.reload.other_merging_organisations }.from(nil).to(other_merging_organisations)
          end

          it "redirects telephone number path" do
            request

            expect(response).to redirect_to(confirm_telephone_number_merge_request_path(merge_request))
          end
        end
      end

      describe "from confirm_telephone_number page" do
        context "when confirming the number" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_absorbing_organisation: true, new_telephone_number: "123") }
          let(:params) do
            { merge_request: { telephone_number_correct: true, page: "confirm_telephone_number" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "redirects merge date path" do
            request

            expect(response).to redirect_to(merge_date_merge_request_path(merge_request))
          end

          it "updates telephone_number_correct and sets new_telephone_number to nil" do
            expect { request }.to change {
              merge_request.reload.telephone_number_correct
            }.from(nil).to(true).and change {
              merge_request.reload.new_telephone_number
            }.from("123").to(nil)
          end
        end

        context "when setting new number" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_absorbing_organisation: true) }
          let(:params) do
            { merge_request: { telephone_number_correct: false, new_telephone_number: "123", page: "confirm_telephone_number" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "redirects merge date path" do
            request

            expect(response).to redirect_to(merge_date_merge_request_path(merge_request))
          end

          it "updates telephone_number_correct and sets new_telephone_number to nil" do
            expect { request }.to change {
              merge_request.reload.new_telephone_number
            }.from(nil).to("123")
          end
        end

        context "when not answering the question and the org has phone number" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: create(:organisation, phone: "123")) }
          let(:params) do
            { merge_request: { page: "confirm_telephone_number" } }
          end
          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request

            expect(page).to have_content("Select to confirm or enter a new telephone number")
          end

          it "does not update the request" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end

        context "when not answering the question and the org does not have a phone number" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: other_organisation) }
          let(:params) do
            { merge_request: { page: "confirm_telephone_number" } }
          end
          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request

            expect(page).to have_content("Enter a valid telephone number")
          end

          it "does not update the request" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end

        context "when not answering the phone number" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, absorbing_organisation: other_organisation) }
          let(:params) do
            { merge_request: { page: "confirm_telephone_number", telephone_number_correct: false } }
          end
          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request

            expect(page).to have_content("Enter a valid telephone number")
          end

          it "does not update the request" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end
      end

      describe "#new_organisation_name" do
        let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_absorbing_organisation: true) }

        context "when viewing the new organisation name page" do
          before do
            get "/merge-request/#{merge_request.id}/new-organisation-name", headers:
          end

          it "displays the correct question" do
            expect(page).to have_content("What is the new organisation called?")
          end

          it "has the correct back button" do
            expect(page).to have_link("Back", href: absorbing_organisation_merge_request_path(merge_request))
          end
        end

        context "when updating the new organisation name" do
          let(:params) do
            { merge_request: { new_organisation_name: "new org name", page: "new_organisation_name" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "redirects to new organisation address path" do
            request
            expect(response).to redirect_to(new_organisation_address_merge_request_path(merge_request))
          end

          it "updates new organisation name to the correct name" do
            expect { request }.to change {
              merge_request.reload.new_organisation_name
            }.from(nil).to("new org name")
          end
        end

        context "when the new organisation name is not answered" do
          let(:params) do
            { merge_request: { new_organisation_name: nil, page: "new_organisation_name" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request
            expect(page).to have_content("Enter an organisation name")
          end

          it "does not update the organisation name" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end

        context "when the new organisation name already exists" do
          before do
            create(:organisation, name: "new org name")
          end

          let(:params) do
            { merge_request: { new_organisation_name: "New org name", page: "new_organisation_name" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request
            expect(page).to have_content("An organisation with this name already exists")
          end

          it "does not update the organisation name" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end
      end

      describe "#new_organisation_address" do
        let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_organisation_name: "New name", new_absorbing_organisation: true) }

        context "when viewing the new organisation name page" do
          before do
            get "/merge-request/#{merge_request.id}/new-organisation-address", headers:
          end

          it "displays the correct question" do
            expect(page).to have_content("What is New name’s address?")
          end

          it "has the correct back button" do
            expect(page).to have_link("Back", href: new_organisation_name_merge_request_path(merge_request))
          end

          it "has a skip link" do
            expect(page).to have_link("Skip for now", href: new_organisation_telephone_number_merge_request_path(merge_request))
          end
        end

        context "when updating the new organisation address" do
          let(:params) do
            { merge_request: {
              new_organisation_address_line1: "first address line",
              new_organisation_address_line2: "second address line",
              new_organisation_postcode: "new postcode",
              page: "new_organisation_address",
            } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "redirects to new organisation telephone path" do
            request
            expect(response).to redirect_to(new_organisation_telephone_number_merge_request_path(merge_request))
          end

          it "updates new organisation address line 1 to correct address line" do
            expect { request }.to change {
              merge_request.reload.new_organisation_address_line1
            }.from(nil).to("first address line")
          end

          it "updates new organisation address line 2 to correct address line" do
            expect { request }.to change {
              merge_request.reload.new_organisation_address_line2
            }.from(nil).to("second address line")
          end

          it "updates new organisation postcode to correct address line" do
            expect { request }.to change {
              merge_request.reload.new_organisation_postcode
            }.from(nil).to("new postcode")
          end
        end

        context "when address is not provided" do
          let(:params) do
            { merge_request: {
              new_organisation_address_line1: nil,
              new_organisation_address_line2: nil,
              new_organisation_postcode: nil,
              page: "new_organisation_address",
            } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "does not throw an error" do
            request
            expect(response).to redirect_to(new_organisation_telephone_number_merge_request_path(merge_request))
          end
        end
      end

      describe "#new_organisation_telephone_number" do
        let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_organisation_name: "New name", new_absorbing_organisation: true) }

        context "when viewing the new organisation telephone number page" do
          before do
            get "/merge-request/#{merge_request.id}/new-organisation-telephone-number", headers:
          end

          it "displays the correct question" do
            expect(page).to have_content("What is New name’s telephone number?")
          end

          it "has the correct back button" do
            expect(page).to have_link("Back", href: new_organisation_address_merge_request_path(merge_request))
          end
        end

        context "when updating the new organisation telephone number" do
          let(:params) do
            { merge_request: { new_organisation_telephone_number: "1234", page: "new_organisation_telephone_number" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "redirects to new organisation type path" do
            request
            expect(response).to redirect_to(new_organisation_type_merge_request_path(merge_request))
          end

          it "updates new organisation name to the correct telephone number" do
            expect { request }.to change {
              merge_request.reload.new_organisation_telephone_number
            }.from(nil).to("1234")
          end
        end

        context "when the new organisation telephone number is not answered" do
          let(:params) do
            { merge_request: { new_organisation_telephone_number: nil, page: "new_organisation_telephone_number" } }
          end

          let(:request) do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "renders the error" do
            request
            expect(page).to have_content("Enter a valid telephone number")
          end

          it "does not update the organisation telephone number" do
            expect { request }.not_to(change { merge_request.reload.attributes })
          end
        end
      end
    end
  end

  context "when user is signed in with a data coordinator user" do
    before do
      sign_in user
    end

    describe "#organisations" do
      let(:params) { { merge_request: { requesting_organisation_id: other_organisation.id, status: "incomplete" } } }

      context "when creating a new merge request" do
        before do
          post "/merge-request", headers:, params:
        end

        it "does not allow creating a new merge request" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when viewing existing merge request" do
        before do
          get "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not allow viewing a merge request" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#update_organisations" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      context "when updating a merge request with a new organisation" do
        before do
          patch "/merge-request/#{merge_request.id}/organisations", headers:, params:
        end

        it "does not allow updaing a merge request" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#remove_organisation" do
      let(:params) { { merge_request: { merging_organisation: other_organisation.id } } }

      context "when removing an organisation from merge request" do
        before do
          MergeRequestOrganisation.create!(merge_request_id: merge_request.id, merging_organisation_id: other_organisation.id)
          get "/merge-request/#{merge_request.id}/organisations/remove", headers:, params:
        end

        it "does not allow removing an organisation" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#update" do
      describe "from absorbing_organisation page" do
        context "when absorbing_organisation_id set to id" do
          let(:merge_request) { MergeRequest.create!(requesting_organisation: organisation, new_absorbing_organisation: true) }
          let(:params) do
            { merge_request: { absorbing_organisation_id: other_organisation.id, page: "absorbing_organisation" } }
          end

          before do
            patch "/merge-request/#{merge_request.id}", headers:, params:
          end

          it "does not allow updating absorbing organisation" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "#other_merging_organisations" do
        let(:other_merging_organisations) { "A list of other merging organisations" }
        let(:params) { { merge_request: { other_merging_organisations:, page: "organisations" } } }
        let(:request) do
          patch "/merge-request/#{merge_request.id}", headers:, params:
        end

        context "when adding other merging organisations" do
          before do
            MergeRequestOrganisation.create!(merge_request_id: merge_request.id, merging_organisation_id: other_organisation.id)
            request
          end

          it "does not allow updating merging organisations" do
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end
end
