require "rails_helper"

RSpec.describe Form::Sales::Pages::PersonStudentNotChildValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:person_index) { 2 }

  let(:page_id) { "person_2_student_not_child_value_check" }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "forms.2024.sales.soft_validations.student_not_child_value_check.title_text",
    })
  end

  it "has correct informative_text" do
    expect(page.informative_text).to eq({})
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[student_not_child_value_check])
  end

  it "has correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[relat2 ecstat2 age2])
  end

  context "with person 2" do
    let(:person_index) { 2 }
    let(:page_id) { "person_2_student_not_child_value_check" }

    it "has the correct id" do
      expect(page.id).to eq(page_id)
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_2_student_not_child?" => true }])
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat2 ecstat2 age2])
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }
    let(:page_id) { "person_3_student_not_child_value_check" }

    it "has the correct id" do
      expect(page.id).to eq(page_id)
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_3_student_not_child?" => true }])
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat3 ecstat3 age3])
    end
  end

  context "with person 4" do
    let(:person_index) { 4 }
    let(:page_id) { "person_4_student_not_child_value_check" }

    it "has the correct id" do
      expect(page.id).to eq(page_id)
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_4_student_not_child?" => true }])
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat4 ecstat4 age4])
    end
  end

  context "with person 5" do
    let(:person_index) { 5 }
    let(:page_id) { "person_5_student_not_child_value_check" }

    it "has the correct id" do
      expect(page.id).to eq(page_id)
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_5_student_not_child?" => true }])
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat5 ecstat5 age5])
    end
  end

  context "with person 6" do
    let(:person_index) { 6 }
    let(:page_id) { "person_6_student_not_child_value_check" }

    it "has the correct id" do
      expect(page.id).to eq(page_id)
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_6_student_not_child?" => true }])
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat6 ecstat6 age6])
    end
  end
end
