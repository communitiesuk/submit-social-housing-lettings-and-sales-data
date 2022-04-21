class LocalAuthority
  def self.ons_code_mappings
    FormHandler.instance.forms["2021_2022"].get_question("la", nil).answer_options
  end
end
