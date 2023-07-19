require "rails_helper"

RSpec.describe OrganisationsHelper do

  include TagHelper
  describe "display_organisation_attributes" do
    let(:organisation) { create(:organisation) }

    it "does not include data protection agreement" do
      expect(display_organisation_attributes(organisation)).to eq(
        [{ editable: true, name: "Name", value: "DLUHC" },
         { editable: false, name: "Organisation ID", value: "ORG#{organisation.id}" },
         { editable: true,
           name: "Address",
           value: "2 Marsham Street\nLondon\nSW1P 4DF" },
         { editable: true, name: "Telephone number", value: nil },
         { editable: false, name: "Type of provider", value: "Local authority" },
         { editable: false, name: "Registration number", value: "1234" },
         { editable: false, format: :bullet, name: "Rent periods", value: %w[All] },
         { editable: false, name: "Owns housing stock", value: "Yes" },
         { editable: false, name: "Status", value: status_tag(organisation.status) }],
      )
    end
  end
end
