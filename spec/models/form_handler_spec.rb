require "rails_helper"

RSpec.describe FormHandler do
  let(:form_handler) { described_class.instance }
  let(:now) { Time.utc(2022, 9, 20) }

  around do |example|
    Timecop.freeze(now) do
      Singleton.__init__(described_class)
      example.run
    end
    Singleton.__init__(described_class)
  end

  context "when accessing a form in a different year" do
    let(:now) { Time.utc(2021, 8, 3) }

    it "is able to load a current lettings form" do
      form = form_handler.get_form("current_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(46)
    end

    it "is able to load a next lettings form" do
      form = form_handler.get_form("next_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(13)
    end
  end

  describe "Get all forms" do
    it "is able to load all the forms" do
      all_forms = form_handler.forms
      expect(all_forms.count).to be >= 1
      expect(all_forms["current_sales"]).to be_a(Form)
    end
  end

  describe "Get specific form" do
    it "is able to load a current lettings form" do
      form = form_handler.get_form("current_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(13)
    end

    it "is able to load a previous lettings form" do
      form = form_handler.get_form("previous_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(46)
    end

    it "is able to load a current sales form" do
      form = form_handler.get_form("current_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(186)
      expect(form.name).to eq("2022_2023_sales")
    end

    it "is able to load a previous sales form" do
      form = form_handler.get_form("previous_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(186)
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
      let(:now) { Time.utc(2022, 8, 3) }

      it "returns the same year as the current start year" do
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

      it "returns the correct current sales form name" do
        expect(form_handler.form_name_from_start_year(2022, "sales")).to eq("current_sales")
      end

      it "returns the correct previous sales form name" do
        expect(form_handler.form_name_from_start_year(2021, "sales")).to eq("previous_sales")
      end

      it "returns the correct next sales form name" do
        expect(form_handler.form_name_from_start_year(2023, "sales")).to eq("next_sales")
      end

      it "returns the correct current start date" do
        expect(form_handler.current_collection_start_date).to eq(Time.zone.local(2022, 4, 1))
      end
    end

    context "with the date before 1st of April" do
      let(:now) { Time.utc(2022, 2, 3) }

      it "returns the previous year as the current start year" do
        expect(form_handler.current_collection_start_year).to eq(2021)
      end

      it "returns the correct current lettings form name" do
        expect(form_handler.form_name_from_start_year(2021, "lettings")).to eq("current_lettings")
      end

      it "returns the correct previous lettings form name" do
        expect(form_handler.form_name_from_start_year(2020, "lettings")).to eq("previous_lettings")
      end

      it "returns the correct next lettings form name" do
        expect(form_handler.form_name_from_start_year(2022, "lettings")).to eq("next_lettings")
      end

      it "returns the correct current sales form name" do
        expect(form_handler.form_name_from_start_year(2021, "sales")).to eq("current_sales")
      end

      it "returns the correct previous sales form name" do
        expect(form_handler.form_name_from_start_year(2020, "sales")).to eq("previous_sales")
      end

      it "returns the correct next sales form name" do
        expect(form_handler.form_name_from_start_year(2022, "sales")).to eq("next_sales")
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
        expect(form_handler.in_crossover_period?(now: Date.new(2022, 1, 1))).to be_falsey
      end
    end

    context "when in overlapping period" do
      it "returns true" do
        expect(form_handler.in_crossover_period?(now: Date.new(2022, 6, 1))).to be_truthy
      end
    end
  end
  # rubocop:enable RSpec/PredicateMatcher
end
