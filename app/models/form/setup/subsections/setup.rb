class Form::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this lettings log"
    @pages = [pages]
    @section = section
  end

  def pages
    [
      Form::Setup::Pages::Organisation.new(nil, nil, self),
      Form::Setup::Pages::CreatedBy.new(nil, nil, self),
      Form::Setup::Pages::NeedsType.new(nil, nil, self),
      Form::Setup::Pages::Renewal.new(nil, nil, self),
      Form::Setup::Pages::TenancyStartDate.new(nil, nil, self),
      Form::Setup::Pages::RentType.new(nil, nil, self),
      Form::Setup::Pages::TenantCode.new(nil, nil, self),
      Form::Setup::Pages::PropertyReference.new(nil, nil, self),
    ]
  end

  def status(case_log)
    unless enabled?(case_log)
      return :cannot_start_yet
    end

    qs = applicable_questions(case_log)
    qs_optional_removed = qs.reject { |q| case_log.optional_fields.include?(q.id) }
    return :not_started if qs.all? { |question| case_log[question.id].blank? || question.read_only? || question.derived? }
    return :completed if qs_optional_removed.all? { |question| question.completed?(case_log) }

    :in_progress
  end

  def applicable_questions(case_log)
    questions.select do |q|
      (q.displayed_to_user?(case_log) && !q.derived?) ||
        q.has_inferred_check_answers_value?(case_log) ||
        %w[owning_organisation_id created_by_id].include?(q.id)
    end
  end
end
