module Validations::Sales::HouseholdValidations
  include Validations::SharedValidations

  def validate_buyers_living_in_property(record)
    if record.buyers_will_live_in? && record.buyer_one_will_not_live_in_property? && record.buyer_two_will_not_live_in_property?
      record.errors.add :buylivein, I18n.t("validations.sales.household.buylivein.buyers_will_live_in_property_values_inconsistent")
      record.errors.add :buy1livein, I18n.t("validations.sales.household.buy1livein.buyers_will_live_in_property_values_inconsistent")
      record.errors.add :buy2livein, I18n.t("validations.sales.household.buy2livein.buyers_will_live_in_property_values_inconsistent")
    end
  end

  def validate_buyer1_previous_tenure(record)
    return unless record.saledate
    return unless record.discounted_ownership_sale? && record.prevten

    if [3, 4, 5, 6, 7, 9, 0].include?(record.prevten)
      record.errors.add :prevten, I18n.t("validations.sales.household.prevten.prevten_invalid_for_discounted_sale")
      record.errors.add :ownershipsch, I18n.t("validations.sales.household.ownershipsch.prevten_invalid_for_discounted_sale")
    end
  end

  def validate_person_age_matches_economic_status(record)
    (2..6).each do |person_num|
      age = record.public_send("age#{person_num}")
      economic_status = record.public_send("ecstat#{person_num}")
      next unless age && economic_status

      if person_is_economic_child?(economic_status) && age > 16
        record.errors.add "ecstat#{person_num}", I18n.t("validations.sales.household.ecstat.child_over_16", person_num:)
        record.errors.add "age#{person_num}", I18n.t("validations.sales.household.age.child_over_16", person_num:)
      end
    end
  end

  def validate_buyer_not_child(record)
    return unless record.saledate

    record.errors.add "ecstat1", I18n.t("validations.sales.household.ecstat1.buyer_cannot_be_child") if person_is_economic_child?(record.ecstat1)
    record.errors.add "ecstat2", I18n.t("validations.sales.household.ecstat2.buyer_cannot_be_child") if person_is_economic_child?(record.ecstat2) && record.joint_purchase?
  end

private

  def person_is_economic_child?(economic_status)
    economic_status == 9
  end

  def person_is_child?(relationship)
    relationship == "C"
  end
end
