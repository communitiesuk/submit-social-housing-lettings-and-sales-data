class Form::Lettings::Questions::PostcodeForAddressMatcher < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full_input"
    @copy_key = "lettings.property_information.address.postcode_full_input"
    @type = "text"
    @width = 5
    @plain_label = true
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @hide_question_number_on_page = true
    @hidden_in_check_answers = true
  end
end
