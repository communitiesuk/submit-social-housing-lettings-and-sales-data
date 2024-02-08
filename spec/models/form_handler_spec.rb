require "rails_helper"

RSpec.describe FormHandler do
  let(:form_handler) { described_class.instance }
  let(:now) { Time.utc(2022, 9, 20) }

  around do |example|
    Timecop.freeze(now) do
      Singleton.__init__(described_class)
      example.run
    end
  end

  context "when accessing a form in a different year" do
    let(:now) { Time.utc(2021, 8, 3) }

    it "is able to load a current lettings form" do
      form = form_handler.get_form("current_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
    end

    it "is able to load a next lettings form" do
      form = form_handler.get_form("next_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
    end
  end

  describe "Get all forms" do
    it "is able to load all the forms" do
      all_forms = form_handler.forms
      expect(all_forms.count).to be >= 1
      expect(all_forms["current_sales"]).to be_a(Form)
    end

    context "when in 23/24 period or later" do
      let(:now) { Time.utc(2023, 6, 7) }

      it "does not load outdated forms" do
        all_forms = form_handler.forms
        expect(all_forms.keys).not_to include nil
      end

      it "loads archived forms" do
        all_forms = form_handler.forms
        expect(all_forms.keys).to include("archived_sales")
        expect(all_forms.keys).to include("archived_lettings")
      end
    end
  end

  describe "Get specific form" do
    let(:now) { Time.utc(2023, 9, 20) }

    it "is able to load a current lettings form" do
      form = form_handler.get_form("current_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
      expect(form.name).to eq("2023_2024_lettings")
    end

    it "is able to load a previous lettings form" do
      form = form_handler.get_form("previous_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
      expect(form.name).to eq("2022_2023_lettings")
    end

    it "is able to load a archived lettings form" do
      form = form_handler.get_form("archived_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
      expect(form.name).to eq("2021_2022_lettings")
    end

    it "is able to load a current sales form" do
      form = form_handler.get_form("current_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
      expect(form.name).to eq("2023_2024_sales")
    end

    it "is able to load a previous sales form" do
      form = form_handler.get_form("previous_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
      expect(form.name).to eq("2022_2023_sales")
    end

    it "is able to load a archived sales form" do
      form = form_handler.get_form("archived_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to be_positive
      expect(form.name).to eq("2021_2022_sales")
    end
  end

  describe "Current form" do
    it "returns the latest form by date" do
      form = form_handler.current_lettings_form
      expect(form).to be_a(Form)
      expect(form.start_date.year).to eq(2022)
    end
  end

  describe "Current collection start year" do
    context "when the date is after 1st of April" do
      let(:now) { Time.utc(2023, 8, 3) }

      it "returns the same year as the current start year" do
        expect(form_handler.current_collection_start_year).to eq(2023)
      end

      it "returns the correct current lettings form name" do
        expect(form_handler.form_name_from_start_year(2023, "lettings")).to eq("current_lettings")
      end

      it "returns the correct previous lettings form name" do
        expect(form_handler.form_name_from_start_year(2022, "lettings")).to eq("previous_lettings")
      end

      it "returns the correct next lettings form name" do
        expect(form_handler.form_name_from_start_year(2024, "lettings")).to eq("next_lettings")
      end

      it "returns the correct archived lettings form name" do
        expect(form_handler.form_name_from_start_year(2021, "lettings")).to eq("archived_lettings")
      end

      it "returns the correct current sales form name" do
        expect(form_handler.form_name_from_start_year(2023, "sales")).to eq("current_sales")
      end

      it "returns the correct previous sales form name" do
        expect(form_handler.form_name_from_start_year(2022, "sales")).to eq("previous_sales")
      end

      it "returns the correct next sales form name" do
        expect(form_handler.form_name_from_start_year(2024, "sales")).to eq("next_sales")
      end

      it "returns the correct archived sales form name" do
        expect(form_handler.form_name_from_start_year(2021, "sales")).to eq("archived_sales")
      end

      it "returns the correct current start date" do
        expect(form_handler.current_collection_start_date).to eq(Time.zone.local(2023, 4, 1))
      end
    end

    context "with the date before 1st of April" do
      let(:now) { Time.utc(2023, 2, 3) }

      it "returns the previous year as the current start year" do
        expect(form_handler.current_collection_start_year).to eq(2022)
      end

      it "returns the correct current lettings form name" do
        expect(form_handler.form_name_from_start_year(2022, "lettings")).to eq("current_lettings")
      end

      it "returns the correct previous lettings form name" do
        expect(form_handler.form_name_from_start_year(2021, "lettings")).to eq("previous_lettings")
      end

      it "returns the correct next lettings form name" do
        expect(form_handler.form_name_from_start_year(2023, "lettings")).to eq("next_lettings")
      end

      it "returns the correct archived lettings form name" do
        expect(form_handler.form_name_from_start_year(2020, "lettings")).to eq("archived_lettings")
      end

      it "returns the correct current sales form name" do
        expect(form_handler.form_name_from_start_year(2022, "sales")).to eq("current_sales")
      end

      it "returns the correct previous sales form name" do
        expect(form_handler.form_name_from_start_year(2021, "sales")).to eq("previous_sales")
      end

      it "returns the correct next sales form name" do
        expect(form_handler.form_name_from_start_year(2023, "sales")).to eq("next_sales")
      end

      it "returns the correct archived sales form name" do
        expect(form_handler.form_name_from_start_year(2020, "sales")).to eq("archived_sales")
      end
    end
  end

  it "loads the form once at boot time" do
    form_handler = described_class.instance
    expect(Form).not_to receive(:new).with(:any, "current_sales")
    expect(form_handler.get_form("current_sales")).to be_a(Form)
  end

  it "correctly sets form type and start year" do
    form = form_handler.forms["current_lettings"]
    expect(form.type).to eq("lettings")
    expect(form.start_date.year).to eq(2022)
  end

  # rubocop:disable RSpec/PredicateMatcher
  describe "#in_crossover_period?" do
    context "when not in overlapping period" do
      it "returns false" do
        expect(form_handler.in_crossover_period?(now: Date.new(2023, 1, 1))).to be_falsey
      end
    end

    context "when in overlapping period" do
      it "returns true" do
        expect(form_handler.in_crossover_period?(now: Date.new(2022, 6, 1))).to be_truthy
      end
    end
  end

  describe "lettings_forms" do
    context "when current and previous forms are defined in JSON (current collection start year before 2023)" do
      let(:now) { Time.utc(2022, 9, 20) }

      it "creates a next_lettings form from ruby form objects" do
        expect(form_handler.lettings_forms["previous_lettings"]).to be_present
        expect(form_handler.lettings_forms["previous_lettings"].start_date.year).to eq(2021)
        expect(form_handler.lettings_forms["current_lettings"]).to be_present
        expect(form_handler.lettings_forms["current_lettings"].start_date.year).to eq(2022)
        expect(form_handler.lettings_forms["next_lettings"]).to be_present
        expect(form_handler.lettings_forms["next_lettings"].start_date.year).to eq(2023)
      end
    end

    context "when only previous form is defined in JSON (current collection start year 2023)" do
      let(:now) { Time.utc(2023, 9, 20) }

      it "creates current_lettings and next_lettings forms from ruby form objects" do
        expect(form_handler.lettings_forms["archived_lettings"]).to be_present
        expect(form_handler.lettings_forms["archived_lettings"].start_date.year).to eq(2021)
        expect(form_handler.lettings_forms["previous_lettings"]).to be_present
        expect(form_handler.lettings_forms["previous_lettings"].start_date.year).to eq(2022)
        expect(form_handler.lettings_forms["current_lettings"]).to be_present
        expect(form_handler.lettings_forms["current_lettings"].start_date.year).to eq(2023)
        expect(form_handler.lettings_forms["next_lettings"]).to be_present
        expect(form_handler.lettings_forms["next_lettings"].start_date.year).to eq(2024)
      end
    end

    context "when only archived form form is defined in JSON (current collection start year 2024 onwards)" do
      let(:now) { Time.utc(2024, 9, 20) }

      it "creates previous_lettings, current_lettings and next_lettings forms from ruby form objects and archived form from json" do
        expect(form_handler.lettings_forms["archived_lettings"]).to be_present
        expect(form_handler.lettings_forms["archived_lettings"].start_date.year).to eq(2022)
        expect(form_handler.lettings_forms["previous_lettings"]).to be_present
        expect(form_handler.lettings_forms["previous_lettings"].start_date.year).to eq(2023)
        expect(form_handler.lettings_forms["current_lettings"]).to be_present
        expect(form_handler.lettings_forms["current_lettings"].start_date.year).to eq(2024)
        expect(form_handler.lettings_forms["next_lettings"]).to be_present
        expect(form_handler.lettings_forms["next_lettings"].start_date.year).to eq(2025)
      end
    end
  end

  describe "#ordered_sales_questions_for_all_years" do
    let(:result) { described_class.instance.ordered_sales_questions_for_all_years }
    let(:now) { Time.zone.now }

    it "returns an array of questions" do
      section = build(:section, :with_questions, question_ids: %w[1 2 3])
      sales_form = FormFactory.new(year: 1936, type: "sales")
                              .with_sections([section])
                              .build
      described_class.instance.use_fake_forms!({ "current_sales" => sales_form })
      expect(result).to(satisfy { |result| result.all? { |element| element.is_a?(Form::Question) } })
    end

    it "does not return multiple questions with the same id" do
      first_section = build(:section, :with_questions, question_ids: %w[1 2 3])
      second_section = build(:section, :with_questions, question_ids: %w[2 3 4 5])
      sales_form = FormFactory.new(year: 1936, type: "sales")
                              .with_sections([first_section, second_section])
                              .build
      described_class.instance.use_fake_forms!({ "current_sales" => sales_form })
      expect(result.map(&:id)).to eq %w[1 2 3 4 5]
    end

    it "returns the questions in the same order as the form" do
      first_section = build(:section, :with_questions, question_ids: %w[1 2 3])
      second_section = build(:section, :with_questions, question_ids: %w[4 5 6])
      sales_form = FormFactory.new(year: 1945, type: "sales")
                              .with_sections([first_section, second_section])
                              .build
      described_class.instance.use_fake_forms!({ "current_sales" => sales_form })
      expect(result.map(&:id)).to eq %w[1 2 3 4 5 6]
    end

    it "inserts questions from all years in their correct positions" do
      original_section = build(:section, :with_questions, question_ids: %w[1 1a_deprecated 2 3])
      new_section = build(:section, :with_questions, question_ids: %w[1 2 2a_new 3])
      original_form = FormFactory.new(year: 1066, type: "sales")
                                 .with_sections([original_section])
                                 .build
      new_form = FormFactory.new(year: 1485, type: "sales")
                            .with_sections([new_section])
                            .build
      fake_forms = {
        "previous_sales" => original_form,
        "current_sales" => new_form,
      }
      described_class.instance.use_fake_forms!(fake_forms)
      expect(result.map(&:id)).to eq %w[1 1a_deprecated 2 2a_new 3]
    end

    it "inserts questions from previous years that would start a section after new questions in the previous section" do
      original_first_section = build(:section)
      original_first_section.subsections = [build(:subsection, :with_questions, question_ids: %w[1 2], id: "1", section: original_first_section)]
      new_first_section = build(:section)
      new_first_section.subsections = [build(:subsection, :with_questions, question_ids: %w[1 2 extra], id: "1", section: new_first_section)]
      original_second_section = build(:section)
      original_second_section.subsections = [build(:subsection, :with_questions, question_ids: %w[3 4], id: "2")]
      new_second_section = build(:section)
      new_second_section.subsections = [build(:subsection, :with_questions, question_ids: %w[3_new 4], id: "2")]

      original_form = FormFactory.new(year: 2022, type: "sales").with_sections([original_first_section, original_second_section]).build
      new_form = FormFactory.new(year: 2023, type: "sales").with_sections([new_first_section, new_second_section]).build

      fake_forms = {
        "current_sales" => new_form,
        "previous_sales" => original_form,
      }
      described_class.instance.use_fake_forms!(fake_forms)
      expect(result.map(&:id)).to eq %w[1 2 extra 3 3_new 4]
    end

    it "builds the ordering based on the current form" do
      archived_section = build(:section, :with_questions, question_ids: %w[0 1 2 3])
      previous_section = build(:section, :with_questions, question_ids: %w[0 1 3 2])
      current_section = build(:section, :with_questions, question_ids: %w[3 2 0 1])
      next_section = build(:section, :with_questions, question_ids: %w[3 2 1 0])

      fake_forms = {
        "current_sales" => FormFactory.new(year: 2023, type: "sales").with_sections([current_section]).build,
        "previous_sales" => FormFactory.new(year: 2022, type: "sales").with_sections([previous_section]).build,
        "next_sales" => FormFactory.new(year: 2021, type: "sales").with_sections([next_section]).build,
        "archived_sales" => FormFactory.new(year: 2020, type: "sales").with_sections([archived_section]).build,
      }
      described_class.instance.use_fake_forms!(fake_forms)
      expect(result.map(&:id)).to eq %w[3 2 0 1]
    end
  end

  describe "#ordered_lettings_questions_for_all_years" do
    let(:result) { described_class.instance.ordered_lettings_questions_for_all_years }
    let(:now) { Time.zone.now }

    it "returns an array of questions" do
      section = build(:section, :with_questions, question_ids: %w[1 2 3])
      lettings_form = FormFactory.new(year: 2936, type: "lettings")
                              .with_sections([section])
                              .build
      described_class.instance.use_fake_forms!({ "current_lettings" => lettings_form })
      expect(result).to(satisfy { |result| result.all? { |element| element.is_a?(Form::Question) } })
    end

    it "does not return multiple questions with the same id" do
      first_section = build(:section, :with_questions, question_ids: %w[1 2 3])
      second_section = build(:section, :with_questions, question_ids: %w[2 3 4 5])
      lettings_form = FormFactory.new(year: 2936, type: "lettings")
                              .with_sections([first_section, second_section])
                              .build
      described_class.instance.use_fake_forms!({ "current_lettings" => lettings_form })
      expect(result.map(&:id)).to eq %w[1 2 3 4 5]
    end

    it "returns the questions in the same order as the form" do
      first_section = build(:section, :with_questions, question_ids: %w[1 2 3])
      second_section = build(:section, :with_questions, question_ids: %w[4 5 6])
      lettings_form = FormFactory.new(year: 2945, type: "lettings")
                              .with_sections([first_section, second_section])
                              .build
      described_class.instance.use_fake_forms!({ "current_lettings" => lettings_form })
      expect(result.map(&:id)).to eq %w[1 2 3 4 5 6]
    end

    it "inserts questions from all years in their correct positions" do
      original_section = build(:section, :with_questions, question_ids: %w[1 1a_deprecated 2 3])
      new_section = build(:section, :with_questions, question_ids: %w[1 2 2a_new 3])
      original_form = FormFactory.new(year: 2066, type: "lettings")
                                 .with_sections([original_section])
                                 .build
      new_form = FormFactory.new(year: 2485, type: "lettings")
                            .with_sections([new_section])
                            .build
      fake_forms = {
        "previous_lettings" => original_form,
        "current_lettings" => new_form,
      }
      described_class.instance.use_fake_forms!(fake_forms)
      expect(result.map(&:id)).to eq %w[1 1a_deprecated 2 2a_new 3]
    end

    it "inserts questions from previous years that would start a section after new questions in the previous section" do
      original_first_section = build(:section)
      original_first_section.subsections = [build(:subsection, :with_questions, question_ids: %w[1 2], id: "1", section: original_first_section)]
      new_first_section = build(:section)
      new_first_section.subsections = [build(:subsection, :with_questions, question_ids: %w[1 2 extra], id: "1", section: new_first_section)]
      original_second_section = build(:section)
      original_second_section.subsections = [build(:subsection, :with_questions, question_ids: %w[3 4], id: "2")]
      new_second_section = build(:section)
      new_second_section.subsections = [build(:subsection, :with_questions, question_ids: %w[3_new 4], id: "2")]

      original_form = FormFactory.new(year: 2023, type: "lettings").with_sections([original_first_section, original_second_section]).build
      new_form = FormFactory.new(year: 2024, type: "lettings").with_sections([new_first_section, new_second_section]).build

      fake_forms = {
        "current_lettings" => new_form,
        "previous_lettings" => original_form,
      }
      described_class.instance.use_fake_forms!(fake_forms)
      expect(result.map(&:id)).to eq %w[1 2 extra 3 3_new 4]
    end

    it "builds the ordering based on the current form" do
      archived_section = build(:section, :with_questions, question_ids: %w[0 1 2 3])
      previous_section = build(:section, :with_questions, question_ids: %w[0 1 3 2])
      current_section = build(:section, :with_questions, question_ids: %w[3 2 0 1])
      next_section = build(:section, :with_questions, question_ids: %w[3 2 1 0])

      fake_forms = {
        "current_lettings" => FormFactory.new(year: 2023, type: "sales").with_sections([current_section]).build,
        "previous_lettings" => FormFactory.new(year: 2022, type: "sales").with_sections([previous_section]).build,
        "next_lettings" => FormFactory.new(year: 2021, type: "sales").with_sections([next_section]).build,
        "archived_lettings" => FormFactory.new(year: 2020, type: "sales").with_sections([archived_section]).build,
      }
      described_class.instance.use_fake_forms!(fake_forms)
      expect(result.map(&:id)).to eq %w[3 2 0 1]
    end
  end
  # rubocop:enable RSpec/PredicateMatcher
end
