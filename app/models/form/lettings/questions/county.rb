class Form::Lettings::Questions::County < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "county"
    @header = "County (optional)"
    @type = "text"
    @plain_label = true
    @do_not_clear = true
  end

  def hidden_in_check_answers?(_log = nil, _current_user = nil)
    true
  end
end
