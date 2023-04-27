class BulkUpload::SalesLogToCsv
  attr_reader :log, :line_ending, :col_offset, :overrides

  def initialize(log:, line_ending: "\n", col_offset: 1, overrides: {})
    @log = log
    @line_ending = line_ending
    @col_offset = col_offset
    @overrides = overrides
  end

  def row_prefix
    [nil] * col_offset
  end

  def to_2022_csv_row
    (row_prefix + to_2022_row).flatten.join(",") + line_ending
  end

  def default_2022_field_numbers
    (1..134).to_a
  end

  def default_2022_field_numbers_row(seed: nil)
    if seed
      ["Bulk upload field number"] + default_2022_field_numbers.shuffle(random: Random.new(seed))
    else
      ["Bulk upload field number"] + default_2022_field_numbers
    end.flatten.join(",") + line_ending
  end

  def to_2022_row
    [
      log.purchid, # 1
      log.saledate&.day,
      log.saledate&.month,
      log.saledate&.strftime("%y"),
      nil,
      log.noint,
      log.age1,
      log.age2,
      log.age3,
      log.age4,
      log.age5,
      log.age6,

      log.sex1,
      log.sex2,
      log.sex3,
      log.sex4,
      log.sex5,
      log.sex6,

      log.relat2,
      log.relat3, # 20
      log.relat4,
      log.relat5,
      log.relat6,

      log.ecstat1,
      log.ecstat2,
      log.ecstat3,
      log.ecstat4,
      log.ecstat5,
      log.ecstat6,

      log.ethnic, # 30
      log.national,
      log.income1,
      log.income2,
      log.inc1mort,
      log.inc2mort,
      log.savings,
      log.prevown,
      nil,

      log.prevten,
      log.prevloc, # 40
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      log.ppcodenk == 0 ? 1 : nil,

      log.pregyrha,
      log.pregla,
      log.pregghb,
      log.pregother,

      log.disabled,
      log.wheel,
      log.beds, # 50
      log.proptype,
      log.builtype,
      log.la,
      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,
      log.wchair,

      log.type, # shared ownership
      log.resale,
      log.hodate&.day,
      log.hodate&.month, # 60
      log.hodate&.strftime("%y"),
      log.exdate&.day,
      log.exdate&.month,
      log.exdate&.strftime("%y"),
      log.lanomagr,

      log.frombeds,
      log.fromprop,

      log.value,
      log.equity,
      log.mortgage, # 70
      log.extrabor,
      log.deposit,
      log.cashdis,

      log.mrent,
      log.mscharge,

      log.type, # discounted ownership
      log.value,
      log.grant,
      log.discount,
      log.mortgage, # 80
      log.extrabor,
      log.deposit,
      log.mscharge,

      log.type, # outright sale
      log.othtype,
      nil,

      log.value,
      log.mortgage,
      log.extrabor,
      log.deposit, # 90
      log.mscharge,

      overrides[:organisation_id] || log.owning_organisation&.old_visible_id,
      log.created_by&.email,
      nil,
      hhregres,
      nil,
      log.armedforcesspouse,
      log.mortgagelender, # shared ownership
      log.mortgagelenderother,
      log.mortgagelender, # discounted ownership 100
      log.mortgagelenderother,
      log.mortgagelender, # outright ownership
      log.mortgagelenderother,

      log.hb,
      log.mortlen, # shared ownership
      log.mortlen, # discounted ownership
      log.mortlen, # outright ownership

      log.proplen, # discounted ownership
      log.jointmore,
      log.proplen, # shared ownership 110
      log.staircase,
      log.privacynotice,
      log.ownershipsch,
      log.companybuy, # outright sale
      log.buylivein,
      log.jointpur,
      log.buy1livein,
      log.buy2livein,
      log.hholdcount,
      log.stairbought, # 120
      log.stairowned,
      log.socprevten,
      log.mortgageused, # shared ownership
      log.mortgageused, # discounted ownership
      log.mortgageused, # outright ownership
    ]
  end

private

  def hhregres
    if log.hhregres == 1
      log.hhregresstill
    else
      log.hhregres
    end
  end
end
