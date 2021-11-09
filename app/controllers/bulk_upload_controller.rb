class BulkUploadController < ApplicationController
  SPREADSHEET_CONTENT_TYPES = %w[
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ].freeze

  FIRST_DATA_ROW = 7

  def show
    render "case_logs/bulk_upload"
  end

  def process_bulk_upload
    if SPREADSHEET_CONTENT_TYPES.include?(params["case_log_bulk_upload"].content_type)
      xlsx = Roo::Spreadsheet.open(params["case_log_bulk_upload"].tempfile, extension: :xlsx)
      sheet = xlsx.sheet(0)
      last_row = sheet.last_row
      if last_row < FIRST_DATA_ROW
        head :no_content
      else
        data_range = FIRST_DATA_ROW..last_row
        data_range.map do |row_num|
          row = sheet.row(row_num)
          CaseLog.create!(
            tenant_code: row[7],
            startertenancy: row[8],
            age1: row[12],
            age2: row[13],
            age3: row[14],
            age4: row[15],
            age5: row[16],
            age6: row[17],
            age7: row[18],
            age8: row[19],
            sex1: row[20],
            sex2: row[21],
            sex3: row[22],
            sex4: row[23],
            sex5: row[24],
            sex6: row[25],
            sex7: row[26],
            sex8: row[27],
            relat2: row[28],
            relat3: row[29],
            relat4: row[30],
            relat5: row[31],
            relat6: row[32],
            relat7: row[33],
            relat8: row[34],
            ecstat1: row[35],
            ecstat2: row[36],
            ecstat3: row[37],
            ecstat4: row[38],
            ecstat5: row[39],
            ecstat6: row[40],
            ecstat7: row[41],
            ecstat8: row[42],
            ethnic: row[43],
            national: row[44],
            armed_forces: row[45],
            armed_forces_partner: "",
            prevten: "",
            hhmemb: "",
            homeless: "",
            reason_for_leaving_last_settled_home: "",
            underoccupation_benefitcap: "",
            leftreg: "",
            reservist: "",
            illness: "",
            preg_occ: "",
            accessibility_requirements: "",
            condition_effects: "",
            tenancy_code: "",
            startdate: "",
            tenancylength: "",
            tenancy: "",
            lettype: "",
            landlord: "",
            property_location: "",
            previous_postcode: "",
            property_relet: "",
            rsnvac: "",
            property_reference: "",
            unittype_gn: "",
            property_building_type: "",
            beds: "",
            property_void_date: "",
            property_major_repairs: "",
            property_major_repairs_date: "",
            offered: "",
            wchair: "",
            earnings: "",
            incfreq: "",
            benefits: "",
            housing_benefit: "",
            period: "",
            brent: "",
            scharge: "",
            pscharge: "",
            supcharg: "",
            tcharge: "",
            outstanding_amount: "",
            layear: "",
            lawaitlist: "",
            previous_la: "",
            property_postcode: "",
            reasonpref: "",
            reasonable_preference_reason: "",
            cbl: "",
            chr: "",
            cap: "",
            outstanding_rent_or_charges: "",
            other_reason_for_leaving_last_settled_home: "",
            housingneeds_a: "",
            housingneeds_b: "",
            housingneeds_c: "",
            housingneeds_f: "",
            housingneeds_g: "",
            housingneeds_h: "",
            accessibility_requirements_prefer_not_to_say: "",
            illness_type_1: "",
            illness_type_2: "",
            illness_type_3: "",
            illness_type_4: "",
            illness_type_8: "",
            illness_type_5: "",
            illness_type_6: "",
            illness_type_7: "",
            illness_type_9: "",
            illness_type_10: "",
            condition_effects_prefer_not_to_say: "",
            rp_homeless: "",
            rp_insan_unsat: "",
            rp_medwel: "",
            rp_hardship: "",
            rp_dontknow: "",
            tenancyother: "",
            override_net_income_validation: "",
            net_income_known: "",
            gdpr_acceptance: "",
            gdpr_declined: "",
            property_owner_organisation: "",
            property_manager_organisation: "",
            sale_or_letting: "",
            tenant_same_property_renewal: "",
            rent_type: "",
            intermediate_rent_product_name: "",
            needs_type: "",
            sale_completion_date: "",
            purchaser_code: "",
          )
        end
        redirect_to(case_logs_path)
      end
    end
  end
end
