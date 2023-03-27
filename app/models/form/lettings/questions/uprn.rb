class Form::Lettings::Questions::Uprn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn"
    @check_answer_label = "UPRN"
    @header = "What is the property's UPRN"
    @type = "text"
    @hint_text = "The Unique Property Reference Number (UPRN) is a unique number system created by Ordnance Survey and used by housing providers and sectors UK-wide. For example 10010457355."
    @width = 10
    @question_number = 11
  end

  def unanswered_error_message
    I18n.t("validations.property.uprn.invalid")
  end

  def get_extra_check_answer_value(log)
    value = [
      log.address_line1,
      log.address_line2,
      log.town_or_city,
      log.county,
      log.postcode_full,
      (LocalAuthority.find_by(code: log.la)&.name if log.la.present?),
    ].select(&:present?)

    return unless value.any?

    "\n\n#{value.join("\n")}"
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    log.uprn_known != 1
  end
end
