require "rails_helper"

RSpec.describe FormHandler do
  let(:test_form_name) { "2021_2022" }

  describe "Get all forms" do
    it "is able to load all the forms" do
      form_handler = described_class.instance
      all_forms = form_handler.forms
      expect(all_forms.count).to be >= 1
      expect(all_forms[test_form_name]).to be_a(Form)
    end
  end

  describe "Get specific form" do
    it "is able to load a specific form" do
      form_handler = described_class.instance
      form = form_handler.get_form(test_form_name)
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(40)
    end
  end

  describe "Current form" do
    it "returns the latest form by date" do
      form_handler = described_class.instance
      form = form_handler.current_form
      expect(form).to be_a(Form)
      expect(form.start_date.year).to eq(2022)
    end
  end

  it "loads the form once at boot time" do
    form_handler = described_class.instance
    expect(Form).not_to receive(:new).with(:any, test_form_name)
    expect(form_handler.get_form(test_form_name)).to be_a(Form)
  end
end
