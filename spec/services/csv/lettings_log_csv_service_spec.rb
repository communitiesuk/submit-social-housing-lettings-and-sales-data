require "rails_helper"

RSpec.describe Csv::LettingsLogCsvService do
  let(:form_handler_mock) { instance_double(FormHandler) }
  let(:organisation) { create(:organisation) }
  let(:fixed_time) { Time.zone.local(2023, 6, 26) }
  let(:log) do
    create(
      :lettings_log,
      :completed,
      startdate: fixed_time,
      created_at: fixed_time,
      updated_at: fixed_time,
      mrcdate: fixed_time - 1.day,
      voiddate: fixed_time - 2.days,
      propcode: "ABCDEFG",
      tenancycode: "HIJKLMN",
      postcode_full: "NW9 5LL",
      ppostcode_full: "TN23 6LZ",
      created_by: user,
      managing_organisation: organisation,
    )
  end
  let(:user) { create(:user, :support, email: "s.port@jeemayle.com") }
  let(:service) { described_class.new(user:, export_type:) }
  let(:export_type) { "labels" }
  let(:csv) { CSV.parse(service.prepare_csv(LettingsLog.where(id: logs.map(&:id)))) }
  let(:logs) { [log] }
  let(:headers) { csv.first }

  it "calls the form handler to get all questions in order when initialized" do
    allow(FormHandler).to receive(:instance).and_return(form_handler_mock)
    allow(form_handler_mock).to receive(:ordered_lettings_questions_for_all_years).and_return([])
    service
    expect(form_handler_mock).to have_received(:ordered_lettings_questions_for_all_years)
  end

  it "returns a string" do
    result = service.prepare_csv(LettingsLog.all)
    expect(result).to be_a String
  end

  it "returns a csv with headers" do
    expect(csv.first.first).to eq "id"
  end

  context "when stubbing :ordered_lettings_questions_for_all_years" do
    let(:lettings_form) do
      FormFactory.new(year: 2050, type: "lettings")
                 .with_sections([build(:section, :with_questions, question_ids:, questions:)])
                 .build
    end
    let(:question_ids) { nil }
    let(:questions) { nil }

    before do
      allow(FormHandler).to receive(:instance).and_return(form_handler_mock)
      allow(form_handler_mock).to receive(:form_name_from_start_year)
      allow(form_handler_mock).to receive(:get_form).and_return(lettings_form)
      allow(form_handler_mock).to receive(:ordered_lettings_questions_for_all_years).and_return(lettings_form.questions)
      allow(form_handler_mock).to receive(:lettings_in_crossover_period?).and_return false
    end

    context "when it returns questions with particular ids" do
      let(:question_ids) { %w[prevten startdate brent rent_type] }

      it "includes log attributes related to questions to the headers" do
        expect(headers).to include(*question_ids.first(3))
      end

      it "removes some log attributes related to questions from the headers and replaces them with their derived values in the correct order" do
        expect(headers).not_to include "rent_type"
        expect(headers).to include(*%w[wrent renttype rent_type_detail])
      end
    end

    context "when it returns checkbox questions" do
      let(:questions) do
        [
          build(:question, id: "condition_effects", type: "checkbox", answer_options: { "illness_type_1" => {}, "illness_type_2" => {}, "illness_type_3" => {} }),
          build(:question, id: "letting_allocation", type: "checkbox", answer_options: { "cbl" => {}, "cap" => {}, "chr" => {} }),
        ]
      end

      it "does not add the id of the checkbox question to the headers" do
        question_ids = questions.map(&:id)
        expect(headers).not_to include(*question_ids)
      end

      it "adds the related log attributes from the answer options to the headers" do
        log_attributes = questions.flat_map { |q| q.answer_options.keys }
        expect(headers).to include(*log_attributes)
      end
    end
  end

  it "adds log attributes not related to questions to the headers" do
    expect(headers.first(5)).to eq %w[id status created_by is_dpo created_at]
  end

  it "adds attributes related to associated schemes and locations to the headers" do
    expect(headers).to include(*%w[scheme_service_name scheme_sensitive SCHTYPE scheme_registered_under_care_act])
    expect(headers.last(5)).to eq %w[location_units location_type_of_unit location_mobility_type location_admin_district location_startdate]
  end

  context "when there are many logs" do
    let(:logs) { create_list(:lettings_log, log_count) }
    let(:log_count) { 30 }

    it "creates a CSV with the correct number of logs" do
      expected_row_count_with_headers = log_count + 1
      expect(csv.size).to be expected_row_count_with_headers
    end
  end

  context "when exporting with human readable labels" do
    let(:export_type) { "labels" }

    it "gives answer to radio questions as labels" do
      relat2_column_index = csv.first.index("relat2")
      relat2_value = csv.second[relat2_column_index]
      expect(relat2_value).to eq "Partner"
    end

    it "gives answers to free input questions as the user input" do
      age1_column_index = csv.first.index("age1")
      age1_value = csv.second[age1_column_index]
      expect(age1_value).to eq 35.to_s
    end

    it "exports the code for the local authority under the heading 'la'" do
      la_column_index = csv.first.index("la")
      la_value = csv.second[la_column_index]
      expect(la_value).to eq "E09000003"
    end

    it "exports the label for the local authority under the heading 'la_label'" do
      la_label_column_index = csv.first.index("la_label")
      la_label_value = csv.second[la_label_column_index]
      expect(la_label_value).to eq "Barnet"
    end

    it "exports the CSV with all values correct" do
      expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_labels.csv")
      values_to_delete = %w[id vacdays]
      values_to_delete.each do |attribute|
        index = csv.first.index(attribute)
        csv.second[index] = nil
      end
      expect(csv).to eq expected_content
    end
  end

  context "when exporting as codes" do
    let(:export_type) { "codes" }

    it "gives answer to radio questions as labels" do
      relat2_column_index = csv.first.index("relat2")
      relat2_value = csv.second[relat2_column_index]
      expect(relat2_value).to eq "P"
    end

    it "gives answers to free input questions as the user input" do
      age1_column_index = csv.first.index("age1")
      age1_value = csv.second[age1_column_index]
      expect(age1_value).to eq 35.to_s
    end

    it "exports the code for the local authority under the heading 'la'" do
      la_column_index = csv.first.index("la")
      la_value = csv.second[la_column_index]
      expect(la_value).to eq "E09000003"
    end

    it "exports the label for the local authority under the heading 'la_label'" do
      la_label_column_index = csv.first.index("la_label")
      la_label_value = csv.second[la_label_column_index]
      expect(la_label_value).to eq "Barnet"
    end

    it "exports the CSV with all values correct" do
      expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_codes.csv")
      values_to_delete = %w[id vacdays]
      values_to_delete.each do |attribute|
        index = csv.first.index(attribute)
        csv.second[index] = nil
      end
      expect(csv).to eq expected_content
    end
  end

  context "when the user is not a support user" do
    let(:user) { create(:user, email: "choreographer@owtluk.com") }

    it "does not include certain attributes in the headers" do
      expect(headers).not_to include(*%w[rent_type_detail wrent wscharge wpschrge wsupchrg wtcharge])
    end

    context "and exporting with labels" do
      let(:export_type) { "labels" }

      it "exports the CSV with all values correct" do
        expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_non_support_labels.csv")
        values_to_delete = %w[id]
        values_to_delete.each do |attribute|
          index = csv.first.index(attribute)
          csv.second[index] = nil
        end
        expect(csv).to eq expected_content
      end
    end

    context "and exporting values as codes" do
      let(:export_type) { "codes" }

      it "exports the CSV with all values correct" do
        expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_non_support_codes.csv")
        values_to_delete = %w[id]
        values_to_delete.each do |attribute|
          index = csv.first.index(attribute)
          csv.second[index] = nil
        end
        expect(csv).to eq expected_content
      end
    end
  end
end
