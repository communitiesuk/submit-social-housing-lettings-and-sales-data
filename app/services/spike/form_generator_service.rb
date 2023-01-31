module Spike
  class FormGeneratorService
    def initialize; end

    def call
      form = Form.new("config/forms/2022_2023.json")

      form.sections.reject { |subsection| subsection.id == "setup" }.each do |section|
        section.subsections.each do |subsection|
          subsection.pages.each do |page|
            page.questions.each do |question|
              # create_question(question)
            end
            # create_page(page)
          end
          # create_subsection(subsection)
        end
        create_section(section)
      end
    end

    def create_section(section)
      subsections_array = section.subsections.map { |s| "Form::Lettings::Subsections::#{section.id.camelize}::#{s.id.camelize}.new(nil, nil, self)" }
      out_file = File.new("app/models/form/lettings/sections/#{section.id}.rb", "w")
      out_file.puts("class Form::Lettings::Sections::#{section.id.camelize} < ::Form::Section
      def initialize(id, hsh, form)
        super
        @id = \"#{section.id}\"
        @label = \"#{section.id}\"
        @description = \"#{section.description}\"
        @form = form
        @subsections = #{subsections_array}
      end
    end")
      out_file.close
    end

    def create_subsection(subsection)
      pages_array = subsection.pages.map { |page| "Form::Lettings::Pages::#{page.id.camelize}.new(nil, nil, self)" }
      out_file = File.new("app/models/form/lettings/subsections/#{subsection.id}.rb", "w")
      out_file.puts("class Form::Lettings::Subsections::#{subsection.id.camelize} < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = \"#{subsection.id}\"")
      out_file.puts("    @label = \"#{subsection.label}\"") if subsection.label
      out_file.puts("    @depends_on = #{subsection.depends_on}") if subsection.depends_on
      out_file.puts("  end

  def pages
    @pages ||= #{pages_array}.compact
  end
end")
      out_file.close
    end

    def create_page(page)
      questions_array = page.questions.map { |question| "Form::Lettings::Questions::#{question.id.camelize}.new(nil, nil, self)" }
      out_file = File.new("app/models/form/lettings/pages/#{page.id}.rb", "w")
      out_file.puts("class Form::Lettings::Pages::#{page.id.camelize} < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = \"#{page.id}\"")
      out_file.puts("    @header = \"#{page.header}\"") if page.header
      out_file.puts("    @depends_on = #{page.depends_on}") if page.depends_on
      out_file.puts("    @header_partial = #{page.header_partial}") if page.header_partial
      out_file.puts("    @description = \"#{page.description}\"") if page.description
      out_file.puts("    @title_text = #{page.title_text}") if page.title_text
      out_file.puts("    @informative_text = #{page.informative_text}") if page.informative_text
      out_file.puts("    @hide_subsection_label = #{page.hide_subsection_label}") if page.hide_subsection_label
      out_file.puts("    @next_unresolved_page_id = \"#{page.next_unresolved_page_id}\"") if page.next_unresolved_page_id
      out_file.puts("  end

  def questions
    @questions ||= #{questions_array}
  end
end")
      out_file.close
    end

    def create_question(question)
      out_file = File.new("app/models/form/lettings/questions/#{question.id}.rb", "w")

      out_file.puts("class Form::Lettings::Questions::#{question.id.camelize} < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = \"#{question.id}\"
    @check_answer_label = \"#{question.check_answer_label}\"
    @header = \"#{question.header}\"
    @type = \"#{question.type}\"")
      out_file.puts("    @width = #{question.width}") if question.width
      out_file.puts("    @inferred_check_answers_value = #{question.inferred_check_answers_value}") if question.inferred_check_answers_value
      out_file.puts("    @check_answers_card_number = #{question.check_answer_label}") if question.check_answer_label
      out_file.puts("    @max = #{question.max}") if question.max
      out_file.puts("    @min = #{question.min}") if question.min
      out_file.puts("    @guidance_partial = \"#{question.guidance_partial}\"") if question.guidance_partial
      out_file.puts("    @hint_text = \"#{question.hint_text}\"") if question.hint_text
      out_file.puts("    @step = #{question.step}") if question.step
      out_file.puts("    @fields_to_add = #{question.fields_to_add}") if question.fields_to_add
      out_file.puts("    @result_field = #{question.result_field}") if question.result_field
      out_file.puts("    @readonly = #{question.readonly}") if question.readonly
      out_file.puts("    @answer_options = ANSWER_OPTIONS") if question.answer_options
      out_file.puts("    @conditional_for = #{question.conditional_for}") if question.conditional_for
      out_file.puts("    @inferred_answers = #{question.inferred_answers}") if question.inferred_answers
      out_file.puts("    @hidden_in_check_answers = #{question.hidden_in_check_answers}") if question.hidden_in_check_answers
      out_file.puts("    @guidance_position = #{question.guidance_position}") if question.guidance_position
      out_file.puts("    @derived = #{question.derived}") if question.derived
      out_file.puts("    @prefix = \"#{question.prefix}\"") if question.prefix
      out_file.puts("    @suffix = \"#{question.suffix}\"") if question.suffix
      out_file.puts("    @requires_js = #{question.requires_js}") if question.requires_js
      out_file.puts("    @fields_added = #{question.fields_added}") if question.fields_added
      out_file.puts("    @unresolved_hint_text = #{question.unresolved_hint_text}") if question.unresolved_hint_text
      out_file.puts("  end")
      if question.answer_options
        out_file.puts("
  ANSWER_OPTIONS = #{question.answer_options}")
      end
      out_file.puts("end")

      out_file.close
    end
  end
end
