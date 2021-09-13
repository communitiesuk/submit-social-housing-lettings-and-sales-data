describe "questions/_numeric_question.html.erb" do
  context "when given a label, value constraints and hint text" do
    let(:label) { "Test Label" }
    let(:min) { "1" }
    let(:max) { "150" }
    let(:hint_text) { "Some text that describes the question in more detail" }
    let(:locals) { { label: label, minimum: min, maximum: max, hint_text: hint_text } }

    before(:each) do
      render partial: "numeric_question", locals: locals
    end

    it "displays a numeric entry field with a label" do
      expect(rendered).to have_selector('//input[@type="number"]')
      expect(rendered).to have_selector("//label[contains('#{label}')]")
    end

    it "validates for a given minimum input" do
      expect(rendered).to have_selector("//input[@min=#{min}]")
    end

    it "validates for a given maximum input" do
      expect(rendered).to have_selector("//input[@max=#{max}]")
    end

    it "displays hint text" do
      expect(rendered).to have_selector("//div[@class='govuk-hint']")
      expect(rendered).to have_css("#numeric_hint", text: hint_text.to_s)
    end
  end
end
