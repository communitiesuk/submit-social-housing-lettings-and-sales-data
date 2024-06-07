desc "Infer nil letting allocation values as no"
task fix_nil_letting_allocation_values: :environment do
  LettingsLog.where(cbl: nil)
     .or(LettingsLog.where(chr: nil))
     .or(LettingsLog.where(cap: nil))
     .or(LettingsLog.filter_by_year(2024).where(accessible_register: nil))
     .find_each do |log|
    next unless log.cbl.present? || log.chr.present? || log.cap.present? || log.accessible_register.present? || log.letting_allocation_unknown.present?

    log.cbl = 0 if log.cbl.blank?
    log.chr = 0 if log.chr.blank?
    log.cap = 0 if log.cap.blank?
    log.accessible_register = 0 if log.form.start_year_after_2024? && log.accessible_register.blank?

    log.letting_allocation_unknown = if log.cbl == 1 || log.chr == 1 || log.cap == 1 || log.accessible_register == 1
                                       0
                                     else
                                       1
                                     end

    next if log.save

    Rails.logger.log("NilLettingsAllocationValues: Unable to save changes to log #{log.id}")
  end
end
