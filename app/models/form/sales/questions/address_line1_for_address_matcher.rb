class Form::Sales::Questions::AddressLine1ForAddressMatcher < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line1_input"
    @copy_key = "sales.property_information.address_matcher.address_line1_input"
    @error_label = "Address line 1"
    @type = "text"
    @plain_label = true
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @hide_question_number_on_page = true
  end

  def answer_label(log, _current_user = nil)
    [
      log.address_line1_input,
      log.postcode_full_input,
    ].select(&:present?).join("\n")
  end
end
