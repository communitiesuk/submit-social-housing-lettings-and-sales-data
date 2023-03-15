class Form::Sales::Questions::AddressLine1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line1"
    @check_answer_label = "Address"
    @header = "Address line 1"
    @type = "text"
    @plain_label = true
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    return true if log.uprn_known.nil?
    return false if log.uprn_known&.zero?
    return true if log.uprn_confirmed.nil? && log.uprn.present?
    return true if log.uprn_known == 1 && log.uprn.blank?

    log.uprn_confirmed == 1
  end

  def answer_label(log, _current_user = nil)
    [
      log.address_line1,
      log.address_line2,
      log.postcode_full,
      log.town_or_city,
      log.county,
    ].select(&:present?).join("\n")
  end

  def get_extra_check_answer_value(log)
    la = LocalAuthority.find_by(code: log.la)&.name

    la.presence
  end
end
