require "rails_helper"
require "rake"

RSpec.describe Csv::LettingsLogCsvService do
  subject(:task) { Rake::Task["data_import:add_variable_definitions"] }

  before do
    Rake.application.rake_require("tasks/log_variable_definitions")
    Rake::Task.define_task(:environment)
    task.reenable
    task.invoke("spec/fixtures/variable_definitions")
  end

  context "when downloading a csv" do
    let(:log) { create(:lettings_log) }
    let(:user) { create(:user, :support, email: "s.port@jeemayle.com") }
    let(:service) { described_class.new(user:, export_type:, year:) }
    let(:export_type) { "labels" }
    let(:year) { 2024 }
    let(:csv) { CSV.parse(service.prepare_csv(LettingsLog.where(id: logs.map(&:id)))) }
    let(:logs) { [log] }
    let(:definition_headers) { csv.first }
    let(:attribute_headers) { csv.second }
    let(:content_row) { csv.third }

    it "returns a string" do
      result = service.prepare_csv(LettingsLog.all)
      expect(result).to be_a String
    end

    it "returns a csv with definition headers on the first line" do
      expect(definition_headers.first).to eq "Log ID"
    end

    it "returns a csv with attribute headers on the second line" do
      expect(attribute_headers.first).to eq "id"
    end

    context "when stubbing :ordered_questions_for_year" do
      let(:form_handler_mock) { instance_double(FormHandler) }
      let(:lettings_form) do
        FormFactory.new(year: 2050, type: "lettings")
                  .with_sections([build(:section, :with_questions, question_ids:, questions:)])
                  .build
      end
      let(:question_ids) { [] }
      let(:questions) { nil }
      let(:year) { 2050 }

      before do
        allow(FormHandler).to receive(:instance).and_return(form_handler_mock)
        allow(form_handler_mock).to receive(:form_name_from_start_year)
        allow(form_handler_mock).to receive(:get_form).and_return(lettings_form)
        allow(form_handler_mock).to receive(:ordered_questions_for_year).and_return(lettings_form.questions)
        allow(form_handler_mock).to receive(:lettings_in_crossover_period?).and_return(true)
      end

      it "calls the form handler to get all questions for the specified year" do
        allow(FormHandler).to receive(:instance).and_return(form_handler_mock)
        allow(form_handler_mock).to receive(:ordered_questions_for_year).and_return([])
        service.prepare_csv(LettingsLog.all)
        expect(form_handler_mock).to have_received(:ordered_questions_for_year).with(2050, "lettings")
      end

      context "when it returns questions with particular ids" do
        let(:question_ids) { %w[prevten startdate brent rent_type] }

        it "includes log attributes related to questions to the headers" do
          expect(attribute_headers).to include(*question_ids.first(3))
        end

        it "removes some log attributes related to questions from the headers and replaces them with their derived values in the correct order" do
          expect(attribute_headers).not_to include "rent_type"
          expect(attribute_headers).to include(*%w[wrent renttype renttype_detail])
          expect(attribute_headers).not_to include("rent_type_detail")
        end
      end

      context "when it returns checkbox questions" do
        let(:questions) do
          [
            build(:question, id: "condition_effects", type: "checkbox", answer_options: { "illness_type_1" => {}, "illness_type_2" => {}, "illness_type_3" => {} }),
            build(:question, id: "letting_allocation", type: "checkbox", answer_options: { "cbl" => {}, "cap" => {}, "chr" => {}, "accessible_register" => {} }),
          ]
        end

        it "does not add the id of the checkbox question to the headers" do
          question_ids = questions.map(&:id)
          expect(attribute_headers).not_to include(*question_ids)
        end

        it "adds the related log attributes from the answer options to the headers" do
          log_attributes = questions.flat_map { |q| q.answer_options.keys }
          expect(attribute_headers).to include(*log_attributes)
        end
      end
    end

    it "adds log attributes not related to questions to the headers" do
      expect(attribute_headers.first(5)).to eq %w[id status duplicate_set_id created_by assigned_to]
    end

    it "adds attributes related to associated schemes and locations to the headers" do
      expect(attribute_headers).to include(*%w[scheme_service_name scheme_confidential SCHTYPE scheme_registered_under_care_act])
      expect(attribute_headers.last(5)).to eq %w[location_units location_type_of_unit location_mobility_type location_local_authority location_startdate]
    end

    context "when there are many logs" do
      let(:logs) { create_list(:lettings_log, log_count) }
      let(:log_count) { 30 }

      it "creates a CSV with the correct number of logs" do
        expected_row_count_with_headers = log_count + 2
        expect(csv.size).to be expected_row_count_with_headers
      end
    end

    context "when exporting with human readable labels" do
      let(:export_type) { "labels" }
      let(:log) { create(:lettings_log, :setup_completed, hhmemb: 2, details_known_2: 0, relat2: "P", age1: 35, la: "E09000003", duplicate_set_id: 12_312) }

      it "gives answer to radio questions as labels" do
        relat2_column_index = attribute_headers.index("relat2")
        relat2_value = content_row[relat2_column_index]
        expect(relat2_value).to eq "Partner"
      end

      it "gives answers to free input questions as the user input" do
        age1_column_index = attribute_headers.index("age1")
        age1_value = content_row[age1_column_index]
        expect(age1_value).to eq 35.to_s
      end

      it "exports the code for the local authority under the heading 'la'" do
        la_column_index = attribute_headers.index("la")
        la_value = content_row[la_column_index]
        expect(la_value).to eq "E09000003"
      end

      it "exports the label for the local authority under the heading 'la_label'" do
        la_label_column_index = attribute_headers.index("la_label")
        la_label_value = content_row[la_label_column_index]
        expect(la_label_value).to eq "Barnet"
      end

      it "exports the id for under the heading 'duplicate_set_id'" do
        duplicate_set_id_column_index = attribute_headers.index("duplicate_set_id")
        duplicate_set_id_value = content_row[duplicate_set_id_column_index]
        expect(duplicate_set_id_value).to eq "12312"
      end
    end

    context "when exporting as codes" do
      let(:export_type) { "codes" }
      let(:log) { create(:lettings_log, :setup_completed, hhmemb: 2, details_known_2: 0, relat2: "P", age1: 35, la: "E09000003", duplicate_set_id: 12_312) }

      it "gives answer to radio questions as labels" do
        relat2_column_index = attribute_headers.index("relat2")
        relat2_value = content_row[relat2_column_index]
        expect(relat2_value).to eq "P"
      end

      it "gives answers to free input questions as the user input" do
        age1_column_index = attribute_headers.index("age1")
        age1_value = content_row[age1_column_index]
        expect(age1_value).to eq 35.to_s
      end

      it "exports the code for the local authority under the heading 'la'" do
        la_column_index = attribute_headers.index("la")
        la_value = content_row[la_column_index]
        expect(la_value).to eq "E09000003"
      end

      it "exports the label for the local authority under the heading 'la_label'" do
        la_label_column_index = attribute_headers.index("la_label")
        la_label_value = content_row[la_label_column_index]
        expect(la_label_value).to eq "Barnet"
      end

      it "exports the duplicate log reference under the heading 'duplicate_set_id'" do
        duplicate_set_id_column_index = attribute_headers.index("duplicate_set_id")
        duplicate_set_id_value = content_row[duplicate_set_id_column_index]
        expect(duplicate_set_id_value).to eq "12312"
      end
    end

    context "when the user is not a support user" do
      let(:user) { create(:user, :data_coordinator, email: "choreographer@owtluk.com") }

      it "does not include certain attributes in the headers" do
        expect(attribute_headers).not_to include(*%w[wrent wscharge wpschrge wsupchrg wtcharge])
      end
    end

    describe "the full CSV output" do
      context "when the requested log year is 2024" do
        let(:year) { 2024 }
        let(:organisation) { create(:organisation, provider_type: "LA") }
        let(:log) do
          create(
            :lettings_log,
            :ignore_validation_errors,
            created_by: user,
            assigned_to: user,
            created_at: Time.zone.local(2024, 4, 1),
            updated_at: Time.zone.local(2024, 4, 1),
            owning_organisation: organisation,
            managing_organisation: organisation,
            needstype: 1,
            renewal: 0,
            startdate: Time.zone.local(2024, 4, 1),
            rent_type: 1,
            tenancycode: "HIJKLMN",
            propcode: "ABCDEFG",
            declaration: 1,
            address_line1: "Address line 1",
            town_or_city: "London",
            postcode_full: "NW9 5LL",
            la: "E09000003",
            is_la_inferred: false,
            address_line1_as_entered: "address line 1 as entered",
            address_line2_as_entered: "address line 2 as entered",
            town_or_city_as_entered: "town or city as entered",
            county_as_entered: "county as entered",
            postcode_full_as_entered: "AB1 2CD",
            la_as_entered: "la as entered",
            first_time_property_let_as_social_housing: 0,
            unitletas: 2,
            rsnvac: 6,
            unittype_gn: 7,
            builtype: 1,
            wchair: 1,
            beds: 3,
            voiddate: Time.zone.local(2024, 3, 30),
            majorrepairs: 1,
            mrcdate: Time.zone.local(2024, 3, 31),
            joint: 3,
            startertenancy: 1,
            tenancy: 4,
            tenancylength: 2,
            hhmemb: 4,
            age1_known: 0,
            age1: 35,
            sex1: "F",
            ethnic_group: 0,
            ethnic: 2,
            nationality_all: 36,
            ecstat1: 0,
            details_known_2: 0,
            relat2: "P",
            age2_known: 0,
            age2: 32,
            sex2: "M",
            ecstat2: 6,
            details_known_3: 1,
            details_known_4: 0,
            relat4: "R",
            age4_known: 1,
            sex4: "R",
            ecstat4: 10,
            armedforces: 1,
            leftreg: 4,
            reservist: 1,
            preg_occ: 2,
            housingneeds: 1,
            housingneeds_type: 0,
            housingneeds_a: 1,
            housingneeds_b: 0,
            housingneeds_c: 0,
            housingneeds_f: 0,
            housingneeds_g: 0,
            housingneeds_h: 0,
            housingneeds_other: 0,
            illness: 1,
            illness_type_1: 0,
            illness_type_2: 1,
            illness_type_3: 0,
            illness_type_4: 0,
            illness_type_5: 0,
            illness_type_6: 0,
            illness_type_7: 0,
            illness_type_8: 0,
            illness_type_9: 0,
            illness_type_10: 0,
            layear: 2,
            waityear: 7,
            reason: 4,
            prevten: 6,
            homeless: 1,
            ppcodenk: 1,
            ppostcode_full: "TN23 6LZ",
            previous_la_known: 1,
            prevloc: "E07000105",
            reasonpref: 1,
            rp_homeless: 0,
            rp_insan_unsat: 1,
            rp_medwel: 0,
            rp_hardship: 0,
            rp_dontknow: 0,
            cbl: 0,
            chr: 1,
            cap: 0,
            accessible_register: 0,
            referral: 2,
            net_income_known: 0,
            incref: 0,
            incfreq: 1,
            earnings: 268,
            hb: 6,
            has_benefits: 1,
            benefits: 1,
            period: 2,
            brent: 200,
            scharge: 50,
            pscharge: 40,
            supcharg: 35,
            tcharge: 325,
            hbrentshortfall: 1,
            tshortfall_known: 1,
            tshortfall: 12,
          )
        end

        context "when exporting with human readable labels" do
          let(:export_type) { "labels" }

          context "when the current user is a support user" do
            let(:user) { create(:user, :support, organisation:, email: "s.port@jeemayle.com") }

            it "exports the CSV with 2024 ordering and all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_labels_24.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end

          context "when the current user is not a support user" do
            let(:user) { create(:user, :data_provider, organisation:, email: "choreographer@owtluk.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_non_support_labels_24.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end
        end

        context "when exporting values as codes" do
          let(:export_type) { "codes" }

          context "when the current user is a support user" do
            let(:user) { create(:user, :support, organisation:, email: "s.port@jeemayle.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_codes_24.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end

          context "when the current user is not a support user" do
            let(:user) { create(:user, :data_provider, organisation:, email: "choreographer@owtluk.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_non_support_codes_24.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end
        end
      end

      context "when the requested log year is 2023" do
        let(:year) { 2023 }
        let(:organisation) { create(:organisation, provider_type: "LA") }
        let(:log) do
          create(
            :lettings_log,
            :ignore_validation_errors,
            created_by: user,
            assigned_to: user,
            created_at: Time.zone.local(2023, 11, 26),
            updated_at: Time.zone.local(2023, 11, 26),
            owning_organisation: organisation,
            managing_organisation: organisation,
            needstype: 1,
            renewal: 0,
            startdate: Time.zone.local(2023, 11, 26),
            rent_type: 1,
            tenancycode: "HIJKLMN",
            propcode: "ABCDEFG",
            declaration: 1,
            address_line1: "Address line 1",
            town_or_city: "London",
            postcode_full: "NW9 5LL",
            la: "E09000003",
            is_la_inferred: false,
            first_time_property_let_as_social_housing: 0,
            unitletas: 2,
            rsnvac: 6,
            offered: 2,
            unittype_gn: 7,
            builtype: 1,
            wchair: 1,
            beds: 3,
            voiddate: Time.zone.local(2023, 11, 24),
            majorrepairs: 1,
            mrcdate: Time.zone.local(2023, 11, 25),
            joint: 3,
            startertenancy: 1,
            tenancy: 4,
            tenancylength: 2,
            hhmemb: 4,
            age1_known: 0,
            age1: 35,
            sex1: "F",
            ethnic_group: 0,
            ethnic: 2,
            national: 13,
            ecstat1: 0,
            details_known_2: 0,
            relat2: "P",
            age2_known: 0,
            age2: 32,
            sex2: "M",
            ecstat2: 6,
            details_known_3: 1,
            details_known_4: 0,
            relat4: "R",
            age4_known: 1,
            sex4: "R",
            ecstat4: 10,
            armedforces: 1,
            leftreg: 4,
            reservist: 1,
            preg_occ: 2,
            housingneeds: 1,
            housingneeds_type: 0,
            housingneeds_a: 1,
            housingneeds_b: 0,
            housingneeds_c: 0,
            housingneeds_f: 0,
            housingneeds_g: 0,
            housingneeds_h: 0,
            housingneeds_other: 0,
            illness: 1,
            illness_type_1: 0,
            illness_type_2: 1,
            illness_type_3: 0,
            illness_type_4: 0,
            illness_type_5: 0,
            illness_type_6: 0,
            illness_type_7: 0,
            illness_type_8: 0,
            illness_type_9: 0,
            illness_type_10: 0,
            layear: 2,
            waityear: 7,
            reason: 4,
            prevten: 6,
            homeless: 1,
            ppcodenk: 1,
            ppostcode_full: "TN23 6LZ",
            previous_la_known: 1,
            prevloc: "E07000105",
            reasonpref: 1,
            rp_homeless: 0,
            rp_insan_unsat: 1,
            rp_medwel: 0,
            rp_hardship: 0,
            rp_dontknow: 0,
            cbl: 0,
            chr: 1,
            cap: 0,
            accessible_register: 0,
            referral: 2,
            net_income_known: 0,
            incref: 0,
            incfreq: 1,
            earnings: 268,
            hb: 6,
            has_benefits: 1,
            benefits: 1,
            period: 2,
            brent: 200,
            scharge: 50,
            pscharge: 40,
            supcharg: 35,
            tcharge: 325,
            hbrentshortfall: 1,
            tshortfall_known: 1,
            tshortfall: 12,
          )
        end

        context "when exporting with human readable labels" do
          let(:export_type) { "labels" }

          context "when the current user is a support user" do
            let(:user) { create(:user, :support, organisation:, email: "s.port@jeemayle.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_labels_23.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end

          context "when the current user is not a support user" do
            let(:user) { create(:user, :data_provider, organisation:, email: "choreographer@owtluk.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_non_support_labels_23.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end
        end

        context "when exporting values as codes" do
          let(:export_type) { "codes" }

          context "when the current user is a support user" do
            let(:user) { create(:user, :support, organisation:, email: "s.port@jeemayle.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_codes_23.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end

          context "when the current user is not a support user" do
            let(:user) { create(:user, :data_provider, organisation:, email: "choreographer@owtluk.com") }

            it "exports the CSV with all values correct" do
              expected_content = CSV.read("spec/fixtures/files/lettings_log_csv_export_non_support_codes_23.csv")
              values_to_delete = %w[id]
              values_to_delete.each do |attribute|
                index = attribute_headers.index(attribute)
                content_row[index] = nil
              end
              expect(csv).to eq expected_content
            end
          end
        end
      end
    end
  end
end
