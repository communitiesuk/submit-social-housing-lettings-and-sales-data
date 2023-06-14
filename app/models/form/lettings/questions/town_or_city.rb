class Form::Lettings::Questions::TownOrCity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "town_or_city"
    @header = "Town or city"
    @type = "text"
    @plain_label = true
    @check_answer_label = "Q12 - Town or city"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end
end
