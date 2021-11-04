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
      t.change :housingneeds_a, :boolean
      t.change :housingneeds_b, :boolean
      t.change :housingneeds_c, :boolean
      t.change :housingneeds_f, :boolean
      t.change :housingneeds_g, :boolean
      t.change :housingneeds_h, :boolean

    end
  end
end
