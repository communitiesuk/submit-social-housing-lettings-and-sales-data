class Form::Lettings::Pages::Outstanding < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "outstanding"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Hbrentshortfall.new(nil, nil, self)]
  end

  def routed_to?(log, _)
    return false unless super && [1, 6].include?(log.hb)

    (log.household_charge.present? && log.household_charge.zero? || log.household_charge.nil?)
  end
end
