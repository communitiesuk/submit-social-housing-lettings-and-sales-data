require "rails_helper"

RSpec.describe Validations::PropertyValidations do
  subject(:property_validator) { property_validator_class.new }

  let(:property_validator_class) { Class.new { include Validations::PropertyValidations } }
  let(:log) { build(:lettings_log) }

  describe "#validate_shared_housing_rooms" do
    context "when number of bedrooms has not been answered" do
      it "does not add an error" do
        log.beds = nil
        log.unittype_gn = 2
        property_validator.validate_shared_housing_rooms(log)
        expect(log.errors).to be_empty
      end
    end

    context "when unit type is shared and number of bedrooms has not been answered" do
      it "does not add an error" do
        log.beds = nil
        log.unittype_gn = 10
        property_validator.validate_shared_housing_rooms(log)
        expect(log.errors).to be_empty
      end
    end

    context "when unit type has not been answered" do
      it "does not add an error" do
        log.beds = 2
        log.unittype_gn = nil
        property_validator.validate_shared_housing_rooms(log)
        expect(log.errors).to be_empty
      end
    end

    context "when a bedsit has more than 1 bedroom" do
      before do
        log.beds = 2
        log.unittype_gn = 2
      end

      context "and the log is for 24/25 or later" do
        it "does not add an error" do
          property_validator.validate_shared_housing_rooms(log)

          expect(log.errors).to be_empty
        end
      end

      context "and the log is from before 24/25" do
        it "adds an error" do
          allow(log.form).to receive(:start_year_2024_or_later?).and_return false

          property_validator.validate_shared_housing_rooms(log)

          expect(log.errors["unittype_gn"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_bedroom_bedsit"))
          expect(log.errors["beds"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_bedroom_bedsit"))
        end
      end
    end

    context "when a bedsit has less than 1 bedroom" do
      before do
        log.beds = 0
        log.unittype_gn = 2
      end

      context "and the log is for 24/25 or later" do
        it "does not add an error" do
          property_validator.validate_shared_housing_rooms(log)

          expect(log.errors).to be_empty
        end
      end

      context "and the log is from before 24/25" do
        it "adds an error" do
          allow(log.form).to receive(:start_year_2024_or_later?).and_return false

          property_validator.validate_shared_housing_rooms(log)

          expect(log.errors["unittype_gn"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_bedroom_bedsit"))
          expect(log.errors["beds"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_bedroom_bedsit"))
        end
      end
    end

    context "when shared housing has more than 7 bedrooms" do
      let(:expected_error) { I18n.t("validations.lettings.property.unittype_gn.one_seven_bedroom_shared") }

      it "adds an error if the number of bedrooms is not between 1 and 7" do
        log.beds = 8
        log.unittype_gn = 9
        log.hhmemb = 3
        property_validator.validate_shared_housing_rooms(log)
        expect(log.errors["unittype_gn"]).to include(match(expected_error))
        expect(log.errors["beds"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_seven_bedroom_shared"))
      end
    end

    context "when shared housing has less than 1 bedrooms" do
      let(:expected_error) { I18n.t("validations.lettings.property.unittype_gn.one_seven_bedroom_shared") }

      it "adds an error if the number of bedrooms is not between 1 and 7" do
        log.beds = 0
        log.unittype_gn = 9
        log.hhmemb = 3
        property_validator.validate_shared_housing_rooms(log)
        expect(log.errors["unittype_gn"]).to include(match(expected_error))
        expect(log.errors["beds"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_seven_bedroom_shared"))
      end
    end

    context "when there are too many bedrooms for the number of household members and unit type" do
      let(:expected_error) { I18n.t("validations.lettings.property.unittype_gn.one_three_bedroom_single_tenant_shared") }

      it "adds an error" do
        log.beds = 4
        log.unittype_gn = 9
        log.hhmemb = 1
        property_validator.validate_shared_housing_rooms(log)
        expect(log.errors["unittype_gn"]).to include(match(expected_error))
        expect(log.errors["beds"]).to include(I18n.t("validations.lettings.property.unittype_gn.one_three_bedroom_single_tenant_shared"))
      end
    end
  end

  describe "#validate_unitletas" do
    context "when the property has not been let before" do
      it "validates that no previous let type is provided" do
        log.first_time_property_let_as_social_housing = 1
        log.unitletas = 0
        property_validator.validate_unitletas(log)
        expect(log.errors["unitletas"])
          .to include(match I18n.t("validations.lettings.property.unitletas.previous_let_social"))
        log.unitletas = 1
        property_validator.validate_unitletas(log)
        expect(log.errors["unitletas"])
          .to include(match I18n.t("validations.lettings.property.unitletas.previous_let_social"))
        log.unitletas = 2
        property_validator.validate_unitletas(log)
        expect(log.errors["unitletas"])
          .to include(match I18n.t("validations.lettings.property.unitletas.previous_let_social"))
        log.unitletas = 3
        property_validator.validate_unitletas(log)
        expect(log.errors["unitletas"])
          .to include(match I18n.t("validations.lettings.property.unitletas.previous_let_social"))
      end
    end

    context "when the property has been let previously" do
      it "expects to have a previous let type" do
        log.first_time_property_let_as_social_housing = 0
        log.unitletas = 0
        property_validator.validate_unitletas(log)
        expect(log.errors["unitletas"]).to be_empty
      end
    end
  end

  describe "validate_rsnvac" do
    context "when the property has not been let before" do
      it "validates that it has a first let reason for vacancy" do
        log.first_time_property_let_as_social_housing = 1
        log.rsnvac = 6
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"])
          .to include(match I18n.t("validations.lettings.property.rsnvac.first_let_social"))
      end

      it "expects to have a first let reason for vacancy" do
        log.first_time_property_let_as_social_housing = 1
        log.rsnvac = 15
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"]).to be_empty
        log.rsnvac = 16
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"]).to be_empty
        log.rsnvac = 17
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"]).to be_empty
      end
    end

    context "when the property has been let as social housing before" do
      it "validates that the reason for vacancy is not a first let as social housing reason" do
        log.first_time_property_let_as_social_housing = 0
        log.rsnvac = 15
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"])
          .to include(match I18n.t("validations.lettings.property.rsnvac.first_let_not_social"))
        log.rsnvac = 16
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"])
          .to include(match I18n.t("validations.lettings.property.rsnvac.first_let_not_social"))
        log.rsnvac = 17
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"])
          .to include(match I18n.t("validations.lettings.property.rsnvac.first_let_not_social"))
      end

      it "expects the reason for vacancy to be a first let as social housing reason" do
        log.first_time_property_let_as_social_housing = 1
        log.rsnvac = 15
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"]).to be_empty
        log.rsnvac = 16
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"]).to be_empty
        log.rsnvac = 17
        property_validator.validate_rsnvac(log)
        expect(log.errors["rsnvac"]).to be_empty
      end

      context "when the letting is not a renewal" do
        it "validates that the reason for vacancy is not renewal" do
          log.first_time_property_let_as_social_housing = 0
          log.renewal = 0
          log.rsnvac = 14
          property_validator.validate_rsnvac(log)
          expect(log.errors["rsnvac"])
                .to include(match I18n.t("validations.lettings.property.rsnvac.not_a_renewal"))
        end
      end
    end

    context "when the property has been let before" do
      let(:non_temporary_previous_tenancies) { [4, 5, 16, 21, 22] }

      context "when the previous tenancy was not temporary" do
        let(:referral_sources) { described_class::REFERRAL_INVALID_TMP }

        it "validates that the property is not being relet to tenant who occupied as temporary" do
          non_temporary_previous_tenancies.each do |prevten|
            log.rsnvac = 9
            log.prevten = prevten
            property_validator.validate_rsnvac(log)
            expect(log.errors["rsnvac"])
              .to include(match I18n.t("validations.lettings.property.rsnvac.non_temp_accommodation"))
          end
        end

        it "validates that the letting source is not a referral" do
          referral_sources.each do |src|
            log.rsnvac = 9
            log.referral = src
            property_validator.validate_rsnvac(log)
            expect(log.errors["rsnvac"])
              .to include(match I18n.t("validations.lettings.property.rsnvac.referral_invalid"))
          end
        end
      end

      context "when the previous tenancy was temporary" do
        it "expects that the property can be relet to a tenant who previously occupied it as temporary" do
          log.prevten = 0
          log.rsnvac = 2
          property_validator.validate_rsnvac(log)
          expect(log.errors["rsnvac"]).to be_empty
        end

        it "expects that the letting source can be a referral" do
          log.prevten = 0
          log.referral = 2
          property_validator.validate_rsnvac(log)
          expect(log.errors["rsnvac"]).to be_empty
        end
      end
    end
  end

  describe "#validate_uprn" do
    context "when within length limit but alphanumeric" do
      let(:log) { build(:sales_log, uprn: "123abc") }

      it "adds an error" do
        property_validator.validate_uprn(log)
        expect(log.errors.added?(:uprn, "UPRN must be 12 digits or less.")).to be true
      end
    end

    context "when over the length limit" do
      let(:log) { build(:sales_log, uprn: "1234567890123") }

      it "adds an error" do
        property_validator.validate_uprn(log)
        expect(log.errors.added?(:uprn, "UPRN must be 12 digits or less.")).to be true
      end
    end

    context "when within the limit and only numeric" do
      let(:log) { build(:sales_log, uprn: "123456789012") }

      it "does not add an error" do
        property_validator.validate_uprn(log)
        expect(log.errors).not_to be_present
      end
    end
  end
end
