require "rails_helper"

RSpec.describe Form::Sales::Pages::RetirementValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 1 }

  let(:page_id) { "person_1_retirement_value_check" }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "with joint purchase" do
    context "with person 1" do
      let(:person_index) { 1 }
      let(:page_id) { "person_1_retirement_value_check_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_1_retirement_value_check_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_1_retired_under_soft_min_age?" => true, "jointpur" => 1 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_1",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_1",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_1",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 2" do
      let(:person_index) { 2 }
      let(:page_id) { "person_2_retirement_value_check_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_retirement_value_check_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_2_retired_under_soft_min_age?" => true, "jointpur" => 1 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_2",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_2",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_2",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 3" do
      let(:person_index) { 3 }
      let(:page_id) { "person_3_retirement_value_check_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_retirement_value_check_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_3_retired_under_soft_min_age?" => true, "jointpur" => 1 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_3",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_3",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_3",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 4" do
      let(:person_index) { 4 }
      let(:page_id) { "person_4_retirement_value_check_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_retirement_value_check_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_4_retired_under_soft_min_age?" => true, "jointpur" => 1 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_4",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_4",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_4",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 5" do
      let(:person_index) { 5 }
      let(:page_id) { "person_5_retirement_value_check_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_5_retirement_value_check_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_5_retired_under_soft_min_age?" => true, "jointpur" => 1 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_5",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_5",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_5",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 6" do
      let(:person_index) { 6 }
      let(:page_id) { "person_6_retirement_value_check_joint_purchase" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_6_retirement_value_check_joint_purchase")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_6_retired_under_soft_min_age?" => true, "jointpur" => 1 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_6",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_6",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_6",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end
  end

  context "without joint purchase" do
    context "with person 1" do
      let(:person_index) { 1 }
      let(:page_id) { "person_1_retirement_value_check" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_1_retirement_value_check")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_1_retired_under_soft_min_age?" => true, "jointpur" => 2 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_1",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_1",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_1",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 2" do
      let(:person_index) { 2 }
      let(:page_id) { "person_2_retirement_value_check" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_2_retirement_value_check")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_2_retired_under_soft_min_age?" => true, "jointpur" => 2 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_2",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_2",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_2",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 3" do
      let(:person_index) { 2 }
      let(:page_id) { "person_3_retirement_value_check" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_3_retirement_value_check")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_2_retired_under_soft_min_age?" => true, "jointpur" => 2 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_2",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_2",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_2",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 4" do
      let(:person_index) { 3 }
      let(:page_id) { "person_4_retirement_value_check" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_4_retirement_value_check")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_3_retired_under_soft_min_age?" => true, "jointpur" => 2 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_3",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_3",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_3",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 5" do
      let(:person_index) { 4 }
      let(:page_id) { "person_5_retirement_value_check" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_5_retirement_value_check")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_4_retired_under_soft_min_age?" => true, "jointpur" => 2 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_4",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_4",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_4",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end

    context "with person 6" do
      let(:person_index) { 5 }
      let(:page_id) { "person_6_retirement_value_check" }

      it "has correct questions" do
        expect(page.questions.map(&:id)).to eq(%w[retirement_value_check])
      end

      it "has the correct id" do
        expect(page.id).to eq("person_6_retirement_value_check")
      end

      it "has correct depends_on" do
        expect(page.depends_on).to eq([{ "person_5_retired_under_soft_min_age?" => true, "jointpur" => 2 }])
      end

      it "has correct title_text" do
        expect(page.title_text).to eq({
          "translation" => "soft_validations.retirement.min.title",
          "arguments" => [
            {
              "key" => "retirement_age_for_person_5",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end

      it "has correct informative_text" do
        expect(page.informative_text).to eq({
          "translation" => "soft_validations.retirement.min.hint_text",
          "arguments" => [
            {
              "key" => "plural_gender_for_person_5",
              "label" => false,
              "i18n_template" => "gender",
            },
            {
              "key" => "retirement_age_for_person_5",
              "label" => false,
              "i18n_template" => "age",
            },
          ],
        })
      end
    end
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end
end
