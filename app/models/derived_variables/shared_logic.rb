module DerivedVariables::SharedLogic
private

  def reset_invalidated_derived_values!(dependencies)
    dependencies.each do |dependency|
      any_conditions_changed = dependency[:conditions].any? { |attribute, _value| send("#{attribute}_changed?") }
      next unless any_conditions_changed

      previously_in_derived_state = dependency[:conditions].all? { |attribute, value| send("#{attribute}_was") == value }
      next unless previously_in_derived_state

      dependency[:derived_values].each do |derived_attribute, _derived_value|
        Rails.logger.debug("Cleared derived #{derived_attribute} value")
        send("#{derived_attribute}=", nil)
      end
    end
  end

  def set_encoded_derived_values!(dependencies)
    dependencies.each do |dependency|
      derivation_applies = dependency[:conditions].all? { |attribute, value| send(attribute) == value }
      if derivation_applies
        dependency[:derived_values].each { |attribute, value| send("#{attribute}=", value) }
      end
    end
  end
end
