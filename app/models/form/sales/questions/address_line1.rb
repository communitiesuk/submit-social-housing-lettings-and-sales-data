class Form::Sales::Questions::AddressLine1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line1"
    @check_answer_label = "Address"
    @header = "Address line 1"
    @type = "text"
    @plain_label = true
    @check_answer_label = "Q15 - Address lines 1 and 2"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_label(log, _current_user = nil)
    [
      log.address_line1,
      log.address_line2,
    ].select(&:present?).join("\n")
  end
end
