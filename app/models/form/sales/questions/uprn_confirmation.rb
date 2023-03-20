class Form::Sales::Questions::UprnConfirmation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_confirmed"
    @header = "Is this the property address?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answer_label = "Is this the right address?"
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No, I want to enter the address manually" },
  }.freeze

  def notification_banner(log = nil)
    return unless log&.uprn

    {
      title: "UPRN: #{log.uprn}",
      heading: [
        log.address_line1,
        log.address_line2,
        log.postcode_full,
        log.town_or_city,
        log.county,
      ].select(&:present?).join("\n"),
    }
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    log.uprn_known != 1 || log.uprn_confirmed.present?
  end
end
