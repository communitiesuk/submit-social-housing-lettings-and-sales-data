class TestDataController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def create_test_lettings_log
    return render_not_found unless FeatureToggle.create_test_logs_enabled?

    log = FactoryBot.create(:lettings_log, :completed, assigned_to: current_user, ppostcode_full: "SW1A 1AA")
    redirect_to lettings_log_path(log)
  end

  def create_setup_test_lettings_log
    return render_not_found unless FeatureToggle.create_test_logs_enabled?

    log = FactoryBot.create(:lettings_log, :setup_completed, assigned_to: current_user)
    redirect_to lettings_log_path(log)
  end

  def create_2024_test_lettings_bulk_upload
    return render_not_found unless FeatureToggle.create_test_logs_enabled?

    file = Tempfile.new("test_lettings_log.csv")
    header = ["Field number"] + (1..130).to_a
    file.write("#{header.join(',')}\n")
    log = FactoryBot.create(:lettings_log, :completed, assigned_to: current_user, ppostcode_full: "SW1A 1AA")
    file.write("#{([nil] + to_2024_lettings_row(log)).flatten.join(',')}\n")
    file.rewind
    send_file file.path, type: "text/csv",
                         filename: "test_lettings_log.csv",
                         disposition: "attachment",
                         after_send: lambda {
                                       file.close
                                       file.unlink
                                     }
  end

  def create_test_sales_log
    return render_not_found unless FeatureToggle.create_test_logs_enabled?

    log = FactoryBot.create(:sales_log, :completed, assigned_to: current_user)
    redirect_to sales_log_path(log)
  end

  def create_setup_test_sales_log
    return render_not_found unless FeatureToggle.create_test_logs_enabled?

    log = FactoryBot.create(:sales_log, :shared_ownership_setup_complete, assigned_to: current_user)
    redirect_to sales_log_path(log)
  end

  def create_2024_test_sales_bulk_upload
    return render_not_found unless FeatureToggle.create_test_logs_enabled?

    file = Tempfile.new("test_sales_log.csv")
    header = ["Field number"] + (1..131).to_a
    file.write("#{header.join(',')}\n")
    log = FactoryBot.create(:sales_log, :completed, assigned_to: current_user, value: 180_000, deposit: 150_000)
    file.write("#{([nil] + to_2024_sales_row(log)).flatten.join(',')}\n")
    file.rewind
    send_file file.path, type: "text/csv",
                         filename: "test_sales_log.csv",
                         disposition: "attachment",
                         after_send: lambda {
                                       file.close
                                       file.unlink
                                     }
  end

