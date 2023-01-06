module DerivedVariables::SalesLogVariables
  def set_derived_fields!
    self.ethnic = 17 if ethnic_refused?
    if exdate.present?
      self.exday = exdate.day
      self.exmonth = exdate.month
      self.exyear = exdate.year
    end
    self.deposit = value if outright_sale? && mortgage_not_used?
  end
end
