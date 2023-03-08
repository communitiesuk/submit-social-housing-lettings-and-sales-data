class Form::Sales::Pages::PrivacyNotice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "privacy_notice"
    @header = "Department for Levelling Up, Housing and Communities privacy notice"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PrivacyNotice.new(nil, nil, self),
    ]
  end
end
