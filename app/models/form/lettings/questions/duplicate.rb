class Form::Lettings::Questions::Duplicate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "duplicate"
    @check_answer_label = "Look at all these duplicates"
    @header = "Look at all these duplicates"
    @type = "duplicate"
    @hint_text = ""
  end
end
