class Form::Sales::Pages::Buyer2Nationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_nationality"
    @depends_on = [
      {
        "joint_purchase?" => true,
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "joint_purchase?" => true,
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= if form.start_year_2024_or_later?
                     [
                       Form::Sales::Questions::NationalityAllGroup.new("nationality_all_buyer2_group", nil, self, 2),
                       Form::Sales::Questions::NationalityAll.new("nationality_all_buyer2", nil, self, 2),
                     ]
                   else
                     [Form::Sales::Questions::Buyer2Nationality.new(nil, nil, self)]
                   end
  end
end
