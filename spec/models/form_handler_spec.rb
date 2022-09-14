require "rails_helper"

RSpec.describe FormHandler do
  let(:test_form_name) { "2021_2022" }
  let(:form_handler) { described_class.instance }

  before { Singleton.__init__(described_class) }

  context "when accessing a form in a different year" do
    before do
      Timecop.freeze(Time.utc(2021, 8, 3))
    end

    after do
      Timecop.unfreeze
    end

    it "is able to load a current lettings form" do
      form = form_handler.get_form("current_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(45)
    end

    it "is able to load a next lettings form" do
      form = form_handler.get_form("next_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(12)
    end
  end

  describe "Get all forms" do
    it "is able to load all the forms" do
      all_forms = form_handler.forms
      expect(all_forms.count).to be >= 1
      expect(all_forms[test_form_name]["form"]).to be_a(Form)
    end
  end

  describe "Get specific form" do
    it "is able to load a specific form" do
      form = form_handler.get_form(test_form_name)
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(45)
    end

    it "is able to load a current lettings form" do
      form = form_handler.get_form("current_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(12)
    end

    it "is able to load a previous lettings form" do
      form = form_handler.get_form("previous_lettings")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(45)
    end

    it "is able to load a current sales form" do
      form = form_handler.get_form("current_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(1)
      expect(form.name).to eq("2022_2023_sales")
    end

    it "is able to load a previous sales form" do
      form = form_handler.get_form("previous_sales")
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(1)
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

  it "loads the form once at boot time" do
    form_handler = described_class.instance
    expect(Form).not_to receive(:new).with(:any, test_form_name)
    expect(form_handler.get_form(test_form_name)).to be_a(Form)
  end

  it "can get a saleslog form" do
    expect(form_handler.get_form("2022_2023_sales")).to be_a(Form)
  end

  it "keeps track of form type and start year" do
    form = form_handler.forms["current_lettings"]
    expect(form["type"]).to eq("lettings")
    expect(form["start_year"]).to eq(2022)
  end
end
