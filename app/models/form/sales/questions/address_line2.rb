class Form::Sales::Questions::AddressLine2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line2"
    @header = "Address line 2 (optional)"
    @type = "text"
    @plain_label = true
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def hidden_in_check_answers?(_log = nil, _current_user = nil)
    true
  end
end
