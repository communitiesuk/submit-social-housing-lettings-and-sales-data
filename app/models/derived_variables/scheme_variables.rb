module DerivedVariables::SchemeVariables
  def set_derived_fields!
    if has_other_client_group == "No"
      self.secondary_client_group = nil
    end
  end
end
