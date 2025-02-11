class Form::Lettings::Pages::PersonWorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_working_situation"

    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PersonWorkingSituation.new(nil, nil, self, person_index: @person_index)]
  end

  def routed_to?(log, _)
    return false unless super && log.send("details_known_#{@person_index}").zero?

    age = log.send("age#{@person_index}")
    age.nil? || age > 15
  end
end
