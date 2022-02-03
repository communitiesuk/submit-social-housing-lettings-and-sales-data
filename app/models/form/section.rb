class Form::Section
  attr_accessor :id, :label, :description, :subsections, :form

  def initialize(id, hsh, form)
    @id = id
    @label = hsh["label"]
    @description = hsh["description"]
    @form = form
    @subsections = hsh["subsections"].map { |s_id, s| Form::Subsection.new(s_id, s, self) }
  end
end
