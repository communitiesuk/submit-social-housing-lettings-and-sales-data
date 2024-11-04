class Form::Lettings::Questions::AddressLine2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line2"
    @copy_key = "lettings.property_information.address.address_line2"
    @type = "text"
    @plain_label = true
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def hidden_in_check_answers?(_log = nil, _current_user = nil)
    true
  end
end
