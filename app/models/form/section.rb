class Form::Section
  attr_accessor :id, :label, :description, :subsections, :form

  def initialize(id, hsh, form)
    @id = id
    @form = form
    if hsh
      @label = hsh["label"]
      @description = hsh["description"]
      @subsections = hsh["subsections"].map { |s_id, s| Form::Subsection.new(s_id, s, self) }
    end
  end

  def displayed_in_tasklist?(log)
    subsections.any? { |subsection| subsection.displayed_in_tasklist?(log) }
  end
end
