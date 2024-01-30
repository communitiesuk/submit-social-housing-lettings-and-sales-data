class Form::Sales::Pages::Nationality1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_nationality"
    @depends_on = [
      {
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= if form.start_year_after_2024?
                     [
                       Form::Sales::Questions::NationalityAllGroup.new("nationality_all_group", nil, self, 1),
                       Form::Sales::Questions::NationalityAll.new("nationality_all", nil, self, 1),
                     ]
                   else
                     [Form::Sales::Questions::Nationality1.new(nil, nil, self)]
                   end
  end
end
