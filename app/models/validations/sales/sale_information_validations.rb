module Validations::Sales::SaleInformationValidations
  include Validations::SharedValidations
  include CollectionTimeHelper
  include MoneyFormattingHelper

  def validate_practical_completion_date(record)
    return unless record.hodate.present? && date_valid?("hodate", record)
    return if record.saledate.blank?

    if record.hodate > record.saledate
      record.errors.add :hodate, I18n.t("validations.sales.sale_information.hodate.must_be_before_saledate")
      record.errors.add :saledate, I18n.t("validations.sales.sale_information.saledate.must_be_after_hodate")
    end

    if record.saledate - record.hodate >= 3.years && record.form.start_year_2024_or_later?
      record.errors.add :hodate, I18n.t("validations.sales.sale_information.hodate.must_be_less_than_3_years_from_saledate")
      record.errors.add :saledate, I18n.t("validations.sales.sale_information.saledate.must_be_less_than_3_years_from_hodate")
    end
  end

  def validate_exchange_date(record)
    return unless record.exdate && record.saledate

    if record.exdate > record.saledate
      record.errors.add :exdate, I18n.t("validations.sales.sale_information.exdate.must_be_before_saledate")
      record.errors.add :saledate, I18n.t("validations.sales.sale_information.saledate.must_be_after_exdate")
    end

    if record.saledate - record.exdate >= 1.year
      record.errors.add :exdate, I18n.t("validations.sales.sale_information.exdate.must_be_less_than_1_year_from_saledate")
      record.errors.add :saledate, I18n.t("validations.sales.sale_information.saledate.must_be_less_than_1_year_from_exdate")
    end
  end

  def validate_staircasing_initial_purchase_date(record)
    return unless record.initialpurchase

    if record.initialpurchase < Time.zone.local(1980, 1, 1)
      record.errors.add :initialpurchase, I18n.t("validations.sales.sale_information.initialpurchase.must_be_after_1980")
    end
  end

  def validate_previous_property_unit_type(record)
    return unless record.fromprop && record.frombeds

    if record.frombeds != 1 && record.fromprop == 2
      record.errors.add :frombeds, I18n.t("validations.sales.sale_information.frombeds.previous_property_type_bedsit")
      record.errors.add :fromprop, I18n.t("validations.sales.sale_information.fromprop.previous_property_type_bedsit")
    end
  end

  def validate_discounted_ownership_value(record)
    return unless record.saledate && record.form.start_year_2024_or_later?
    return unless record.value && record.deposit && record.ownershipsch
    return unless record.mortgage || record.mortgageused == 2 || record.mortgageused == 3
    return unless record.discount || record.grant || record.type == 29

    # When a percentage discount is used, a percentage tolerance is needed to account for rounding errors
    tolerance = record.discount ? record.value * 0.05 / 100 : 1

    if over_tolerance?(record.mortgage_deposit_and_grant_total, record.value_with_discount, tolerance, strict: !record.discount.nil?) && record.discounted_ownership_sale?
      deposit_and_grant_sentence = record.grant.present? ? ", cash deposit (#{record.field_formatted_as_currency('deposit')}), and grant (#{record.field_formatted_as_currency('grant')})" : " and cash deposit (#{record.field_formatted_as_currency('deposit')})"
      discount_sentence = record.discount.present? ? " (#{record.field_formatted_as_currency('value')}) subtracted by the sum of the full purchase price (#{record.field_formatted_as_currency('value')}) multiplied by the percentage discount (#{record.discount}%)" : ""
      %i[mortgageused mortgage value deposit ownershipsch discount grant].each do |field|
        record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.discounted_ownership_value",
                                        mortgage: record.mortgage&.positive? ? " (#{record.field_formatted_as_currency('mortgage')})" : "",
                                        deposit_and_grant_sentence:,
                                        mortgage_deposit_and_grant_total: record.field_formatted_as_currency("mortgage_deposit_and_grant_total"),
                                        discount_sentence:,
                                        value_with_discount: record.field_formatted_as_currency("value_with_discount")).html_safe
      end
    end
  end

  def validate_outright_sale_value_matches_mortgage_plus_deposit(record)
    return unless record.saledate && record.form.start_year_2024_or_later?
    return unless record.outright_sale?
    return unless record.mortgage_used? && record.mortgage
    return unless record.deposit && record.value

    if over_tolerance?(record.mortgage_and_deposit_total, record.value, 1)
      %i[mortgageused mortgage value deposit].each do |field|
        record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.outright_sale_value",
                                        mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"),
                                        mortgage: record.mortgage&.positive? ? " (#{record.field_formatted_as_currency('mortgage')})" : "",
                                        deposit: record.field_formatted_as_currency("deposit"),
                                        value: record.field_formatted_as_currency("value")).html_safe
      end
      record.errors.add :ownershipsch, :skip_bu_error, message: I18n.t("validations.sales.sale_information.ownershipsch.outright_sale_value",
                                                                       mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"),
                                                                       mortgage: record.mortgage&.positive? ? " (#{record.field_formatted_as_currency('mortgage')})" : "",
                                                                       deposit: record.field_formatted_as_currency("deposit"),
                                                                       value: record.field_formatted_as_currency("value")).html_safe
    end
  end

  def validate_basic_monthly_rent(record)
    return unless record.mrent && record.ownershipsch && record.type

    if record.shared_ownership_scheme? && !record.old_persons_shared_ownership? && record.mrent > 9999
      record.errors.add :mrent, I18n.t("validations.sales.sale_information.mrent.monthly_rent_higher_than_expected")
      record.errors.add :type, I18n.t("validations.sales.sale_information.type.monthly_rent_higher_than_expected")
    end
  end

  def validate_grant_amount(record)
    return unless record.saledate && record.form.start_year_2024_or_later?
    return unless record.grant && (record.type == 8 || record.type == 21)

    unless record.grant.between?(9_000, 16_000)
      record.errors.add :grant, I18n.t("validations.sales.sale_information.grant.out_of_range")
    end
  end

  def validate_stairbought(record)
    return unless record.stairbought && record.type
    return unless record.saledate && record.form.start_year_2024_or_later?

    max_stairbought = case record.type
                      when 30, 16, 28, 31, 32
                        90
                      when 2, 18
                        75
                      when 24
                        50
                      end

    if max_stairbought && record.stairbought > max_stairbought
      record.errors.add :stairbought, I18n.t("validations.sales.sale_information.stairbought.stairbought_over_max", max_stairbought:, type: record.form.get_question("type", record).answer_label(record))
      record.errors.add :type, I18n.t("validations.sales.sale_information.type.stairbought_over_max", max_stairbought:, type: record.form.get_question("type", record).answer_label(record))
    end
  end

  def validate_discount_and_value(record)
    return unless record.saledate && record.form.start_year_2024_or_later?
    return unless record.discount && record.value && record.la

    if record.london_property? && record.discount_value > 136_400
      %i[discount value la postcode_full uprn].each do |field|
        record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.value_over_discounted_london_max", discount_value: record.field_formatted_as_currency("discount_value"))
      end
    elsif record.property_not_in_london? && record.discount_value > 102_400
      %i[discount value la postcode_full uprn].each do |field|
        record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.value_over_discounted_max", discount_value: record.field_formatted_as_currency("discount_value"))
      end
    end
  end

  def validate_non_staircasing_mortgage(record)
    return unless record.saledate && record.form.start_year_2024_or_later?
    return unless record.value && record.deposit && record.equity
    return unless record.shared_ownership_scheme? && record.type && record.mortgageused && record.is_not_staircasing?

    if record.social_homebuy?
      check_non_staircasing_socialhomebuy_mortgage(record)
    else
      check_non_staircasing_non_socialhomebuy_mortgage(record)
    end
  end

  def validate_staircasing_mortgage(record)
    return unless record.saledate && record.form.start_year_2024_or_later?
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
          record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.non_staircasing_mortgage.mortgage_used_socialhomebuy",
                                          mortgage: record.field_formatted_as_currency("mortgage"),
                                          value: record.field_formatted_as_currency("value"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          cashdis: record.field_formatted_as_currency("cashdis"),
                                          equity: "#{record.equity}%",
                                          mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                          expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.non_staircasing_mortgage.mortgage_used_socialhomebuy",
                                                                 mortgage: record.field_formatted_as_currency("mortgage"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 cashdis: record.field_formatted_as_currency("cashdis"),
                                                                 equity: "#{record.equity}%",
                                                                 mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                                                 expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
      end
    elsif record.mortgage_not_used?
      if over_tolerance?(record.deposit_and_discount_total, record.expected_shared_ownership_deposit_value, 1)
        %i[mortgageused value deposit cashdis equity].each do |field|
          record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.non_staircasing_mortgage.mortgage_not_used_socialhomebuy",
                                          deposit_and_discount_total: record.field_formatted_as_currency("deposit_and_discount_total"),
                                          expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value"),
                                          value: record.field_formatted_as_currency("value"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          cashdis: record.field_formatted_as_currency("cashdis"),
                                          equity: "#{record.equity}%").html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.non_staircasing_mortgage.mortgage_not_used_socialhomebuy",
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
          record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.non_staircasing_mortgage.mortgage_used",
                                          mortgage: record.field_formatted_as_currency("mortgage"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          value: record.field_formatted_as_currency("value"),
                                          equity: "#{record.equity}%",
                                          mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"),
                                          expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.non_staircasing_mortgage.mortgage_used",
                                                                 mortgage: record.field_formatted_as_currency("mortgage"),
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 equity: "#{record.equity}%",
                                                                 mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"),
                                                                 expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
      end
    elsif record.mortgage_not_used?
      if over_tolerance?(record.deposit, record.expected_shared_ownership_deposit_value, 1)
        %i[mortgageused value deposit equity].each do |field|
          record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.non_staircasing_mortgage.mortgage_not_used",
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          value: record.field_formatted_as_currency("value"),
                                          expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.non_staircasing_mortgage.mortgage_not_used",
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 expected_shared_ownership_deposit_value: record.field_formatted_as_currency("expected_shared_ownership_deposit_value")).html_safe
      end
    end
  end

  def check_staircasing_socialhomebuy_mortgage(record)
    return unless record.cashdis

    if record.mortgage_used?
      return unless record.mortgage

      if over_tolerance?(record.mortgage_deposit_and_discount_total, record.stairbought_part_of_value, 1)
        %i[mortgage value deposit cashdis stairbought].each do |field|
          record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.staircasing_mortgage.mortgage_used_socialhomebuy",
                                          mortgage_deposit_and_discount_total: record.field_formatted_as_currency("mortgage_deposit_and_discount_total"),
                                          stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"),
                                          mortgage: record.field_formatted_as_currency("mortgage"),
                                          value: record.field_formatted_as_currency("value"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          cashdis: record.field_formatted_as_currency("cashdis"),
                                          stairbought: "#{record.stairbought}%").html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_used_socialhomebuy",
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
        record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.staircasing_mortgage.mortgage_not_used_socialhomebuy",
                                        deposit_and_discount_total: record.field_formatted_as_currency("deposit_and_discount_total"),
                                        stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value"),
                                        value: record.field_formatted_as_currency("value"),
                                        deposit: record.field_formatted_as_currency("deposit"),
                                        cashdis: record.field_formatted_as_currency("cashdis"),
                                        stairbought: "#{record.stairbought}%").html_safe
      end
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_not_used_socialhomebuy",
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
        %i[mortgage value deposit stairbought].each do |field|
          record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.staircasing_mortgage.mortgage_used",
                                          mortgage: record.field_formatted_as_currency("mortgage"),
                                          deposit: record.field_formatted_as_currency("deposit"),
                                          mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"),
                                          value: record.field_formatted_as_currency("value"),
                                          stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value")).html_safe
        end
        record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_used",
                                                                 mortgage: record.field_formatted_as_currency("mortgage"),
                                                                 deposit: record.field_formatted_as_currency("deposit"),
                                                                 mortgage_and_deposit_total: record.field_formatted_as_currency("mortgage_and_deposit_total"),
                                                                 value: record.field_formatted_as_currency("value"),
                                                                 stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value")).html_safe
      end
    elsif over_tolerance?(record.deposit, record.stairbought_part_of_value, 1)
      %i[mortgageused value deposit stairbought].each do |field|
        record.errors.add field, I18n.t("validations.sales.sale_information.#{field}.staircasing_mortgage.mortgage_not_used",
                                        deposit: record.field_formatted_as_currency("deposit"),
                                        value: record.field_formatted_as_currency("value"),
                                        stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value")).html_safe
      end
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.sale_information.type.staircasing_mortgage.mortgage_not_used",
                                                               deposit: record.field_formatted_as_currency("deposit"),
                                                               value: record.field_formatted_as_currency("value"),
                                                               stairbought_part_of_value: record.field_formatted_as_currency("stairbought_part_of_value")).html_safe
    end
  end

  def validate_mortgage_used_dont_know(record)
    return unless record.mortgage_use_unknown?

    if record.discounted_ownership_sale?
      record.errors.add :mortgageused, I18n.t("validations.invalid_option", question: "was a mortgage used for the purchase of this property?")
    end
    if record.outright_sale? && record.saledate && !record.form.start_year_2024_or_later?
      record.errors.add :mortgageused, I18n.t("validations.invalid_option", question: "was a mortgage used for the purchase of this property?")
      record.errors.add :saledate, I18n.t("validations.sales.sale_information.saledate.mortgage_used_year")
    end
    if record.shared_ownership_scheme? && record.is_not_staircasing?
      record.errors.add :mortgageused, I18n.t("validations.invalid_option", question: "was a mortgage used for the purchase of this property?")
      record.errors.add :staircase, I18n.t("validations.sales.sale_information.staircase.mortgage_used_value")
    end
    if record.stairowned && !record.stairowned_100?
      record.errors.add :stairowned, I18n.t("validations.sales.sale_information.stairowned.mortgageused_dont_know")
      record.errors.add :mortgageused, I18n.t("validations.sales.sale_information.mortgageused.mortgageused_dont_know")
    end
  end

  def validate_number_of_staircase_transactions(record)
    return unless record.numstair

    if record.firststair == 2 && record.numstair < 2
      record.errors.add :numstair, I18n.t("validations.sales.sale_information.numstair.must_be_greater_than_one")
      record.errors.add :firststair, I18n.t("validations.sales.sale_information.firststair.more_than_one_transaction")
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
