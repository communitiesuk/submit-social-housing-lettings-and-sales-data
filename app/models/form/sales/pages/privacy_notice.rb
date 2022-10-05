class Form::Sales::Pages::PrivacyNotice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "privacy_notice"
    @header = "Department for Levelling Up, Housing and Communities privacy notice"
    @description = "Make sure that the buyer has seen the Department for Levelling Up, Housing and Communities (DLUHC) privacy notice before completing this log"
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PrivacyNotice.new(nil, nil, self),
    ]
  end
end
