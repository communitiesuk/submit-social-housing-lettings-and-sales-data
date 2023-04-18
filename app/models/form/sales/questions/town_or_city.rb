class Form::Sales::Questions::TownOrCity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "town_or_city"
    @header = "Town or city"
    @type = "text"
    @plain_label = true
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def hidden_in_check_answers?(_log = nil, _current_user = nil)
    true
  end
end
