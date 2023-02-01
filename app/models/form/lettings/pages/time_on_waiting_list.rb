class Form::Lettings::Pages::TimeOnWaitingList < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "time_on_waiting_list"
    @header = ""
    @depends_on = [{ "renewal" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Waityear.new(nil, nil, self)]
  end
end
