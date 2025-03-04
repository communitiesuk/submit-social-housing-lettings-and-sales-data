require "rails_helper"
require "shared/shared_examples_for_derived_fields"

RSpec.describe SalesLog, type: :model do
  include_examples "shared examples for derived fields", :sales_log

  describe "set_derived_fields!" do
    it "correctly derives and saves exday, exmonth and exyear" do
      log = build(:sales_log, exdate: Time.gm(2023, 5, 4))
      expect { log.set_derived_fields! }.to change(log, :exday).from(nil).to(4)
                                        .and change(log, :exmonth).from(nil).to(5)
                                        .and change(log, :exyear).from(nil).to(2023)
    end

    it "correctly derives and saves pcode1 and pcode1 and pcode2" do
      log = build(:sales_log, postcode_full: "W6 0SP")
      expect { log.set_derived_fields! }.to change(log, :pcode1).from(nil).to("W6")
                                        .and change(log, :pcode2).from(nil).to("0SP")
    end

    it "sets pregblank field when no buyer organisation is selected" do
      log = build(:sales_log, pregyrha: 0, pregla: 0, pregghb: 0, pregother: 0)
      expect { log.set_derived_fields! }.to change(log, :pregblank).from(nil).to(1)
    end

    %i[pregyrha pregla pregghb pregother].each do |field|
      it "does not set pregblank field when #{field} is selected" do
        log = build(:sales_log, pregyrha: 0, pregla: 0, pregghb: 0, pregother: 0)
        log[field] = 1
        expect { log.set_derived_fields! }.to not_change(log, :pregblank)
      end
    end

    it "correctly derives nationality_all/nationality_all_buyer2 when _group is UK" do
      log = build(:sales_log, nationality_all_group: 826, nationality_all_buyer2_group: 826)
      expect { log.set_derived_fields! }.to change(log, :nationality_all).from(nil).to(826)
                                        .and change(log, :nationality_all_buyer2).from(nil).to(826)
    end

    it "correctly derives nationality_all/nationality_all_buyer2 when buyer prefers not to say" do
      log = build(:sales_log, nationality_all_group: 0, nationality_all_buyer2_group: 0)
      expect { log.set_derived_fields! }.to change(log, :nationality_all).from(nil).to(0)
                                        .and change(log, :nationality_all_buyer2).from(nil).to(0)
    end

    it "does not derive nationality_all/nationality_all_buyer2 when it is other" do
      log = build(:sales_log, nationality_all_group: 12, nationality_all_buyer2_group: 12)
      expect { log.set_derived_fields! }.to not_change(log, :nationality_all)
                                        .and not_change(log, :nationality_all_buyer2)
    end

    it "does not derive nationality_all/nationality_all_buyer2 when it is not given" do
      log = build(:sales_log, nationality_all_group: nil, nationality_all_buyer2_group: nil)
      expect { log.set_derived_fields! }.to not_change(log, :nationality_all)
                                        .and not_change(log, :nationality_all_buyer2)
    end

    it "derives a mortgage value of 0 when mortgage is not used" do
      log = build(:sales_log, mortgage: 100_000, mortgageused: 2)
      expect { log.set_derived_fields! }.to change(log, :mortgage).from(100_000).to(0)
    end

    it "clears mortgage value if mortgage used is changed from no to yes" do
      log = create(:sales_log, :completed, mortgageused: 2, grant: nil)
      log.mortgageused = 1
      expect { log.set_derived_fields! }.to change(log, :mortgage).from(0).to(nil)
    end

    it "clears mortgage value if mortgage used is changed from no to don't know" do
      log = create(:sales_log, :shared_ownership_setup_complete, stairowned: 100, mortgage: 0, mortgageused: 2)
      log.mortgageused = 3
      expect { log.set_derived_fields! }.to change(log, :mortgage).from(0).to(nil)
    end

    it "clears mortgage value if mortgage used is changed from yes to don't know" do
      log = create(:sales_log, :shared_ownership_setup_complete, staircase: 2, mortgage: 50_000, mortgageused: 1)
      log.mortgageused = 3
      expect { log.set_derived_fields! }.to change(log, :mortgage).from(50_000).to(nil)
    end

    describe "#clear_child_ecstat_for_age_changes!" do
      it "clears the working situation of a person that was previously a child under 16" do
        log = create(:sales_log, :completed, age3: 13, age4: 16, age5: 45)
        log.age3 = 17
        expect { log.set_derived_fields! }.to change(log, :ecstat3).from(9).to(nil)
      end

      it "does not clear the working situation of a person that had an age change but is still a child under 16" do
        log = create(:sales_log, :completed, age3: 13, age4: 16, age5: 45)
        log.age3 = 15
        expect { log.set_derived_fields! }.to not_change(log, :ecstat3)
      end

      it "does not clear the working situation of a person that had an age change but is still an adult" do
        log = create(:sales_log, :completed, age3: 13, age4: 16, age5: 45)
        log.age5 = 46
        expect { log.set_derived_fields! }.to not_change(log, :ecstat5)
      end
    end

    context "with a log that is not outright sales" do
      it "does not derive deposit when mortgage used is no" do
        log = build(:sales_log, :shared_ownership_setup_complete, value: 123_400, deposit: nil, mortgageused: 2)
        expect { log.set_derived_fields! }.to not_change(log, :deposit)
      end
    end

    context "with an outright sales log" do
      it "derives deposit as the value when mortgage used is no" do
        log = build(:sales_log, :outright_sale_setup_complete, value: 123_400, deposit: nil, mortgageused: 2)
        expect { log.set_derived_fields! }.to change(log, :deposit).from(nil).to(123_400)
      end

      it "does not derive deposit when mortgage used is yes" do
        log = build(:sales_log, :outright_sale_setup_complete, value: 123_400, deposit: nil, mortgageused: 1)
        expect { log.set_derived_fields! }.to not_change(log, :deposit)
      end

      it "sets deposit to nil when mortgage used is don't know" do
        log = build(:sales_log, :outright_sale_setup_complete, value: 123_400, deposit: 0, mortgageused: 3)
        expect { log.set_derived_fields! }.to change(log, :deposit).from(0).to(nil)
      end

      context "with outright sales log" do
        before do
          allow(Time).to receive(:now).and_return(Time.zone.local(2024, 5, 4))
        end

        it "clears derived deposit when setting mortgage used to yes" do
          log = create(:sales_log, :outright_sale_setup_complete, value: 123_400, deposit: 123_400, mortgageused: 2)
          log.mortgageused = 1
          expect { log.set_derived_fields! }.to change(log, :deposit).from(123_400).to(nil)
        end

        it "clears that buyer 1 will live in the property if joint purchase is updated" do
          log = create(:sales_log, :outright_sale_setup_complete, buylivein: 1, jointpur: 2)
          log.jointpur = 1
          expect { log.set_derived_fields! }.to change(log, :buy1livein).from(1).to(nil)
        end
      end

      context "when buyers will live in the property" do
        context "and the sale is not a joint purchase" do
          it "derives that buyer 1 will live in the property" do
            log = build(:sales_log, :shared_ownership_setup_complete, staircase: 2, buylivein: 1, jointpur: 2)
            expect { log.set_derived_fields! }.to change(log, :buy1livein).from(nil).to(1)
          end

          it "does not derive a value for whether buyer 2 will live in the property" do
            log = build(:sales_log, :shared_ownership_setup_complete, staircase: 2, buylivein: 1, jointpur: 2)
            log.set_derived_fields!
            expect(log.buy2livein).to be_nil
          end
        end

        context "and the sale is a joint purchase" do
          it "does not derive values for whether buyer 1 or buyer 2 will live in the property" do
            log = build(:sales_log, :outright_sale_setup_complete, buylivein: 1, jointpur: 1)
            log.set_derived_fields!
            expect(log.buy1livein).to be_nil
            expect(log.buy2livein).to be_nil
          end
        end
      end

      context "when buyers will not live in the property" do
        context "and the sale is not a joint purchase" do
          it "derives that buyer 1 will not live in the property" do
            log = build(:sales_log, :outright_sale_setup_complete, buylivein: 2, jointpur: 2)
            expect { log.set_derived_fields! }.to change(log, :buy1livein).from(nil).to(2)
          end

          it "does not derive a value for whether buyer 2 will live in the property" do
            log = build(:sales_log, :outright_sale_setup_complete, buylivein: 2, jointpur: 2)
            log.set_derived_fields!
            expect(log.buy2livein).to be_nil
          end
        end

        context "and the sale is a joint purchase" do
          it "derives that neither buyer 1 nor buyer 2 will live in the property" do
            log = build(:sales_log, :outright_sale_setup_complete, buylivein: 2, jointpur: 1)
            expect { log.set_derived_fields! }.to change(log, :buy1livein).from(nil).to(2)
                                              .and change(log, :buy2livein).from(nil).to(2)
          end
        end
      end
    end
  end
end
