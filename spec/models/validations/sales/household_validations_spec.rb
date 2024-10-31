require "rails_helper"

RSpec.describe Validations::Sales::HouseholdValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::HouseholdValidations } }
  let(:record) { build(:sales_log, saledate:) }
  let(:saledate) { Time.zone.now }

  describe "#validate_partner_count" do
    let(:saledate) { Time.zone.local(2023, 4, 1) }

    it "validates that only 1 partner exists" do
      record.relat2 = "P"
      record.relat3 = "P"
      household_validator.validate_partner_count(record)
      expect(record.errors["relat2"])
        .to include(match I18n.t("validations.sales.household.relat.one_partner"))
      expect(record.errors["relat3"])
        .to include(match I18n.t("validations.sales.household.relat.one_partner"))
      expect(record.errors["relat4"])
        .not_to include(match I18n.t("validations.sales.household.relat.one_partner"))
    end

    it "expects that a tenant can have a partner" do
      record.relat3 = "P"
      household_validator.validate_partner_count(record)
      expect(record.errors["base"]).to be_empty
    end
  end

  describe "#validate_person_age_matches_relationship" do
    context "with 2023 logs" do
      let(:saledate) { Time.zone.local(2023, 4, 1) }

      context "when the household contains a person under 16" do
        it "expects that person is a child of the tenant" do
          record.age2 = 14
          record.relat2 = "C"
          household_validator.validate_person_age_matches_relationship(record)
          expect(record.errors["relat2"]).to be_empty
          expect(record.errors["age2"]).to be_empty
        end

        it "validates that a person under 16 must not be a partner of the buyer" do
          record.age2 = 14
          record.relat2 = "P"
          household_validator.validate_person_age_matches_relationship(record)
          expect(record.errors["relat2"])
            .to include(match I18n.t("validations.sales.household.relat.child_under_16", person_num: 2))
          expect(record.errors["age2"])
            .to include(match I18n.t("validations.sales.household.age.child_under_16", person_num: 2))
        end
      end

      it "validates that a person over 20 must not be a child of the buyer" do
        record.age2 = 21
        record.relat2 = "C"
        household_validator.validate_person_age_matches_relationship(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.sales.household.relat.child_over_20"))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.sales.household.age.child_over_20"))
      end
    end

    context "with 2024 logs" do
      let(:saledate) { Time.zone.local(2024, 4, 1) }

      it "does not add error if person under 16 is a partner" do
        record.age2 = 14
        record.relat2 = "P"
        household_validator.validate_person_age_matches_relationship(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "does not add error if person over 19 is a child" do
        record.age2 = 20
        record.relat2 = "C"
        household_validator.validate_person_age_matches_relationship(record)
        expect(record.errors["age2"]).to be_empty
        expect(record.errors["relat2"]).to be_empty
      end
    end
  end

  describe "#validate_person_age_matches_economic_status" do
    context "with 2023 logs" do
      let(:saledate) { Time.zone.local(2023, 4, 1) }

      it "validates that person's economic status must be Child" do
        record.age2 = 14
        record.ecstat2 = 1
        household_validator.validate_person_age_matches_economic_status(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.sales.household.ecstat.child_under_16", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.sales.household.age.child_under_16_ecstat", person_num: 2))
      end

      it "expects that person's economic status is Child" do
        record.age2 = 14
        record.ecstat2 = 9
        household_validator.validate_person_age_matches_economic_status(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "validates that a person with economic status 'child' must be under 16" do
        record.age2 = 21
        record.ecstat2 = 9
        household_validator.validate_person_age_matches_economic_status(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.sales.household.ecstat.child_over_16", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.sales.household.age.child_over_16", person_num: 2))
      end
    end

    context "with 2024 logs" do
      let(:saledate) { Time.zone.local(2024, 4, 1) }

      it "does not run the validation" do
        record.age2 = 14
        record.ecstat2 = 1
        household_validator.validate_person_age_matches_economic_status(record)
        expect(record.errors["ecstat2"])
          .not_to include(match I18n.t("validations.sales.household.ecstat.child_under_16", person_num: 2))
        expect(record.errors["age2"])
          .not_to include(match I18n.t("validations.sales.household.age.child_under_16_ecstat", person_num: 2))
      end
    end
  end

  describe "#validate_child_12_years_younger" do
    context "with 2023 logs" do
      let(:saledate) { Time.zone.local(2023, 4, 1) }

      it "validates the child is at least 12 years younger than buyer 1" do
        record.age1 = 30
        record.age2 = record.age1 - 11
        record.relat2 = "C"
        household_validator.validate_child_12_years_younger(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.sales.household.age.child_12_years_younger", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.sales.household.age.child_12_years_younger", person_num: 2))
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.sales.household.age.child_12_years_younger", person_num: 2))
      end

      it "expects the child is at least 12 years younger than buyer 1" do
        record.age1 = 30
        record.age2 = record.age1 - 12
        record.relat2 = "C"
        household_validator.validate_child_12_years_younger(record)
        expect(record.errors["age1"]).to be_empty
        expect(record.errors["age2"]).to be_empty
        expect(record.errors["relate2"]).to be_empty
      end
    end

    context "with 2024 logs" do
      let(:saledate) { Time.zone.local(2024, 4, 1) }

      it "does not validate that child is at least 12 year younger than buyer" do
        record.age1 = 20
        record.age2 = 17
        record.relat2 = "C"
        household_validator.validate_child_12_years_younger(record)
        expect(record.errors["age1"]).to be_empty
        expect(record.errors["age2"]).to be_empty
        expect(record.errors["relat2"]).to be_empty
      end
    end
  end

  describe "#validate_person_age_and_relationship_matches_economic_status" do
    context "with 2023 logs" do
      let(:saledate) { Time.zone.local(2023, 4, 1) }

      it "does not add an error for a person aged 16-19 who is a student but not a child of the buyer" do
        record.age2 = 18
        record.ecstat2 = "7"
        record.relat2 = "P"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "does not add an error for a person not aged 16-19 who is a student but not a child of the buyer" do
        record.age2 = 20
        record.ecstat2 = "7"
        record.relat2 = "P"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "adds errors for a person aged 16-19 who is a child of the buyer but not a student" do
        record.age2 = 17
        record.ecstat2 = "1"
        record.relat2 = "C"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.sales.household.relat.student_16_19.cannot_be_child.16_19_not_student"))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.sales.household.age.student_16_19.cannot_be_16_19.child_not_student"))
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.sales.household.ecstat.student_16_19.must_be_student"))
      end

      it "adds errors for a person who is a child of the buyer and a student but not aged 16-19" do
        record.age2 = 14
        record.ecstat2 = "7"
        record.relat2 = "C"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.sales.household.relat.student_16_19.cannot_be_child.student_not_16_19"))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.sales.household.age.student_16_19.must_be_16_19"))
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.sales.household.ecstat.student_16_19.cannot_be_student.child_not_16_19"))
      end
    end

    context "with 2024 logs" do
      let(:saledate) { Time.zone.local(2024, 4, 1) }

      context "when the household contains a tenant’s child between the ages of 16 and 19" do
        it "does not add an error" do
          record.age2 = 17
          record.relat2 = "C"
          record.ecstat2 = 1
          household_validator.validate_person_age_and_relationship_matches_economic_status(record)
          expect(record.errors["ecstat2"])
            .to be_empty
          expect(record.errors["age2"])
            .to be_empty
          expect(record.errors["relat2"])
            .to be_empty
        end
      end

      it "does not add an error for a person not aged 16-19 who is a student but not a child of the buyer" do
        record.age2 = 20
        record.ecstat2 = "7"
        record.relat2 = "P"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "does not add errors" do
        record.age2 = 14
        record.ecstat2 = "7"
        record.relat2 = "C"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "does not add errors for a person who is a student and aged 16-19 but not child" do
        record.age2 = 17
        record.ecstat2 = "7"
        record.relat2 = "X"
        household_validator.validate_person_age_and_relationship_matches_economic_status(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end
    end
  end

  describe "validating fields about buyers living in the property" do
    let(:sales_log) { build(:sales_log, :outright_sale_setup_complete, saledate:, noint: 1, companybuy: 2, buylivein:, jointpur:, jointmore:, buy1livein:) }

    context "when buyers will live in the property and the sale is a joint purchase" do
      let(:buylivein) { 1 }
      let(:jointpur) { 1 }
      let(:jointmore) { 2 }

      context "and buyer one will live in the property" do
        let(:buy1livein) { 1 }

        it "does not add validations regardless of whether buyer two will live in the property" do
          sales_log.buy2livein = 1
          household_validator.validate_buyers_living_in_property(sales_log)
          expect(sales_log.errors).to be_empty
          sales_log.buy2livein = 2
          household_validator.validate_buyers_living_in_property(sales_log)
          expect(sales_log.errors).to be_empty
        end
      end

      context "and buyer one will not live in the property" do
        let(:buy1livein) { 2 }

        it "does not add validations if buyer two will live in the property or if we do not yet know" do
          sales_log.buy2livein = 1
          household_validator.validate_buyers_living_in_property(sales_log)
          expect(sales_log.errors).to be_empty
          sales_log.buy2livein = nil
          household_validator.validate_buyers_living_in_property(sales_log)
          expect(sales_log.errors).to be_empty
        end

        context "with 2023 logs" do
          let(:saledate) { Time.zone.local(2023, 4, 1) }

          it "triggers a validation if buyer two will also not live in the property" do
            sales_log.buy2livein = 2
            household_validator.validate_buyers_living_in_property(sales_log)
            expect(sales_log.errors[:buylivein]).to include I18n.t("validations.sales.household.buylivein.buyers_will_live_in_property_values_inconsistent")
            expect(sales_log.errors[:buy2livein]).to include I18n.t("validations.sales.household.buy2livein.buyers_will_live_in_property_values_inconsistent")
            expect(sales_log.errors[:buy1livein]).to include I18n.t("validations.sales.household.buy1livein.buyers_will_live_in_property_values_inconsistent")
          end
        end
      end

      context "and we don't know whether buyer one will live in the property" do
        let(:buy1livein) { nil }

        it "does not add validations regardless of whether buyer two will live in the property" do
          sales_log.buy2livein = 1
          household_validator.validate_buyers_living_in_property(sales_log)
          expect(sales_log.errors).to be_empty
          sales_log.buy2livein = 2
          household_validator.validate_buyers_living_in_property(sales_log)
          expect(sales_log.errors).to be_empty
        end
      end
    end
  end

  describe "#validate_buyer1_previous_tenure" do
    let(:record) { build(:sales_log, saledate:, ownershipsch: 2) }

    it "adds an error when previous tenure is not valid" do
      [3, 4, 5, 6, 7, 9, 0].each do |prevten|
        record.prevten = prevten
        household_validator.validate_buyer1_previous_tenure(record)
        expect(record.errors["prevten"]).to include("Buyer 1’s previous tenure should be “local authority tenant” or “private registered provider or housing association tenant” for discounted sales.")
        expect(record.errors["ownershipsch"]).to include("Buyer 1’s previous tenure should be “local authority tenant” or “private registered provider or housing association tenant” for discounted sales.")
      end
    end

    it "does not add an error when previous tenure is allowed" do
      [1, 2].each do |prevten|
        record.prevten = prevten
        household_validator.validate_buyer1_previous_tenure(record)
        expect(record.errors).to be_empty
      end
    end

    it "does not add an error if previous tenure is not given" do
      record.prevten = nil
      household_validator.validate_buyer1_previous_tenure(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error for shared ownership sale" do
      record.ownershipsch = 1

      [1, 2, 3, 4, 5, 6, 7, 9, 0].each do |prevten|
        record.prevten = prevten
        household_validator.validate_buyer1_previous_tenure(record)
        expect(record.errors).to be_empty
      end
    end

    it "does not add an error for outright sale" do
      record.ownershipsch = 3

      [1, 2, 3, 4, 5, 6, 7, 9, 0].each do |prevten|
        record.prevten = prevten
        household_validator.validate_buyer1_previous_tenure(record)
        expect(record.errors).to be_empty
      end
    end

    context "with 23/24 logs" do
      let(:saledate) { Time.zone.local(2023, 4, 4) }

      it "does not add an error for outright sale" do
        record.ownershipsch = 2

        [1, 2, 3, 4, 5, 6, 7, 9, 0].each do |prevten|
          record.prevten = prevten
          household_validator.validate_buyer1_previous_tenure(record)
          expect(record.errors).to be_empty
        end
      end
    end
  end

  describe "#validate_buyer_not_child" do
    context "with 2023 logs" do
      let(:saledate) { Time.zone.local(2023, 4, 1) }

      it "does not add an error if either buyer is a child" do
        record.jointpur = 1
        record.ecstat1 = 9
        record.ecstat2 = 9
        household_validator.validate_buyer_not_child(record)
        expect(record.errors["ecstat1"]).to be_empty
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "with 2024 logs" do
      let(:saledate) { Time.zone.local(2024, 4, 1) }

      it "validates buyer 1 isn't a child" do
        record.ecstat1 = 9
        household_validator.validate_buyer_not_child(record)
        expect(record.errors["ecstat1"])
          .to include("Buyer 1 cannot have a working situation of child under 16.")
      end

      it "validates buyer 2 isn't a child" do
        record.jointpur = 1
        record.ecstat2 = 9
        household_validator.validate_buyer_not_child(record)
        expect(record.errors["ecstat2"])
          .to include("Buyer 2 cannot have a working situation of child under 16.")
      end

      it "allows person 2 to be a child" do
        record.jointpur = 2
        record.ecstat2 = 9
        household_validator.validate_buyer_not_child(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end
  end
end
