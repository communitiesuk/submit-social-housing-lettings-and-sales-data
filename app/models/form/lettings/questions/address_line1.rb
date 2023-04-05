class Form::Lettings::Questions::AddressLine1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line1"
    @check_answer_label = "Address"
    @header = "Address line 1"
    @type = "text"
    @plain_label = true
    @check_answer_label = "Q12 - Address"
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
    return unless log.is_la_inferred?

    la = LocalAuthority.find_by(code: log.la)&.name

    la.presence
  end
end
