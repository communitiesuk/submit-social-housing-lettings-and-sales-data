require "rails_helper"

RSpec.describe LocationsHelper do
  describe "mobility type selection" do
    expected_selection = [OpenStruct.new(id: "Wheelchair-user standard", name: "Wheelchair-user standard", description: "Suitable for someone who uses a wheelchair and offers the full use of all rooms and facilities."),
                          OpenStruct.new(id: "Fitted with equipment and adaptations", name: "Fitted with equipment and adaptations", description: "Fitted with stairlifts, ramps, level access showers or grab rails."),
                          OpenStruct.new(id: "None", name: "None", description: "Not designed to wheelchair-user standards or fitted with any equipment or adaptations.")]
    it "returns correct selection to display" do
      expect(mobility_type_selection).to eq(expected_selection)
    end
  end

  describe "another location selection" do
    it "returns correct selection to display" do
      expected_selection = [OpenStruct.new(id: "Yes", name: "Yes"), OpenStruct.new(id: "No", name: "No")]
      expect(another_location_selection).to eq(expected_selection)
    end
  end

  describe "type of units selection" do
    it "returns correct selection to display" do
      expected_selection = [OpenStruct.new(id: "Bungalow", name: "Bungalow"),
                            OpenStruct.new(id: "Self-contained flat or bedsit", name: "Self-contained flat or bedsit"),
                            OpenStruct.new(id: "Self-contained flat or bedsit with common facilities", name: "Self-contained flat or bedsit with common facilities"),
                            OpenStruct.new(id: "Self-contained house", name: "Self-contained house"),
                            OpenStruct.new(id: "Shared flat", name: "Shared flat"),
                            OpenStruct.new(id: "Shared house or hostel", name: "Shared house or hostel")]
      expect(type_of_units_selection).to eq(expected_selection)
    end
  end

  describe "selection options" do
    it "returns empty array for nil" do
      expect(selection_options(nil)).to eq([])
    end

    it "returns empty array for empty string" do
      expect(selection_options("")).to eq([])
    end

    it "returns empty array for empty object" do
      expect(selection_options({})).to eq([])
    end

    it "can map a resource with values" do
      expect(selection_options(%w[example])).to eq([OpenStruct.new(id: "example", name: "Example")])
    end
  end

  describe "Active periods" do
    let(:location) { FactoryBot.create(:location, startdate: nil) }

    before do
      Timecop.freeze(2022, 10, 10)
    end

    after do
      Timecop.unfreeze
    end

    it "returns one active period without to date" do
      expect(location_active_periods(location).count).to eq(1)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: nil)
    end

    it "ignores reactivations that were deactivated on the same day" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), location:)
      location.reload

      expect(location_active_periods(location).count).to eq(1)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
    end

    it "returns sequential non reactivated active periods" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), location:)
      location.reload

      expect(location_active_periods(location).count).to eq(2)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(location_active_periods(location).second).to have_attributes(from: Time.zone.local(2022, 6, 4), to: Time.zone.local(2022, 7, 6))
    end

    it "returns sequential reactivated active periods" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), reactivation_date: Time.zone.local(2022, 8, 5), location:)
      location.reload
      expect(location_active_periods(location).count).to eq(3)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(location_active_periods(location).second).to have_attributes(from: Time.zone.local(2022, 6, 4), to: Time.zone.local(2022, 7, 6))
      expect(location_active_periods(location).third).to have_attributes(from: Time.zone.local(2022, 8, 5), to: nil)
    end

    it "returns non sequential non reactivated active periods" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), reactivation_date: Time.zone.local(2022, 8, 5), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: nil, location:)
      location.reload

      expect(location_active_periods(location).count).to eq(2)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(location_active_periods(location).second).to have_attributes(from: Time.zone.local(2022, 8, 5), to: nil)
    end

    it "returns non sequential reactivated active periods" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), reactivation_date: Time.zone.local(2022, 8, 5), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), location:)
      location.reload
      expect(location_active_periods(location).count).to eq(3)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(location_active_periods(location).second).to have_attributes(from: Time.zone.local(2022, 6, 4), to: Time.zone.local(2022, 7, 6))
      expect(location_active_periods(location).third).to have_attributes(from: Time.zone.local(2022, 8, 5), to: nil)
    end

    it "returns correct active periods when reactivation happends during a deactivated period" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 11, 11), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 4, 6), reactivation_date: Time.zone.local(2022, 7, 7), location:)
      location.reload

      expect(location_active_periods(location).count).to eq(2)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 4, 6))
      expect(location_active_periods(location).second).to have_attributes(from: Time.zone.local(2022, 11, 11), to: nil)
    end

    it "returns correct active periods when a full deactivation period happens during another deactivation period" do
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 11), location:)
      FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 4, 6), reactivation_date: Time.zone.local(2022, 7, 7), location:)
      location.reload

      expect(location_active_periods(location).count).to eq(2)
      expect(location_active_periods(location).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 4, 6))
      expect(location_active_periods(location).second).to have_attributes(from: Time.zone.local(2022, 7, 7), to: nil)
    end
  end

  describe "display_location_attributes" do
    let(:location) { FactoryBot.build(:location, created_at: Time.zone.local(2022, 3, 16), startdate: Time.zone.local(2022, 4, 1)) }

    it "returns correct display attributes" do
      attributes = [
        { attribute: "postcode", name: "Postcode", value: location.postcode },
        { attribute: "name", name: "Location name", value: location.name },
        { attribute: "local_authority", name: "Local authority", value: location.location_admin_district },
        { attribute: "units", name: "Number of units", value: location.units },
        { attribute: "type_of_unit", name: "Most common unit", value: location.type_of_unit },
        { attribute: "mobility_standards", name: "Mobility standards", value: location.mobility_type },
        { attribute: "location_code", name: "Location code", value: location.location_code },
        { attribute: "availability", name: "Availability", value: "Active from 1 April 2022" },
        { attribute: "status", name: "Status", value: :active },
      ]

      expect(display_location_attributes(location)).to eq(attributes)
    end

    context "when location has different local authorities for different years" do
      before do
        LocalAuthorityLink.create!(local_authority_id: LocalAuthority.find_by(code: "E07000030").id, linked_local_authority_id: LocalAuthority.find_by(code: "E06000063").id)
        location.update!(location_code: "E07000030")
      end

      it "returns correct display attributes" do
        attributes = [
          { attribute: "postcode", name: "Postcode", value: location.postcode },
          { attribute: "name", name: "Location name", value: location.name },
          { attribute: "local_authority", name: "Local authority", value: "Eden (until 31 March 2023)\nCumberland (1 April 2023 - present)" },
          { attribute: "units", name: "Number of units", value: location.units },
          { attribute: "type_of_unit", name: "Most common unit", value: location.type_of_unit },
          { attribute: "mobility_standards", name: "Mobility standards", value: location.mobility_type },
          { attribute: "location_code", name: "Location code", value: "E07000030 (until 31 March 2023)\nE06000063 (1 April 2023 - present)" },
          { attribute: "availability", name: "Availability", value: "Active from 1 April 2022" },
          { attribute: "status", name: "Status", value: :active },
        ]

        expect(display_location_attributes(location)).to eq(attributes)
      end
    end

    context "when location has no local authority" do
      before do
        LocalAuthorityLink.create!(local_authority_id: LocalAuthority.find_by(code: "E07000030").id, linked_local_authority_id: LocalAuthority.find_by(code: "E06000063").id)
        location.update!(location_code: nil, confirmed: false)
      end

      it "returns correct display attributes" do
        attributes = [
          { attribute: "postcode", name: "Postcode", value: location.postcode },
          { attribute: "name", name: "Location name", value: location.name },
          { attribute: "local_authority", name: "Local authority", value: "" },
          { attribute: "units", name: "Number of units", value: location.units },
          { attribute: "type_of_unit", name: "Most common unit", value: location.type_of_unit },
          { attribute: "mobility_standards", name: "Mobility standards", value: location.mobility_type },
          { attribute: "location_code", name: "Location code", value: "" },
          { attribute: "availability", name: "Availability", value: "Active from 1 April 2022" },
          { attribute: "status", name: "Status", value: :incomplete },
        ]

        expect(display_location_attributes(location)).to eq(attributes)
      end
    end

    context "when viewing availability" do
      context "with no deactivations" do
        it "displays current collection start date as availability date if created_at is later than collection start date" do
          location.update!(startdate: nil, created_at: Time.zone.local(2023, 8, 16))
          availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from 1 April 2023")
        end

        it "displays previous collection start date as availability date if created_at is later than collection start date and in crossover" do
          location.update!(startdate: nil, created_at: Time.zone.local(2023, 4, 16))
          availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from 1 April 2022")
        end
      end

      context "with previous deactivations" do
        context "and all reactivated deactivations" do
          before do
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 10), reactivation_date: Time.zone.local(2022, 9, 1), location:)
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 15), reactivation_date: Time.zone.local(2022, 9, 28), location:)
            location.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 9 August 2022\nDeactivated on 10 August 2022\nActive from 1 September 2022 to 14 September 2022\nDeactivated on 15 September 2022\nActive from 28 September 2022")
          end
        end

        context "and non reactivated deactivation" do
          before do
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 10), reactivation_date: Time.zone.local(2022, 9, 1), location:)
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 15), reactivation_date: nil, location:)
            location.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 9 August 2022\nDeactivated on 10 August 2022\nActive from 1 September 2022 to 14 September 2022\nDeactivated on 15 September 2022")
          end
        end
      end

      context "with out of order deactivations" do
        context "and all reactivated deactivations" do
          before do
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 24), reactivation_date: Time.zone.local(2022, 9, 28), location:)
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 15), reactivation_date: Time.zone.local(2022, 6, 18), location:)
            location.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 14 June 2022\nDeactivated on 15 June 2022\nActive from 18 June 2022 to 23 September 2022\nDeactivated on 24 September 2022\nActive from 28 September 2022")
          end
        end

        context "and one non reactivated deactivation" do
          before do
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 24), reactivation_date: Time.zone.local(2022, 9, 28), location:)
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 15), reactivation_date: nil, location:)
            location.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 14 June 2022\nDeactivated on 15 June 2022\nActive from 28 September 2022")
          end
        end
      end

      context "with multiple out of order deactivations" do
        context "and one non reactivated deactivation" do
          before do
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 24), reactivation_date: Time.zone.local(2022, 9, 28), location:)
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 10, 24), reactivation_date: Time.zone.local(2022, 10, 28), location:)
            FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 15), reactivation_date: nil, location:)
            location.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 14 June 2022\nDeactivated on 15 June 2022\nActive from 28 September 2022 to 23 October 2022\nDeactivated on 24 October 2022\nActive from 28 October 2022")
          end
        end
      end

      context "with intersecting deactivations" do
        before do
          FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 10, 10), reactivation_date: Time.zone.local(2022, 12, 1), location:)
          FactoryBot.create(:location_deactivation_period, deactivation_date: Time.zone.local(2022, 11, 11), reactivation_date: Time.zone.local(2022, 12, 11), location:)
          location.reload
        end

        it "displays the timeline of availability" do
          availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from 1 April 2022 to 9 October 2022\nDeactivated on 10 October 2022\nActive from 11 December 2022")
        end
      end
    end
  end
end
