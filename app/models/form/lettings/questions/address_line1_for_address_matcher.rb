class Form::Lettings::Questions::AddressLine1ForAddressMatcher < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_line1"
    @header = "Address line 1"
    @error_label = "Address line 1"
    @type = "text"
    @plain_label = true
    @check_answer_label = "Address line 1"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @question_number = 12
    @hide_question_number_on_page = true
  end
end
