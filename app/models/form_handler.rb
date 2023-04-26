class FormHandler
  include Singleton
  include CollectionTimeHelper
  attr_reader :forms

  SALES_SECTIONS = [
    Form::Sales::Sections::PropertyInformation,
    Form::Sales::Sections::Household,
    Form::Sales::Sections::Finances,
    Form::Sales::Sections::SaleInformation,
  ].freeze

  LETTINGS_SECTIONS = [
    Form::Lettings::Sections::TenancyAndProperty,
    Form::Lettings::Sections::Household,
    Form::Lettings::Sections::RentAndCharges,
  ].freeze

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    @forms[form]
  end

  def current_lettings_form
    forms["current_lettings"]
  end

  def current_sales_form
    forms["current_sales"]
  end

  def sales_forms
    {
      "current_sales" => Form.new(nil, current_collection_start_year, SALES_SECTIONS, "sales"),
      "previous_sales" => Form.new(nil, previous_collection_start_year, SALES_SECTIONS, "sales"),
      "next_sales" => Form.new(nil, next_collection_start_year, SALES_SECTIONS, "sales"),
    }
  end

  # there is a problem with this that is potentially more general, which is what we plan to do about
  # forms that are 2+ years old.
  # eg. if there is a question/attribute on the 21/22 form that no longer exists, we will not export that already
  # What is the status of old forms on the web app? I believe we are not allowed to edit but are we allowed to view?
  # If yes that might be a problem.
  # If not I suggest that it might be easier in this method to replace line 1 with:
  # sales_forms = [2021..2023].each { |year| Form.new(nil, year, SALES_SECTIONS, sales) }
  # sidenote, why do we save a reference to the next years sales log in the FormHandler?
  def ordered_sales_questions_for_all_years
    sales_forms = forms.filter { |name, _form| name.end_with? "sales" }.values
    ordered_questions = sales_forms.pop.questions.uniq(&:id)
    question_ids = ordered_questions.map(&:id)
    all_questions_from_previous_forms = sales_forms.flat_map(&:questions)
    deprecated_questions_by_preceding_question_id(question_ids, all_questions_from_previous_forms).each do |preceding_question_id, deprecated_question|
      index_of_preceding_question = ordered_questions.index { |q| q.id == preceding_question_id }
      ordered_questions.insert(index_of_preceding_question + 1, deprecated_question)
    end
    ordered_questions
  end

  def deprecated_questions_by_preceding_question_id(current_form_question_ids, all_questions_from_previous_forms)
    deprecated_questions = {}
    all_questions_from_previous_forms.each_cons(2) do |preceding_question, question|
      next if current_form_question_ids.include?(question.id) || deprecated_questions.values.map(&:id).include?(question.id)

      deprecated_questions[preceding_question.id] = question
    end
    deprecated_questions
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form = Form.new(form_path)

        form_to_set = form_name_from_start_year(form.start_date.year, "lettings")
        forms[form_to_set] = form if form_to_set && forms[form_to_set].blank?
      end
    end

    if forms["previous_lettings"].blank? && current_collection_start_year >= 2022
      forms["previous_lettings"] = Form.new(nil, previous_collection_start_year, LETTINGS_SECTIONS, "lettings")
    end
    forms["current_lettings"] = Form.new(nil, current_collection_start_year, LETTINGS_SECTIONS, "lettings") if forms["current_lettings"].blank?
    forms["next_lettings"] = Form.new(nil, next_collection_start_year, LETTINGS_SECTIONS, "lettings") if forms["next_lettings"].blank?

    if Rails.env.test?
      forms.merge({ fake_lettings_2021: Form.new("spec/fixtures/forms/2021_2022.json"), real_lettings_2021: Form.new("config/forms/2021_2022.json") })
    else
      forms
    end
  end

  def lettings_form_for_start_year(year)
    lettings_forms.values.find { |form| form.start_date.year == year }
  end

  def sales_form_for_start_year(year)
    sales_forms.values.find { |form| form.start_date.year == year }
  end

  def form_name_from_start_year(year, type)
    form_mappings = { 0 => "current_#{type}", 1 => "previous_#{type}", -1 => "next_#{type}" }
    form_mappings[current_collection_start_year - year]
  end

  def start_date_of_earliest_open_collection_period
    in_crossover_period? ? previous_collection_start_date : current_collection_start_date
  end

  def in_crossover_period?(now: Time.zone.now)
    lettings_in_crossover_period?(now:) || sales_in_crossover_period?(now:)
  end

  def lettings_in_crossover_period?(now: Time.zone.now)
    forms = lettings_forms.values
    forms.count { |form| now.between?(form.start_date, form.end_date) } > 1
  end

  def sales_in_crossover_period?(now: Time.zone.now)
    forms = sales_forms.values
    forms.count { |form| now.between?(form.start_date, form.end_date) } > 1
  end

  def use_fake_forms!(fake_forms = nil)
    @directories = ["spec/fixtures/forms"]
    @forms = fake_forms || get_all_forms
  end

  def use_real_forms!
    @directories = ["config/forms"]
    @forms = get_all_forms
  end

  def earliest_open_collection_start_date(now: Time.zone.now)
    if in_crossover_period?(now:)
      collection_start_date(now) - 1.year
    else
      collection_start_date(now)
    end
  end

private

  def get_all_forms
    lettings_forms.merge(sales_forms)
  end

  def directories
    @directories ||= Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
