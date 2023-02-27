class Form::Lettings::Questions::UprnQuery < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_query"
    @check_answer_label = "Uprn Query"
    @header = "UPRN query"
    @type = "text"
  end
end
