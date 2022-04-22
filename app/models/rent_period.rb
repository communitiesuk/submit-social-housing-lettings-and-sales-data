class RentPeriod
  def self.rent_period_mappings
    FormHandler.instance.current_form.get_question("period", nil).answer_options
  end
end
