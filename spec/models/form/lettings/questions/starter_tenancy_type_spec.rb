require "rails_helper"

RSpec.describe Form::Lettings::Questions::StarterTenancyType, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, id: "starter_tenancy_type") }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has the correct answer options" do
    expect(question.answer_options).to eq(
      {
        "4" => {
          "value" => "Assured Shorthold Tenancy (AST) – Fixed term",
          "hint" => "These are mostly provided by housing associations. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
        },
        "6" => {
          "value" => "Secure – fixed term",
          "hint" => "These are mostly provided by local authorities. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
        },
        "2" => {
          "value" => "Assured – lifetime",
        },
        "7" => {
          "value" => "Secure – lifetime",
        },
        "8" => {
          "value" => "Periodic",
          "hint" => "These are rolling tenancies with no fixed end date. They may have an initial fixed term and then become rolling.",
        },
        "5" => {
          "value" => "Licence agreement",
          "hint" => "These are mostly used for Supported Housing and work on a rolling basis.",
        },
        "3" => {
          "value" => "Other",
        },
      },
    )
  end

  it "has the correct question number" do
    expect(question.question_number).to eq(27)
  end

  context "with 2025/26 form" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1)) }

    it "has the correct question number" do
      expect(question.question_number).to eq(28)
    end
  end
end
