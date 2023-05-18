if Rails.env.test?
  class FormFixture < Form
    attr_accessor :sections, :subsections, :pages, :questions
  end

  class FormFactory
    def initialize(year:, type:)
      @year = year
      @type = type
    end

    def with_sections(sections)
      @sections = sections
      self
    end

    def build
      form = FormFixture.new(nil, @year, [], @type)
      @sections.each { |section| section.form = form }
      form.sections = @sections
      form.subsections = form.sections.flat_map(&:subsections)
      form.pages = form.subsections.flat_map(&:pages)
      form.questions = form.pages.flat_map(&:questions)
      form
    end
  end
end
