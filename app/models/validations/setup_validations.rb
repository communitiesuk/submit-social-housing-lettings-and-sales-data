module Validations::SetupValidations
  def validate_irproduct_other(record)
    if intermediate_product_rent_type?(record) && record.irproduct_other.blank?
      record.errors.add :irproduct_other, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end

  def validate_startdate(record)
    if record.needstype == 2
      if record.startdate > Time.zone.today
        record.errors.add :startdate, I18n.t("validations.setup.startdate.today_or_earlier")
      end 
      
      if record.voiddate.present?
        if (record.startdate.to_date - record.voiddate.to_date).to_i.abs > 730
          record.errors.add :startdate, I18n.t("validations.setup.startdate.voiddate_difference")
        end 
      end 

      if record.mrcdate.present?
        if (record.startdate.to_date - record.mrcdate.to_date).to_i.abs > 730
          record.errors.add :startdate, I18n.t("validations.setup.startdate.mrcdate_difference")
        end 
      end 

      if record.scheme_id.present?
        scheme_end_date = Scheme.find(record.scheme_id).end_date
        if scheme_end_date.present?
          if record.startdate > scheme_end_date
            record.errors.add :startdate, I18n.t("validations.setup.startdate.before_scheme_end_date")
          end
        end
      end
    end
  end 

private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
