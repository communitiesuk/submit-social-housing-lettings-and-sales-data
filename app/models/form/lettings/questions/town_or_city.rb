class Form::Lettings::Questions::TownOrCity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "town_or_city"
    @header = "Town or city"
    @type = "text"
    @plain_label = true
  end

  def hidden_in_check_answers?(_log = nil, _current_user = nil)
    true
  end
end
