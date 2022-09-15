class Form::Lettings::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this lettings log"
    @section = section
  end

  def pages
    @pages ||= [
      Form::Common::Pages::Organisation.new(nil, nil, self),
      Form::Common::Pages::CreatedBy.new(nil, nil, self),
      Form::Lettings::Pages::NeedsType.new(nil, nil, self),
      Form::Lettings::Pages::Scheme.new(nil, nil, self),
      Form::Lettings::Pages::Location.new(nil, nil, self),
      Form::Lettings::Pages::Renewal.new(nil, nil, self),
      Form::Lettings::Pages::TenancyStartDate.new(nil, nil, self),
      Form::Lettings::Pages::RentType.new(nil, nil, self),
      Form::Lettings::Pages::TenantCode.new(nil, nil, self),
      Form::Lettings::Pages::PropertyReference.new(nil, nil, self),
    ]
  end

  def applicable_questions(lettings_log)
    questions.select { |q| support_only_questions.include?(q.id) } + super
  end

  def enabled?(_lettings_log)
    true
  end

private

  def support_only_questions
    %w[owning_organisation_id created_by_id].freeze
  end
end
