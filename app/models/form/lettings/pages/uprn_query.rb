class Form::Lettings::Pages::UprnQuery < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_query"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnQuery.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, _current_user)
    true
  end
end
