class LocalAuthority
  def self.ons_code_mappings
    FormHandler.instance.current_form.get_question("la", nil).answer_options
  end
end
