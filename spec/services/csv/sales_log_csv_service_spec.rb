require "rails_helper"

RSpec.describe Csv::SalesLogCsvService do
  let(:form_handler_mock) { instance_double(FormHandler) }
  let!(:log) { create(:sales_log, :completed) }
  let(:service) { described_class.new(export_type: "labels") }
  let(:csv) { CSV.parse(service.prepare_csv(SalesLog.all)) }

  it "calls the form handler to get all questions in order when initialized" do
    allow(FormHandler).to receive(:instance).and_return(form_handler_mock)
    allow(form_handler_mock).to receive(:ordered_sales_questions_for_all_years).and_return([])
    described_class.new(export_type: "codes")
    expect(form_handler_mock).to have_received(:ordered_sales_questions_for_all_years)
  end

  it "returns a string" do
    result = service.prepare_csv(SalesLog.all)
    expect(result).to be_a String
  end

  it "returns a csv string with headers" do
    expect(csv.first.first).to eq "id"
    expect(csv.second.first).not_to be log.id.to_s
  end

  it "includes log attributes related to questions to the headers" do
    headers = csv.first
    expect(headers).to include("type", "age1", "buy1livein")
  end

  it "includes metadata attributes attributes of related entities to the headers" do
    headers = csv.first
    expect(headers).to include("id", "status", "created_at", "updated_at", "created_by_name", "is_dpo", "owning_organisation_name", "collection_start_year")
  end

  it "removes some log attributes related to questions from the headers and replaces them with their derived values in the correct order" do
    headers = csv.first
    expect(headers).not_to include "exdate"
    expect(headers).to include("exday", "exmonth", "exyear")
    index_of_exdate = FormHandler.instance.ordered_sales_questions_for_all_years.index { |q| q.id == "exdate" }
    id_of_question_before_exdate = FormHandler.instance.ordered_sales_questions_for_all_years[index_of_exdate - 1].id
    index_in_headers_of_question_before_exdate = headers.index(id_of_question_before_exdate)
    expect(headers.index("exday")).to be index_in_headers_of_question_before_exdate + 1
  end

  it "returns a csv string with the correct number of logs" do
    create_list(:sales_log, 15)
    all_logs = SalesLog.all
    log_count = all_logs.count
    expected_row_count_with_headers = log_count + 1
    expect(csv.size).to be expected_row_count_with_headers
  end

  context "when exporting with human readable labels" do
    it "gives answers to radio questions as their labels" do
      national_column_index = csv.first.index("national")
      national_value = csv.second[national_column_index]
      expect(national_value).to eq "United Kingdom"
      relat2_column_index = csv.first.index("relat2")
      relat2_value = csv.second[relat2_column_index]
      expect(relat2_value).to eq "Partner"
    end

    it "gives answers to free input questions as the user input" do
      age1_column_index = csv.first.index("age1")
      age1_value = csv.second[age1_column_index]
      expect(age1_value).to eq 30.to_s
      postcode_part1, postcode_part2 = log.postcode_full.split
      postcode_part1_column_index = csv.first.index("pcode1")
      postcode_part1_value = csv.second[postcode_part1_column_index]
      expect(postcode_part1_value).to eq postcode_part1
      postcode_part2_column_index = csv.first.index("pcode2")
      postcode_part2_value = csv.second[postcode_part2_column_index]
      expect(postcode_part2_value).to eq postcode_part2
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
  end

  context "when exporting values as codes" do
    let(:service) { described_class.new(export_type: "codes") }

    it "gives answers to radio questions as their codes" do
      national_column_index = csv.first.index("national")
      national_value = csv.second[national_column_index]
      expect(national_value).to eq 18.to_s
      relat2_column_index = csv.first.index("relat2")
      relat2_value = csv.second[relat2_column_index]
      expect(relat2_value).to eq "P"
    end

    it "gives answers to free input questions as the user input" do
      age1_column_index = csv.first.index("age1")
      age1_value = csv.second[age1_column_index]
      expect(age1_value).to eq 30.to_s
      postcode_part1, postcode_part2 = log.postcode_full.split
      postcode_part1_column_index = csv.first.index("pcode1")
      postcode_part1_value = csv.second[postcode_part1_column_index]
      expect(postcode_part1_value).to eq postcode_part1
      postcode_part2_column_index = csv.first.index("pcode2")
      postcode_part2_value = csv.second[postcode_part2_column_index]
      expect(postcode_part2_value).to eq postcode_part2
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
  end
end
