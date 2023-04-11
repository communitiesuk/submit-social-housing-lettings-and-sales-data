class Form::Sales::Questions::PostcodeForFullAddress < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @header = "Postcode"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{
      "condition" => {
        "pcodenk" => 1,
      },
      "value" => "Not known",
    }]
    @inferred_answers = {
      "la" => {
        "is_la_inferred" => true,
      },
    }
    @plain_label = true
    @do_not_clear = true
  end

  def hidden_in_check_answers?(_log = nil, _current_user = nil)
    true
  end
end
