require "rails_helper"

RSpec.describe Csv::SchemeCsvService do
  let(:organisation) { create(:organisation, name: "MHCLG") }
  let(:fixed_time) { Time.zone.local(2023, 6, 26) }
  let(:scheme) { create(:scheme, :export, owning_organisation: organisation, service_name: "Test name") }
  let(:location) { create(:location, :export, scheme:) }
  let(:service) { described_class.new(download_type:) }
  let(:download_type) { "combined" }
  let(:csv) { CSV.parse(service.prepare_csv(Scheme.where(id: schemes.map(&:id)))) }
  let(:schemes) { [scheme] }
  let(:headers) { csv.first }

  before do
    Timecop.freeze(fixed_time)
    Singleton.__init__(FormHandler)
    create(:scheme_deactivation_period, scheme:, deactivation_date: scheme.created_at + 1.year, reactivation_date: scheme.created_at + 2.years)
    create(:location_deactivation_period, location:, deactivation_date: location.created_at + 6.months)
  end

  after do
    Timecop.return
    Singleton.__init__(FormHandler)
  end

  it "returns a string" do
    result = service.prepare_csv(Scheme.all)
    expect(result).to be_a String
  end

  it "returns a csv with headers" do
    expect(csv.first.first).to eq "scheme_code"
  end

  it "returns the correctly formatted scheme code" do
    expect(csv.second.first.first).to eq "S"
  end

  context "when download type is schemes" do
    let(:download_type) { "schemes" }
    let(:scheme_attributes) { %w[scheme_code scheme_service_name scheme_status scheme_confidential scheme_type scheme_registered_under_care_act scheme_owning_organisation_name scheme_support_services_provided_by scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at scheme_active_dates] }

    it "has the correct headers" do
      expect(headers).to eq(scheme_attributes)
    end

    it "exports the CSV with all values correct" do
      expected_content = CSV.read("spec/fixtures/files/schemes_csv_export.csv")
      values_to_delete = %w[scheme_code]
      values_to_delete.each do |attribute|
        index = csv.first.index(attribute)
        csv.second[index] = nil
      end
      expect(csv).to eq expected_content
    end

    context "when there are many schemes and locations" do
      let(:schemes) { create_list(:scheme, scheme_count) }
      let(:scheme_count) { 5 }
      let(:locations_per_scheme) { 2 }

      before do
        schemes.each do |scheme|
          create_list(:location, locations_per_scheme, scheme:)
        end
      end

      it "creates a CSV with the correct number of schemes" do
        expected_row_count_with_headers = scheme_count + 1
        expect(csv.size).to be expected_row_count_with_headers
      end
    end
  end

  context "when download type is locations" do
    let(:download_type) { "locations" }
    let(:location_attributes) { %w[scheme_code location_code location_postcode location_name location_status location_local_authority location_units location_type_of_unit location_mobility_type location_active_dates] }

    it "has the correct headers" do
      expect(headers).to eq(location_attributes)
    end

    it "exports the CSV with all values correct" do
      expected_content = CSV.read("spec/fixtures/files/locations_csv_export.csv")
      values_to_delete = %w[scheme_code location_code]
      values_to_delete.each do |attribute|
        index = csv.first.index(attribute)
        csv.second[index] = nil
      end
      expect(csv).to eq expected_content
    end

    context "when there are many schemes and locations" do
      let(:schemes) { create_list(:scheme, scheme_count) }
      let(:scheme_count) { 5 }
      let(:locations_per_scheme) { 2 }

      before do
        schemes.each do |scheme|
          create_list(:location, locations_per_scheme, scheme:)
        end
      end

      it "creates a CSV with the correct number of locations" do
        expected_row_count_with_headers = locations_per_scheme * scheme_count + 1
        expect(csv.size).to be expected_row_count_with_headers
      end
    end
  end

  context "when download type is combined" do
    let(:combined_attributes) { %w[scheme_code scheme_service_name scheme_status scheme_confidential scheme_type scheme_registered_under_care_act scheme_owning_organisation_name scheme_support_services_provided_by scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at scheme_active_dates location_code location_postcode location_name location_status location_local_authority location_units location_type_of_unit location_mobility_type location_active_dates] }

    before do
      scheme
    end

    it "has the correct headers" do
      expect(headers).to eq(combined_attributes)
    end

    it "exports the CSV with all values correct" do
      expected_content = CSV.read("spec/fixtures/files/schemes_and_locations_csv_export.csv")
      values_to_delete = %w[scheme_code location_code]
      values_to_delete.each do |attribute|
        index = csv.first.index(attribute)
        csv.second[index] = nil
      end
      expect(csv).to eq expected_content
    end

    context "when there are many schemes and locations" do
      let(:schemes) { create_list(:scheme, scheme_count) }
      let(:scheme_count) { 5 }
      let(:locations_per_scheme) { 2 }

      before do
        schemes.each do |scheme|
          create_list(:location, locations_per_scheme, scheme:)
        end
      end

      it "creates a CSV with the correct number of locations" do
        expected_row_count_with_headers = locations_per_scheme * scheme_count + 1
        expect(csv.size).to be expected_row_count_with_headers
      end
    end
  end
end
