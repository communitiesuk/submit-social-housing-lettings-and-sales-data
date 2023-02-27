class Form::Lettings::Questions::UprnValidation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn"
    @check_answer_label = "Uprn validation"
    @header = "UPRN validation"
    @type = "text"
  end
end
