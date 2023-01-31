module Spike
  class FormGeneratorService
    def initialize; end

    def call
      form = Form.new("config/forms/2022_2023.json")

      form.sections.reject { |subsection| subsection.id == "setup" }.each do |section|
        section.subsections.each do |subsection|
          subsection.pages.each do |page|
            page.questions.each do |question|
              create_question(question)
            end
            create_page(page)
          end
          create_subsection(subsection)
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
          @id = \"#{subsection.id}\"
          @label = \"#{subsection.label}\"
          @depends_on = #{subsection.depends_on}
        end

        def pages
          @pages ||= #{pages_array}.compact
        end")
      out_file.close
    end

    def create_page(page)
      questions_array = page.questions.map { |question| "Form::Lettings::Questions::#{question.id.camelize}.new(nil, nil, self)" }
      out_file = File.new("app/models/form/lettings/pages/#{page.id}.rb", "w")
      out_file.puts("class Form::Lettings::Pages::#{page.id.camelize} < ::Form::Page
        def initialize(id, hsh, subsection)
          super
          @id = \"#{page.id}\"
          @header = \"#{page.header}\"
          @depends_on = #{page.depends_on}
          @header_partial = #{page.header_partial}
          @description = \"#{page.description}\"
          @title_text = #{page.title_text}
          @informative_text = #{page.informative_text}
          @hide_subsection_label = #{page.hide_subsection_label}
          @next_unresolved_page_id = \"#{page.next_unresolved_page_id}\"
        end

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
          @type = \"#{question.type}\"
          @width = #{question.width}
          @inferred_check_answers_value = #{question.inferred_check_answers_value}
          @check_answers_card_number = #{question.check_answer_label}
          @max = #{question.max}
          @min = #{question.min}
          @guidance_partial = \"#{question.guidance_partial}\"
          @guidance_position = GuidancePosition::TOP
          @hint_text = \"#{question.hint_text}\"
          @step = #{question.step}
          @fields_to_add = #{question.fields_to_add}
          @result_field = #{question.result_field}
          @readonly = #{question.readonly}
          @answer_options = ANSWER_OPTIONS
          @conditional_for = #{question.conditional_for}
          @inferred_answers = #{question.inferred_answers}
          @hidden_in_check_answers = #{question.hidden_in_check_answers}
          @derived = #{question.derived}
          @prefix = \"#{question.prefix}\"
          @suffix = \"#{question.suffix}\"
          @requires_js = #{question.requires_js}
          @fields_added = #{question.fields_added}
          @unresolved_hint_text = #{question.unresolved_hint_text}
        end

        ANSWER_OPTIONS = #{question.answer_options}
      end")
      out_file.close
    end
  end
end
