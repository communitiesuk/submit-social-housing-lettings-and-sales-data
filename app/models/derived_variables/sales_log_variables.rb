module DerivedVariables::SalesLogVariables
  def set_derived_fields!
    self.ethnic = 17 if ethnic_refused?
    if exdate.present?
      self.exday = exdate.day
      self.exmonth = exdate.month
      self.exyear = exdate.year
    end
    if hodate.present?
      self.hoday = hodate.day
      self.homonth = hodate.month
      self.hoyear = hodate.year
    end
    self.deposit = value if outright_sale? && mortgage_not_used?
    if mscharge_known.present? && mscharge_known.zero?
      self.mscharge = 0
    end
  end
end
