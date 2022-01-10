require "rails_helper"

RSpec.describe FormHandler do
  let(:test_form_name) { "2021_2022" }
  describe "Get all forms" do
    it "should be able to load all the forms" do
      form_handler = FormHandler.instance
      all_forms = form_handler.forms
      expect(all_forms.count).to be >= 1
      expect(all_forms[test_form_name]).to be_a(Form)
    end
  end

  describe "Get specific form" do
    it "should be able to load a specific form" do
      form_handler = FormHandler.instance
      form = form_handler.get_form(test_form_name)
      expect(form).to be_a(Form)
      expect(form.pages.count).to eq(31)
    end
  end

  it "should only load the form once at boot time" do
    form_handler = FormHandler.instance
    expect(Form).not_to receive(:new).with(:any, test_form_name)
    expect(form_handler.get_form(test_form_name)).to be_a(Form)
  end
end
