class Form::Setup::Questions::OwningOrganisationId < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Owning organisation"
    @header = "Which organisation is the owning organisation for this log?"
    @hint_text = ""
    @type = "select"
    @page = page
    @answer_options = answer_options_values
  end

  def answer_options_values
    hsh = { "" => "Select an option" }
    Organisation.all.each_with_object(hsh) do |organisation, hsh|
      hsh[organisation.id] = organisation.name
      hsh
    end
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def hidden_in_check_answers
    !form.current_user.support?
  end
end
