class Form::Sales::Pages::JointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "joint_purchase"
  end

  def depends_on
    if form.start_year_2025_or_later?
      [
        { "ownershipsch" => 1 },
        { "ownershipsch" => 2 },
      ]
    else
      [
        { "ownershipsch" => 1 },
        { "ownershipsch" => 2 },
        { "companybuy" => 2 },
      ]
    end
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::JointPurchase.new(nil, nil, self),
    ]
  end
end
