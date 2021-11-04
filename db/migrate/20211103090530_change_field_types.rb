class ChangeFieldTypes < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :ethnic, "integer USING ethnic::integer"
      t.change :national, "integer USING national::integer"
      t.change :ecstat1, "integer USING ecstat1::integer"
      t.change :ecstat2, "integer USING ecstat2::integer"
      t.change :ecstat3, "integer USING ecstat3::integer"
      t.change :ecstat4, "integer USING ecstat4::integer"
      t.change :ecstat5, "integer USING ecstat5::integer"
      t.change :ecstat6, "integer USING ecstat6::integer"
      t.change :ecstat7, "integer USING ecstat7::integer"
      t.change :ecstat8, "integer USING ecstat8::integer"
      t.change :prevten, "integer USING prevten::integer"
      t.change :homeless, "integer USING homeless::integer"
      t.change :underoccupation_benefitcap, "integer USING underoccupation_benefitcap::integer"
      t.change :reservist, "integer USING reservist::integer"
      t.change :leftreg, "integer USING leftreg::integer"
      t.change :illness, "integer USING illness::integer"
      t.change :preg_occ, "integer USING preg_occ::integer"
      t.change :housingneeds_a, "integer USING housingneeds_a::integer"
      t.change :housingneeds_b, "integer USING housingneeds_b::integer"
      t.change :housingneeds_c, "integer USING housingneeds_c::integer"
      t.change :housingneeds_f, "integer USING housingneeds_f::integer"
      t.change :housingneeds_g, "integer USING housingneeds_g::integer"
      t.change :housingneeds_h, "integer USING housingneeds_h::integer"
      t.change :illness_type_1, "integer USING illness_type_1::integer"
      t.change :illness_type_2, "integer USING illness_type_2::integer"
      t.change :illness_type_3, "integer USING illness_type_3::integer"
      t.change :illness_type_4, "integer USING illness_type_4::integer"
      t.change :illness_type_5, "integer USING illness_type_5::integer"
      t.change :illness_type_6, "integer USING illness_type_6::integer"
      t.change :illness_type_7, "integer USING illness_type_7::integer"
      t.change :illness_type_8, "integer USING illness_type_8::integer"
      t.change :illness_type_9, "integer USING illness_type_9::integer"
      t.change :illness_type_10, "integer USING illness_type_10::integer"
      t.change :rp_homeless, "integer USING rp_homeless::integer"
      t.change :rp_insan_unsat, "integer USING rp_insan_unsat::integer"
      t.change :rp_medwel, "integer USING rp_medwel::integer"
      t.change :rp_hardship, "integer USING rp_hardship::integer"
      t.change :rp_dontknow, "integer USING rp_dontknow::integer"
      t.change :cbl, "integer USING cbl::integer"
      t.change :chr, "integer USING chr::integer"
      t.change :cap, "integer USING cap::integer"
      t.change :startertenancy, "integer USING startertenancy::integer"
      t.change :tenancylength, "integer USING tenancylength::integer"
      t.change :tenancy, "integer USING tenancy::integer"
      t.change :landlord, "integer USING landlord::integer"
      t.change :rsnvac, "integer USING rsnvac::integer"
      t.change :unittype_gn, "integer USING unittype_gn::integer"
      t.change :beds, "integer USING beds::integer"
      t.change :wchair, "integer USING wchair::integer"
      t.change :incfreq, "integer USING incfreq::integer"
      t.change :benefits, "integer USING benefits::integer"
      t.change :period, "integer USING period::integer"
      t.change :brent, "integer USING brent::integer"
      t.change :scharge, "integer USING scharge::integer"
      t.change :pscharge, "integer USING pscharge::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :ethnic, :string
      t.change :national, :string
      t.change :ecstat1, :string
      t.change :ecstat2, :string
      t.change :ecstat3, :string
      t.change :ecstat4, :string
      t.change :ecstat5, :string
      t.change :ecstat6, :string
      t.change :ecstat7, :string
      t.change :ecstat8, :string
      t.change :prevten, :string
      t.change :homeless, :string
      t.change :underoccupation_benefitcap, :string
      t.change :reservist, :string
      t.change :leftreg, :string
      t.change :illness, :string
      t.change :preg_occ, :string
      t.change :housingneeds_a, "boolean USING housingneeds_a::boolean"
      t.change :housingneeds_b, "boolean USING housingneeds_b::boolean"
      t.change :housingneeds_c, "boolean USING housingneeds_c::boolean"
      t.change :housingneeds_f, "boolean USING housingneeds_f::boolean"
      t.change :housingneeds_g, "boolean USING housingneeds_g::boolean"
      t.change :housingneeds_h, "boolean USING housingneeds_h::boolean"
      t.change :illness_type_1, "boolean USING illness_type_1::boolean"
      t.change :illness_type_2, "boolean USING illness_type_2::boolean"
      t.change :illness_type_3, "boolean USING illness_type_3::boolean"
      t.change :illness_type_4, "boolean USING illness_type_4::boolean"
      t.change :illness_type_5, "boolean USING illness_type_5::boolean"
      t.change :illness_type_6, "boolean USING illness_type_6::boolean"
      t.change :illness_type_7, "boolean USING illness_type_7::boolean"
      t.change :illness_type_8, "boolean USING illness_type_8::boolean"
      t.change :illness_type_9, "boolean USING illness_type_9::boolean"
      t.change :illness_type_10, "boolean USING illness_type_10::boolean"
      t.change :rp_homeless, :boolean
      t.change :rp_insan_unsat, :boolean
      t.change :rp_medwel, :boolean
      t.change :rp_hardship, :boolean
      t.change :rp_dontknow, :boolean
      t.change :cbl_letting, :string
      t.change :chr_letting, :string
      t.change :cap_letting, :string
      t.change :startertenancy, :string
      t.change :tenancylength, :string
      t.change :tenancy, :string
      t.change :landlord, :string
      t.change :rsnvac, :string
      t.change :unittype_gn, :string
      t.change :beds, :string
      t.change :wchair, :string
      t.change :incfreq, :string
      t.change :benefits, :string
      t.change :period, :string
      t.change :brent, :string
      t.change :scharge, :string
      t.change :pscharge, :string
    end
  end
end