private

  def to_2024_lettings_row(log)
    [
      "ORG#{log.owning_organisation_id}", # 1
      "ORG#{log.managing_organisation_id}",
      log.assigned_to&.email,
      log.needstype,
      log.scheme&.id ? "S#{log.scheme&.id}" : "",
      log.location&.id,
      renewal(log),
      log.startdate&.day,
      log.startdate&.month,
      log.startdate&.strftime("%y"), # 10

      rent_type(log),
      log.irproduct_other,
      log.tenancycode,
      log.propcode,
      log.declaration,
      log.uprn,
      log.address_line1&.tr(",", " "),
      log.address_line2&.tr(",", " "),
      log.town_or_city,
      log.county, # 20

      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,
      log.la,
      log.rsnvac,
      log.unitletas,
      log.unittype_gn,
      log.builtype,
      log.wchair,
      log.beds,
      log.voiddate&.day, # 30

      log.voiddate&.month,
      log.voiddate&.strftime("%y"),
      log.mrcdate&.day,
      log.mrcdate&.month,
      log.mrcdate&.strftime("%y"),
      log.joint,
      log.startertenancy,
      log.tenancy,
      log.tenancyother,
      log.tenancylength, # 40

      log.sheltered,
      log.age1,
      log.sex1,
      log.ethnic,
      log.nationality_all_group,
      log.ecstat1,
      log.relat2,
      log.age2,
      log.sex2,
      log.ecstat2, # 50

      log.relat3,
      log.age3,
      log.sex3,
      log.ecstat3,
      log.relat4,
      log.age4,
      log.sex4,
      log.ecstat4,
      log.relat5,
      log.age5, # 60

      log.sex5,
      log.ecstat5,
      log.relat6,
      log.age6,
      log.sex6,
      log.ecstat6,
      log.relat7,
      log.age7,
      log.sex7,
      log.ecstat7, # 70

      log.relat8,
      log.age8,
      log.sex8,
      log.ecstat8,
      log.armedforces,
      log.leftreg,
      log.reservist,
      log.preg_occ,
      log.housingneeds_a,
      log.housingneeds_b, # 80

      log.housingneeds_c,
      log.housingneeds_f,
      log.housingneeds_g,
      log.housingneeds_h,
      log.illness,
      log.illness_type_1,
      log.illness_type_2,
      log.illness_type_3,
      log.illness_type_4,
      log.illness_type_5, # 90

      log.illness_type_6,
      log.illness_type_7,
      log.illness_type_8,
      log.illness_type_9,
      log.illness_type_10,
      log.layear,
      log.waityear,
      log.reason,
      log.reasonother,
      log.prevten, # 100

      homeless(log),
      previous_postcode_known(log),
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      log.prevloc,
      log.reasonpref,
      log.rp_homeless,
      log.rp_insan_unsat,
      log.rp_medwel,
      log.rp_hardship, # 110

      log.rp_dontknow,
      cbl(log),
      chr(log),
      cap(log),
      accessible_register(log),
      log.referral,
      net_income_known(log),
      log.incfreq,
      log.earnings,
      log.hb, # 120

      log.benefits,
      log.household_charge,
      log.period,
      log.chcharge,
      log.brent,
      log.scharge,
      log.pscharge,
      log.supcharg,
      log.hbrentshortfall,
      log.tshortfall, # 130
    ]
  end

  def renewal(log)
    checkbox_value(log.renewal)
  end

  def checkbox_value(field)
    case field
    when 0
      2
    when 1
      1
    end
  end

  def rent_type(log)
    LettingsLog::RENTTYPE_DETAIL_MAPPING[log.rent_type]
  end

  def previous_postcode_known(log)
    checkbox_value(log.ppcodenk)
  end

  def homeless(log)
    case log.homeless
    when 1
      1
    when 11
      12
    end
  end

  def cbl(log)
    checkbox_value(log.cbl)
  end

  def chr(log)
    checkbox_value(log.chr)
  end

  def cap(log)
    checkbox_value(log.cap)
  end

  def accessible_register(log)
    checkbox_value(log.accessible_register)
  end

  def net_income_known(log)
    case log.net_income_known
    when 0
      1
    when 1
      2
    when 2
      4
    end
  end

  def to_2024_sales_row(log)
    [
      "ORG#{log.owning_organisation_id}", # 1
      "ORG#{log.managing_organisation_id}",
      log.assigned_to&.email,
      log.saledate&.day,
      log.saledate&.month,
      log.saledate&.strftime("%y"),
      log.purchid,
      log.ownershipsch,
      log.ownershipsch == 1 ? log.type : "", # field_9: "What is the type of shared ownership sale?",
      log.ownershipsch == 2 ? log.type : "", # field_10: "What is the type of discounted ownership sale?",

      log.ownershipsch == 3 ? log.type : "", # field_11: "What is the type of outright sale?",
      log.othtype,
      log.companybuy,
      log.buylivein,
      log.jointpur,
      log.jointmore,
      log.noint,
      log.privacynotice,
      log.beds,
      log.proptype, # 20

      log.builtype,
      log.uprn,
      log.address_line1&.tr(",", " "),
      log.address_line2&.tr(",", " "),
      log.town_or_city,
      log.county,
      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,
      log.la,
      log.wchair, # 30

      log.age1,
      log.sex1,
      log.ethnic,
      log.nationality_all_group,
      log.ecstat1,
      log.buy1livein,
      log.relat2,
      log.age2,
      log.sex2,
      log.ethnic_group2, # 40

      log.nationality_all_buyer2_group,
      log.ecstat2,
      log.buy2livein,
      log.hholdcount,
      log.relat3,
      log.age3,
      log.sex3,
      log.ecstat3,
      log.relat4,
      log.age4, # 50

      log.sex4,
      log.ecstat4,
      log.relat5,
      log.age5,
      log.sex5,
      log.ecstat5,
      log.relat6,
      log.age6,
      log.sex6,
      log.ecstat6, # 60

      log.prevten,
      log.ppcodenk,
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      log.prevloc,
      log.pregyrha,
      log.pregother,
      log.pregla,
      log.pregghb,
      log.buy2living, # 70

      log.prevtenbuy2,
      log.hhregres,
      log.hhregresstill,
      log.armedforcesspouse,
      log.disabled,
      log.wheel,
      log.income1,
      log.inc1mort,
      log.income2,
      log.inc2mort, # 80

      log.hb,
      log.savings.present? || "R",
      log.prevown,
      log.prevshared,
      log.proplen,
      log.staircase,
      log.stairbought,
      log.stairowned,
      log.staircasesale,
      log.resale, # 90

      log.exdate&.day,
      log.exdate&.month,
      log.exdate&.strftime("%y"),
      log.hodate&.day,
      log.hodate&.month, # 60
      log.hodate&.strftime("%y"),
      log.lanomagr,
      log.frombeds,
      log.fromprop,
      log.socprevten, # 100

      log.value,
      log.equity,
      log.mortgageused,
      log.mortgage,
      log.mortgagelender,
      log.mortgagelenderother,
      log.mortlen,
      log.extrabor,
      log.deposit,
      log.cashdis, # 110

      log.mrent,
      log.mscharge,
      log.proplen,
      log.value,
      log.grant,
      log.discount || 0,
      log.mortgageused,
      log.mortgage,
      log.mortgagelender,
      log.mortgagelenderother, # 120

      log.mortlen,
      log.extrabor,
      log.deposit,
      log.mscharge,
      log.value,
      log.mortgageused,
      log.mortgage,
      log.mortlen,
      log.extrabor,
      log.deposit, # 130
      log.mscharge,
    ]
  end
end
