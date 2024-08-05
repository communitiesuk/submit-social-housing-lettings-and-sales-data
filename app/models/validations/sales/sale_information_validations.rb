module Validations::Sales::SaleInformationValidations
  include Validations::SharedValidations
  include CollectionTimeHelper
  include MoneyFormattingHelper

  def validate_practical_completion_date(record)
    return unless record.hodate.present? && date_valid?("hodate", record)
    return if record.saledate.blank?

    if record.hodate > record.saledate
      record.errors.add :hodate, I18n.t("validations.sale_information.hodate.must_be_before_saledate")
      record.errors.add :saledate, I18n.t("validations.sale_information.saledate.must_be_after_hodate")
    end

    if record.saledate - record.hodate >= 3.years && record.form.start_year_after_2024?
      record.errors.add :hodate, I18n.t("validations.sale_information.hodate.must_be_less_than_3_years_from_saledate")
      record.errors.add :saledate, I18n.t("validations.sale_information.saledate.must_be_less_than_3_years_from_hodate")
    end
  end

  def validate_exchange_date(record)
    return unless record.exdate && record.saledate

    if record.exdate > record.saledate
      record.errors.add :exdate, I18n.t("validations.sale_information.exdate.must_be_before_saledate")
      record.errors.add :saledate, I18n.t("validations.sale_information.saledate.must_be_after_exdate")
    end

    if record.saledate - record.exdate >= 1.year
      record.errors.add :exdate, I18n.t("validations.sale_information.exdate.must_be_less_than_1_year_from_saledate")
      record.errors.add :saledate, I18n.t("validations.sale_information.saledate.must_be_less_than_1_year_from_exdate")
    end
  end

  def validate_previous_property_unit_type(record)
    return unless record.fromprop && record.frombeds

    if record.frombeds != 1 && record.fromprop == 2
      record.errors.add :frombeds, I18n.t("validations.sale_information.previous_property_type.property_type_bedsit")
      record.errors.add :fromprop, I18n.t("validations.sale_information.previous_property_type.property_type_bedsit")
    end
  end

  def validate_discounted_ownership_value(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.value && record.deposit && record.ownershipsch
    return unless record.mortgage || record.mortgageused == 2 || record.mortgageused == 3
    return unless record.discount || record.grant || record.type == 29

    # When a percentage discount is used, a percentage tolerance is needed to account for rounding errors
    tolerance = record.discount ? record.value * 0.05 / 100 : 1

    if over_tolerance?(record.mortgage_deposit_and_grant_total, record.value_with_discount, tolerance, strict: !record.discount.nil?) && record.discounted_ownership_sale?
      %i[mortgageused mortgage value deposit ownershipsch discount grant].each do |field|
        record.errors.add field, I18n.t("validations.sale_information.discounted_ownership_value",
                                        mortgage: record.mortgage.present? ? " (#{record.field_formatted_as_currency('mortgage')})" : "",
                                        deposit: record.field_formatted_as_currency("deposit"),
                                        grant: record.grant.present? ? " (#{record.field_formatted_as_currency('grant')})" : "",
                                        mortgage_deposit_and_grant_total: record.field_formatted_as_currency("mortgage_deposit_and_grant_total"),
                                        discount_sentence: record.discount.present? ? " (#{record.field_formatted_as_currency('value')}) times by the discount (#{record.discount}%)" : "",
                                        value_with_discount: record.field_formatted_as_currency("value_with_discount"))
      end
    end
  end

  def validate_outright_sale_value_matches_mortgage_plus_deposit(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.outright_sale?
    return unless record.mortgage_used? && record.mortgage
    return unless record.deposit && record.value

    if over_tolerance?(record.mortgage_and_deposit_total, record.value, 1)
      %i[mortgageused mortgage value deposit].each do |field|
        record.errors.add field, I18n.t("validations.sale_information.outright_sale_value", mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"), value: record.field_formatted_as_currency("value"))
      end
      record.errors.add :ownershipsch, :skip_bu_error, message: I18n.t("validations.sale_information.outright_sale_value", mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"), value: record.field_formatted_as_currency("value"))
    end
  end

  def validate_basic_monthly_rent(record)
    return unless record.mrent && record.ownershipsch && record.type

    if record.shared_ownership_scheme? && !record.old_persons_shared_ownership? && record.mrent > 9999
      record.errors.add :mrent, I18n.t("validations.sale_information.monthly_rent.higher_than_expected")
      record.errors.add :type, I18n.t("validations.sale_information.monthly_rent.higher_than_expected")
    end
  end

  def validate_grant_amount(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.grant && (record.type == 8 || record.type == 21)

    unless record.grant.between?(9_000, 16_000)
      record.errors.add :grant, I18n.t("validations.sale_information.grant.out_of_range")
    end
  end

  def validate_stairbought(record)
    return unless record.stairbought && record.type
    return unless record.saledate && record.form.start_year_after_2024?

    max_stairbought = case record.type
                      when 30, 16, 28, 31, 32
                        90
                      when 2, 18
                        75
                      when 24
                        50
                      end

    if max_stairbought && record.stairbought > max_stairbought
      record.errors.add :stairbought, I18n.t("validations.sale_information.stairbought.over_max", max_stairbought:, type: record.form.get_question("type", record).answer_label(record))
      record.errors.add :type, I18n.t("validations.sale_information.stairbought.over_max", max_stairbought:, type: record.form.get_question("type", record).answer_label(record))
    end
  end

  def validate_discount_and_value(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.discount && record.value && record.la

    if record.london_property? && record.discount_value > 136_400
      %i[discount value la postcode_full uprn].each do |field|
        record.errors.add field, I18n.t("validations.sale_information.value.over_discounted_london_max", discount_value: record.field_formatted_as_currency("discount_value"))
      end
    elsif record.property_not_in_london? && record.discount_value > 102_400
      %i[discount value la postcode_full uprn].each do |field|
        record.errors.add field, I18n.t("validations.sale_information.value.over_discounted_max", discount_value: record.field_formatted_as_currency("discount_value"))
      end
    end
  end

  def validate_non_staircasing_mortgage(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.value && record.deposit && record.equity
    return unless record.shared_ownership_scheme? && record.type && record.mortgageused && record.is_not_staircasing?

    if record.social_homebuy?
      check_non_staircasing_socialhomebuy_mortgage(record)
    else
      check_non_staircasing_non_socialhomebuy_mortgage(record)
    end
  end

  def validate_staircasing_mortgage(record)
    return unless record.saledate && record.form.start_year_after_2024?
    return unless record.value && record.deposit && record.stairbought
    return unless record.shared_ownership_scheme? && record.type && record.mortgageused && record.is_staircase?

    if record.social_homebuy?
      check_staircasing_socialhomebuy_mortgage(record)
    else
      check_staircasing_non_socialhomebuy_mortgage(record)
    end
  end

  def check_non_staircasing_socialhomebuy_mortgage(record)
    return unless record.cashdis

    if record.mortgage_used?
      return unless record.mortgage

      if over_tolerance?(record.mortgage_deposit_and_discount_total, record.expected_shared_ownership_deposit_value, 1)
        %i[mortgage value deposit cashdis equity].each do |field|
          record.errors.add field, I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_used_socialhomebuy",
                                          mortgage: record.field_formatted_as_currency("mortgage"),
                                          value: record.field_formatted_as_currency("value"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          cashdis: record.field_formatted_as_currency("cashdis"),
                                          equity: "#{record.equity}%",
                                          mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                          expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_used_socialhomebuy",
                                                                 mortgage: record.field_formatted_as_currency("mortgage"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 cashdis: record.field_formatted_as_currency("cashdis"),
                                                                 equity: "#{record.equity}%",
                                                                 mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                                                 expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"))
      end
    elsif record.mortgage_not_used?
      if over_tolerance?(record.deposit_and_discount_total, record.expected_shared_ownership_deposit_value, 1)
        %i[mortgageused value deposit cashdis equity].each do |field|
          record.errors.add field, I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_not_used_socialhomebuy",
                                          deposit_and_discount_total: record.field_formatted_as_currency("deposit_and_discount_total"),
                                          expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"),
                                          value: record.field_formatted_as_currency("value"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          cashdis: record.field_formatted_as_currency("cashdis"),
                                          equity: "#{record.equity}%").html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_not_used_socialhomebuy",
                                                                 deposit_and_discount_total: record.field_formatted_as_currency("deposit_and_discount_total"),
                                                                 expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 cashdis: record.field_formatted_as_currency("cashdis"),
                                                                 equity: "#{record.equity}%").html_safe
      end
    end
  end

  def check_non_staircasing_non_socialhomebuy_mortgage(record)
    if record.mortgage_used?
      return unless record.mortgage

      if over_tolerance?(record.mortgage_and_deposit_total, record.expected_shared_ownership_deposit_value, 1)
        %i[mortgage value deposit equity].each do |field|
          record.errors.add field, I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_used", mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"), expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"))
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_used", mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"), expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"))
      end
    elsif record.mortgage_not_used?
      if over_tolerance?(record.deposit, record.expected_shared_ownership_deposit_value, 1)
        %i[mortgageused value deposit equity].each do |field|
          record.errors.add field, I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_not_used", deposit: record.field_formatted_as_currency("deposit"), expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"))
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.non_staircasing_mortgage.mortgage_not_used", deposit: record.field_formatted_as_currency("deposit"), expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"))
      end
    end
  end

  def check_staircasing_socialhomebuy_mortgage(record)
    return unless record.cashdis

    if record.mortgage_used?
      return unless record.mortgage

      if over_tolerance?(record.mortgage_deposit_and_discount_total, record.stairbought_part_of_value, 1)
        %i[mortgage value deposit cashdis stairbought].each do |field|
          record.errors.add field, I18n.t("validations.sale_information.staircasing_mortgage.mortgage_used_socialhomebuy",
                                          mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                          stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"),
                                          mortgage: record.field_formatted_as_currency("mortgage"),
                                          value: record.field_formatted_as_currency("value"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          cashdis: record.field_formatted_as_currency("cashdis"),
                                          stairbought: "#{record.stairbought}%").html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.staircasing_mortgage.mortgage_used_socialhomebuy",
                                                                 mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                                                 stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"),
                                                                 mortgage: record.field_formatted_as_currency("mortgage"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 cashdis: record.field_formatted_as_currency("cashdis"),
                                                                 stairbought: "#{record.stairbought}%").html_safe
      end
    elsif over_tolerance?(record.deposit_and_discount_total, record.stairbought_part_of_value, 1)
      %i[mortgageused value deposit cashdis stairbought].each do |field|
        record.errors.add field, I18n.t("validations.sale_information.staircasing_mortgage.mortgage_not_used_socialhomebuy",
                                        deposit_and_discount_total: record.field_formatted_as_currency("deposit_and_discount_total"),
                                        stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"),
                                        value: record.field_formatted_as_currency("value"),
                                        deposit: record.field_formatted_as_currency("deposit"),
                                        cashdis: record.field_formatted_as_currency("cashdis"),
                                        stairbought: "#{record.stairbought}%").html_safe
      end
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.staircasing_mortgage.mortgage_not_used_socialhomebuy",
                                                               deposit_and_discount_total: record.field_formatted_as_currency("deposit_and_discount_total"),
                                                               stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"),
                                                               value: record.field_formatted_as_currency("value"),
                                                               deposit: record.field_formatted_as_currency("deposit"),
                                                               cashdis: record.field_formatted_as_currency("cashdis"),
                                                               stairbought: "#{record.stairbought}%").html_safe
    end
  end

  def check_staircasing_non_socialhomebuy_mortgage(record)
    if record.mortgage_used?
      return unless record.mortgage

      if over_tolerance?(record.mortgage_and_deposit_total, record.stairbought_part_of_value, 1)
        %i[mortgage value deposit stairbought type].each do |field|
          record.errors.add field, I18n.t("validations.sale_information.staircasing_mortgage.mortgage_used", mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"), stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"))
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.staircasing_mortgage.mortgage_used", mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"), stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"))
      end
    elsif over_tolerance?(record.deposit, record.stairbought_part_of_value, 1)
      %i[mortgageused value deposit stairbought type].each do |field|
        record.errors.add field, I18n.t("validations.sale_information.staircasing_mortgage.mortgage_not_used", deposit: record.field_formatted_as_currency("deposit"), stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"))
      end
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sale_information.staircasing_mortgage.mortgage_not_used", deposit: record.field_formatted_as_currency("deposit"), stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"))
    end
  end

  def validate_mortgage_used_dont_know(record)
    return unless record.mortgage_use_unknown?

    if record.discounted_ownership_sale?
      record.errors.add :mortgageused, I18n.t("validations.invalid_option", question: "was a mortgage used for the purchase of this property?")
    end
    if record.outright_sale? && record.saledate && !record.form.start_year_after_2024?
      record.errors.add :mortgageused, I18n.t("validations.invalid_option", question: "was a mortgage used for the purchase of this property?")
      record.errors.add :saledate, I18n.t("validations.financial.mortgage_used.year")
    end
    if record.shared_ownership_scheme? && record.is_not_staircasing?
      record.errors.add :mortgageused, I18n.t("validations.invalid_option", question: "was a mortgage used for the purchase of this property?")
      record.errors.add :staircase, I18n.t("validations.financial.mortgage_used.staircasing")
    end
    if record.stairowned && !record.stairowned_100?
      record.errors.add :stairowned, I18n.t("validations.sale_information.stairowned.mortgageused_dont_know")
      record.errors.add :mortgageused, I18n.t("validations.sale_information.stairowned.mortgageused_dont_know")
    end
  end

  def over_tolerance?(expected, actual, tolerance, strict: false)
    if strict
      (expected - actual).abs > tolerance
    else
      (expected - actual).abs >= tolerance
    end
  end
end
