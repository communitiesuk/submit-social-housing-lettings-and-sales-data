require "rails_helper"

RSpec.describe Imports::SalesLogsImportService do
  subject(:sales_log_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:fixture_directory) { "spec/fixtures/imports/sales_logs" }

  let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }
  let(:managing_organisation) { FactoryBot.create(:organisation, old_visible_id: "2", provider_type: "PRP") }
  let(:remote_folder) { "sales_logs" }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  before do
    allow(Organisation).to receive(:find_by).and_return(nil)
    allow(Organisation).to receive(:find_by).with(old_visible_id: organisation.old_visible_id).and_return(organisation)
    allow(Organisation).to receive(:find_by).with(old_visible_id: managing_organisation.old_visible_id).and_return(managing_organisation)

    # Created by users
    FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa", organisation:)
    FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f", organisation:)
  end

  context "when importing sales logs" do
    before do
      # Stub the S3 file listing and download
      allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/shared_ownership_sales_log.xml #{remote_folder}/shared_ownership_sales_log2.xml #{remote_folder}/outright_sale_sales_log.xml #{remote_folder}/discounted_ownership_sales_log.xml #{remote_folder}/lettings_log.xml])
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/shared_ownership_sales_log.xml")
                                  .and_return(open_file(fixture_directory, "shared_ownership_sales_log"), open_file(fixture_directory, "shared_ownership_sales_log"))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/shared_ownership_sales_log2.xml")
                                  .and_return(open_file(fixture_directory, "shared_ownership_sales_log2"), open_file(fixture_directory, "shared_ownership_sales_log2"))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/outright_sale_sales_log.xml")
                                  .and_return(open_file(fixture_directory, "outright_sale_sales_log"), open_file(fixture_directory, "outright_sale_sales_log"))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/discounted_ownership_sales_log.xml")
                                  .and_return(open_file(fixture_directory, "discounted_ownership_sales_log"), open_file(fixture_directory, "discounted_ownership_sales_log"))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/lettings_log.xml")
                                  .and_return(open_file(fixture_directory, "lettings_log"), open_file(fixture_directory, "lettings_log"))
    end

    it "successfully creates all sales logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).not_to receive(:info)
      expect { sales_log_service.create_logs(remote_folder) }
        .to change(SalesLog, :count).by(4)
    end

    it "only updates existing sales logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).to receive(:info).with(/Updating sales log/).exactly(4).times
      expect { 2.times { sales_log_service.create_logs(remote_folder) } }
        .to change(SalesLog, :count).by(4)
    end

    context "when there are status discrepancies" do
      let(:sales_log_file) { open_file(fixture_directory, "shared_ownership_sales_log3") }
      let(:sales_log_xml) { Nokogiri::XML(sales_log_file) }

      before do
        allow(storage_service).to receive(:get_file_io)
          .with("#{remote_folder}/shared_ownership_sales_log3.xml")
          .and_return(open_file(fixture_directory, "shared_ownership_sales_log3"), open_file(fixture_directory, "shared_ownership_sales_log3"))
        allow(storage_service).to receive(:get_file_io)
          .with("#{remote_folder}/shared_ownership_sales_log4.xml")
          .and_return(open_file(fixture_directory, "shared_ownership_sales_log4"), open_file(fixture_directory, "shared_ownership_sales_log4"))
      end

      it "the logger logs a warning with the sales log's old id/filename" do
        expect(logger).to receive(:warn).with(/is not completed/).once
        expect(logger).to receive(:warn).with(/sales log with old id:shared_ownership_sales_log3 is incomplete but status should be complete/).once

        sales_log_service.send(:create_log, sales_log_xml)
      end

      it "on completion the ids of all logs with status discrepancies are logged in a warning" do
        allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/shared_ownership_sales_log3.xml #{remote_folder}/shared_ownership_sales_log4.xml])
        expect(logger).to receive(:warn).with(/is not completed/).twice
        expect(logger).to receive(:warn).with(/is incomplete but status should be complete/).twice
        expect(logger).to receive(:warn).with(/The following sales logs had status discrepancies: \[shared_ownership_sales_log3, shared_ownership_sales_log4\]/)

        sales_log_service.create_logs(remote_folder)
      end
    end
  end

  context "when importing a specific log" do
    let(:sales_log_file) { open_file(fixture_directory, sales_log_id) }
    let(:sales_log_xml) { Nokogiri::XML(sales_log_file) }

    context "and the organisation legacy ID does not exist" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before { sales_log_xml.at_xpath("//xmlns:OWNINGORGID").content = 99_999 }

      it "raises an exception" do
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .to raise_error(RuntimeError, "Organisation not found with legacy ID 99999")
      end
    end

    context "and the log startdate is before 22/23 collection period" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:DAY").content = 10
        sales_log_xml.at_xpath("//xmlns:MONTH").content = 10
        sales_log_xml.at_xpath("//xmlns:YEAR").content = 2021
        sales_log_xml.at_xpath("//xmlns:HODAY").content = 9
        sales_log_xml.at_xpath("//xmlns:HOMONTH").content = 10
        sales_log_xml.at_xpath("//xmlns:HOYEAR").content = 2021
        sales_log_xml.at_xpath("//xmlns:EXDAY").content = 9
        sales_log_xml.at_xpath("//xmlns:EXMONTH").content = 10
        sales_log_xml.at_xpath("//xmlns:EXYEAR").content = 2021
      end

      it "does not create the log" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
        .to change(SalesLog, :count).by(0)
      end
    end

    context "when the mortgage lender is set to an existing option" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q34a").content = "halifax"
        allow(logger).to receive(:warn).and_return(nil)
      end

      it "correctly sets mortgage lender" do
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log&.mortgagelender).to be(11)
      end
    end

    context "when the mortgage lender is set to a non existing option" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q34a").content = "something else"
        allow(logger).to receive(:warn).and_return(nil)
      end

      it "correctly sets mortgage lender and mortgage lender other" do
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log&.mortgagelender).to be(40)
        expect(sales_log&.mortgagelenderother).to eq("something else")
      end
    end

    context "with shared ownership type" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      it "successfully creates a completed shared ownership log" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .to change(SalesLog, :count).by(1)
      end
    end

    context "with discounted ownership type" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      it "successfully creates a completed discounted ownership log" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .to change(SalesLog, :count).by(1)
      end
    end

    context "with outright sale type" do
      let(:sales_log_id) { "outright_sale_sales_log" }

      it "successfully creates a completed outright sale log" do
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        expect(logger).not_to receive(:info)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .to change(SalesLog, :count).by(1)
      end
    end

    context "and the mortgage soft validation is triggered (mortgage_value_check)" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q2Person1Income").content = "10"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the shared ownership deposit soft validation is triggered (shared_ownership_deposit_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:DerSaleType").content = "2"
        sales_log_xml.at_xpath("//xmlns:CALCMORT").content = "275000"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the purchase price soft validation is triggered (value_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        LaSaleRange.create!(la: "E09000033", bedrooms: 2, soft_min: 177_000, soft_max: 384_000, start_year: 2022)
        sales_log_xml.at_xpath("//xmlns:Q22PurchasePrice").content = "2750"
        sales_log_xml.at_xpath("//xmlns:CALCMORT").content = "2750"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the purchase price soft validation is triggered (income1_value_check, income2_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q2Person1Income").content = "20"
        sales_log_xml.at_xpath("//xmlns:Q2Person2Income").content = "10"
        sales_log_xml.at_xpath("//xmlns:P2Eco").content = "1"
        sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
        sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the savings soft validation is triggered (savings_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q3Savings").content = "200750"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the deposit soft validation is triggered (deposit_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q3Savings").content = "10"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the wheelchair soft validation is triggered (wheel_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q10Wheelchair").content = "1"
        sales_log_xml.at_xpath("//xmlns:Disability").content = "2"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the retirement soft validation is triggered (retirement_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:P1Eco").content = "5"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the grant soft validation is triggered (grant_value_check)" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q32Reductions").content = "5000"
        sales_log_xml.at_xpath("//xmlns:CALCMORT").content = "270000"
        sales_log_xml.at_xpath("//xmlns:Q33Discount").content = ""
        sales_log_xml.at_xpath("//xmlns:DerSaleType").content = "22"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the stairbought soft validation is triggered (staircase_bought_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:PercentBought").content = "51"
        sales_log_xml.at_xpath("//xmlns:PercentOwns").content = "81"
        sales_log_xml.at_xpath("//xmlns:Q17aStaircase").content = "1"
        sales_log_xml.at_xpath("//xmlns:Q17Resale").content = ""
        sales_log_xml.at_xpath("//xmlns:EXDAY").content = ""
        sales_log_xml.at_xpath("//xmlns:EXMONTH").content = ""
        sales_log_xml.at_xpath("//xmlns:EXYEAR").content = ""
        sales_log_xml.at_xpath("//xmlns:HODAY").content = ""
        sales_log_xml.at_xpath("//xmlns:HOMONTH").content = ""
        sales_log_xml.at_xpath("//xmlns:HOYEAR").content = ""
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and the student not child soft validation is triggered (student_not_child_value_check)" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:P2Rel").content = "P"
        sales_log_xml.at_xpath("//xmlns:P2Eco").content = "7"
        sales_log_xml.at_xpath("//xmlns:P2Age").content = "16"
      end

      it "completes the log" do
        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log.status).to eq("completed")
      end
    end

    context "and it has an invalid record with invalid child age" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//meta:status").content = "submitted-invalid"
        sales_log_xml.at_xpath("//xmlns:P2Age").content = 17
        sales_log_xml.at_xpath("//xmlns:P2Eco").content = 9
      end

      it "intercepts the relevant validation error" do
        expect(logger).to receive(:warn).with(/Log discounted_ownership_sales_log: Removing field ecstat2 from log triggering validation: Answer cannot be ‘child under 16’ as you told us the person 2 is older than 16/)
        expect(logger).to receive(:warn).with(/Log discounted_ownership_sales_log: Removing field age2 from log triggering validation: Answer cannot be over 16 as person’s 2 working situation is ‘child under 16‘/)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .not_to raise_error
      end

      it "clears out the invalid answers" do
        allow(logger).to receive(:warn)

        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)

        expect(sales_log).not_to be_nil
        expect(sales_log.age2).to be_nil
        expect(sales_log.ecstat2).to be_nil
      end
    end

    context "and it has an invalid record with invalid postcodes" do
      let(:sales_log_id) { "discounted_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q7Postcode").content = "A1 1AA" # previous postcode
        sales_log_xml.at_xpath("//xmlns:Q14Postcode").content = "A1 2AA" # postcode
      end

      it "intercepts the relevant validation error" do
        expect(logger).to receive(:warn).with(/Removing previous postcode known and previous postcode as the postcode is invalid/)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .not_to raise_error
      end

      it "clears out the invalid answers" do
        allow(logger).to receive(:warn)

        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)

        expect(sales_log).not_to be_nil
        expect(sales_log.postcode_full).to eq("A1 2AA")
        expect(sales_log.ppostcode_full).to be_nil
      end
    end

    context "and it has invalid postcodes" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//meta:status").content = "submitted-invalid"
        sales_log_xml.at_xpath("//xmlns:Q14Postcode").content = "2AA" # postcode
      end

      it "intercepts the relevant validation error" do
        expect(logger).to receive(:warn).with(/Enter a postcode in the correct format, for example AA1 1AA/)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .not_to raise_error
      end

      it "clears out the invalid answers" do
        allow(logger).to receive(:warn)

        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)

        expect(sales_log).not_to be_nil
        expect(sales_log.postcode_full).to be_nil
        expect(sales_log.postcode_full).to be_nil
      end
    end

    context "and it has an invalid record with invalid contracts exchange date" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:DAY").content = "1"
        sales_log_xml.at_xpath("//xmlns:MONTH").content = "10"
        sales_log_xml.at_xpath("//xmlns:YEAR").content = "2022"
        sales_log_xml.at_xpath("//xmlns:EXDAY").content = "1"
        sales_log_xml.at_xpath("//xmlns:EXMONTH").content = "4"
        sales_log_xml.at_xpath("//xmlns:EXYEAR").content = "2020"
      end

      it "intercepts the relevant validation error" do
        expect(logger).to receive(:warn).with(/Removing exchange date as the exchange date is invalid/)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .not_to raise_error
      end

      it "clears out the invalid answers" do
        allow(logger).to receive(:warn)

        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)

        expect(sales_log).not_to be_nil
        expect(sales_log.saledate).to eq(Time.zone.local(2022, 10, 1))
        expect(sales_log.exdate).to be_nil
      end
    end

    context "and it has an invalid income" do
      let(:sales_log_id) { "shared_ownership_sales_log" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q2Person1Income").content = "85000"
        sales_log_xml.at_xpath("//xmlns:Q14ONSLACode").content = "E07000223"
      end

      it "intercepts the relevant validation error" do
        expect(logger).to receive(:warn).with(/Removing income1 as the income1 is invalid/)
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .not_to raise_error
      end

      it "clears out the invalid answers" do
        allow(logger).to receive(:warn)

        sales_log_service.send(:create_log, sales_log_xml)
        sales_log = SalesLog.find_by(old_id: sales_log_id)

        expect(sales_log).not_to be_nil
        expect(sales_log.income1).to be_nil
      end
    end

    context "when inferring default answers for completed sales logs" do
      context "when the armedforcesspouse is not answered" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:ARMEDFORCESSPOUSE").content = ""
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets armedforcesspouse to don't know" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.armedforcesspouse).to be(7)
        end
      end

      context "when the savings not known is not answered and savings is not given" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:savingsKnown").content = ""
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets savingsnk to not know" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.savingsnk).to be(1)
        end
      end

      context "when the savings not known is not answered and savings is given" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:Q3Savings").content = "10000"
          sales_log_xml.at_xpath("//xmlns:savingsKnown").content = ""
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets savingsnk to know" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.savingsnk).to be(0)
        end
      end

      context "when inferring age known" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
          sales_log_xml.at_xpath("//xmlns:P1Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Age").content = "22"
          allow(logger).to receive(:warn).and_return(nil)

          sales_log_service.send(:create_log, sales_log_xml)
        end

        it "sets age known to no if age not answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.age1_known).to be(1) # unknown
          expect(sales_log&.age2_known).to be(1) # unknown
        end

        it "sets age known to yes if age answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.age3_known).to be(0) # known
        end
      end

      context "when inferring gender" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
          sales_log_xml.at_xpath("//xmlns:P1Sex").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Sex").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Sex").content = "Female"
          allow(logger).to receive(:warn).and_return(nil)

          sales_log_service.send(:create_log, sales_log_xml)
        end

        it "sets gender to prefers not to say if not answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.sex1).to eq("R")
          expect(sales_log&.sex2).to eq("R")
        end

        it "sets the gender correctly if answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.sex3).to eq("F")
        end
      end

      context "when inferring ethnic group" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "1"
          sales_log_xml.at_xpath("//xmlns:P1Eth").content = ""
          allow(logger).to receive(:warn).and_return(nil)

          sales_log_service.send(:create_log, sales_log_xml)
        end

        it "sets ethnic group to prefers not to say if not answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.ethnic_group).to eq(17)
        end
      end

      context "when inferring nationality" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "1"
          sales_log_xml.at_xpath("//xmlns:P1Nat").content = ""
          allow(logger).to receive(:warn).and_return(nil)

          sales_log_service.send(:create_log, sales_log_xml)
        end

        it "sets nationality to prefers not to say if not answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.national).to eq(13)
        end
      end

      context "when inferring economic status" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
          sales_log_xml.at_xpath("//xmlns:P1Eco").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Eco").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Eco").content = "3"
          allow(logger).to receive(:warn).and_return(nil)

          sales_log_service.send(:create_log, sales_log_xml)
        end

        it "sets economic status to prefers not to say if not answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.ecstat1).to eq(10)
          expect(sales_log&.ecstat2).to eq(10)
        end

        it "sets the economic status correctly if answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.ecstat3).to eq(3)
        end
      end

      context "when inferring relationship" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
          sales_log_xml.at_xpath("//xmlns:P2Rel").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Rel").content = "Partner"
          allow(logger).to receive(:warn).and_return(nil)

          sales_log_service.send(:create_log, sales_log_xml)
        end

        it "sets relationship to prefers not to say if not answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.relat2).to eq("R")
        end

        it "sets the relationship correctly if answered" do
          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.relat3).to eq("P")
        end
      end

      context "when inferring armed forces" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets hhregres to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:ArmedF").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hhregres).to eq(8)
        end

        it "sets hhregres correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:ArmedF").content = "7 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hhregres).to eq(7)
        end
      end

      context "when inferring disability" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets disabled to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:Disability").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.disabled).to eq(3)
        end

        it "sets disabled correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:Disability").content = "2 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.disabled).to eq(2)
        end
      end

      context "when inferring wheelchair" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets wheel to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:Q10Wheelchair").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.wheel).to eq(3)
        end

        it "sets wheel correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:Q10Wheelchair").content = "2 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.wheel).to eq(2)
        end
      end

      context "when inferring housing benefit" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets hb to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:Q2a").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hb).to eq(4)
        end

        it "sets hb correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:Q2a").content = "2 Housing Benefit"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hb).to eq(2)
        end
      end

      context "when inferring income not known" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets income to not known if not answered and income is not given" do
          sales_log_xml.at_xpath("//xmlns:P1IncKnown").content = ""
          sales_log_xml.at_xpath("//xmlns:Q2Person1Income").content = ""
          sales_log_xml.at_xpath("//xmlns:P2IncKnown").content = ""
          sales_log_xml.at_xpath("//xmlns:Q2Person2Income").content = ""

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.income1nk).to eq(1)
          expect(sales_log&.income2nk).to eq(1)
        end

        it "sets income to known if not answered but the income is given" do
          sales_log_xml.at_xpath("//xmlns:P1IncKnown").content = ""
          sales_log_xml.at_xpath("//xmlns:Q2Person1Income").content = "30000"
          sales_log_xml.at_xpath("//xmlns:P2IncKnown").content = ""
          sales_log_xml.at_xpath("//xmlns:Q2Person2Income").content = "40000"

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.income1nk).to eq(0)
          expect(sales_log&.income2nk).to eq(0)
        end

        it "sets income known correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:P1IncKnown").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:P2IncKnown").content = "2 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.income1nk).to eq(0)
          expect(sales_log&.income2nk).to eq(1)
        end
      end

      context "when inferring prevown" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets prevown to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:Q4PrevOwnedProperty").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.prevown).to eq(3)
        end

        it "sets prevown correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:Q4PrevOwnedProperty").content = "2 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.prevown).to eq(2)
        end
      end

      context "when inferring household count" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets hholdcount to last person the information is given for if HHMEMB is not set" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Age").content = "20"
          sales_log_xml.at_xpath("//xmlns:P3Sex").content = "R"
          sales_log_xml.at_xpath("//xmlns:P4Age").content = "23"

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(3)
        end

        it "sets hholdcount to last person the information is given for - buyers if HHMEMB is 0" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Age").content = "20"
          sales_log_xml.at_xpath("//xmlns:P3Sex").content = "R"
          sales_log_xml.at_xpath("//xmlns:P4Age").content = "23"

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(2)
        end

        it "sets hholdcount to 0 no information for people is given and HHMEMB is not set" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = ""
          sales_log_xml.at_xpath("//xmlns:LiveInOther").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Sex").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Sex").content = ""
          sales_log_xml.at_xpath("//xmlns:P4Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P4Sex").content = ""

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(0)
        end

        it "sets hholdcount to the 0 if no information for people is given and HHMEMB is 0" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "0"
          sales_log_xml.at_xpath("//xmlns:LiveInOther").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P2Sex").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P3Sex").content = ""
          sales_log_xml.at_xpath("//xmlns:P4Age").content = ""
          sales_log_xml.at_xpath("//xmlns:P4Sex").content = ""

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(0)
        end

        it "doesn't hang if jointpur is not given" do
          sales_log_xml.at_xpath("//xmlns:joint").content = ""
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "0"

          sales_log_service.send(:create_log, sales_log_xml)
        end
      end

      context "when inferring income used" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets inc1mort and inc2mort to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:Q2Person1Mortgage").content = ""
          sales_log_xml.at_xpath("//xmlns:Q2Person2MortApplication").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.inc1mort).to eq(3)
          expect(sales_log&.inc2mort).to eq(3)
        end

        it "sets inc1mort and inc2mort correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:Q2Person1Mortgage").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:Q2Person2MortApplication").content = "2 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.inc1mort).to eq(1)
          expect(sales_log&.inc2mort).to eq(2)
        end
      end

      context "when inferring buyer organisation" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets pregblank to true if no other organisations are selected" do
          sales_log_xml.at_xpath("//xmlns:PREGYRHA").content = ""
          sales_log_xml.at_xpath("//xmlns:PREGLA").content = ""
          sales_log_xml.at_xpath("//xmlns:PREGHBA").content = ""
          sales_log_xml.at_xpath("//xmlns:PREGOTHER").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.pregyrha).to eq(nil)
          expect(sales_log&.pregla).to eq(nil)
          expect(sales_log&.pregghb).to eq(nil)
          expect(sales_log&.pregother).to eq(nil)
          expect(sales_log&.pregblank).to eq(1)
        end

        it "sets pregblank and other organisation fields correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:PREGYRHA").content = "Yes"
          sales_log_xml.at_xpath("//xmlns:PREGLA").content = "Yes"
          sales_log_xml.at_xpath("//xmlns:PREGHBA").content = "Yes"
          sales_log_xml.at_xpath("//xmlns:PREGOTHER").content = "Yes"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.pregyrha).to eq(1)
          expect(sales_log&.pregla).to eq(1)
          expect(sales_log&.pregghb).to eq(1)
          expect(sales_log&.pregother).to eq(1)
          expect(sales_log&.pregblank).to eq(nil)
        end
      end

      context "when setting default buyer 2 live in for discounted ownership" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets buy2livein to true if it is joint purchase and it's not answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:LiveInBuyer2").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.buy2livein).to eq(1)
        end

        it "sets buy2livein correctly if it's answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:LiveInBuyer2").content = "1 Yes"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.buy2livein).to eq(1)
        end
      end

      context "when setting default buyer 2 live in for shared ownership" do
        let(:sales_log_id) { "shared_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets buy2livein to true if it is joint purchase and it's not answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:LiveInBuyer2").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.buy2livein).to eq(1)
        end

        it "sets buy2livein correctly if it's answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:LiveInBuyer2").content = "2 No"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.buy2livein).to eq(2)
        end
      end

      context "when setting default buyer 2 live in for outright sale" do
        let(:sales_log_id) { "outright_sale_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "does not set buy2livein if it is joint purchase and it's not answered" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:LiveInBuyer2").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.buy2livein).to eq(nil)
        end
      end

      context "when setting location fields" do
        let(:sales_log_id) { "outright_sale_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "correctly sets LA if postcode is not given" do
          sales_log_xml.at_xpath("//xmlns:Q14ONSLACode").content = "E07000142"
          sales_log_xml.at_xpath("//xmlns:Q14Postcode").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.pcodenk).to eq(1) # postcode not known
          expect(sales_log&.is_la_inferred).to eq(false)
          expect(sales_log&.la_known).to eq(1) # la known
          expect(sales_log&.la).to eq("E07000142")
          expect(sales_log&.status).to eq("completed")
        end

        it "correctly sets previous LA if postcode is not given" do
          sales_log_xml.at_xpath("//xmlns:Q7ONSLACode").content = "E07000142"
          sales_log_xml.at_xpath("//xmlns:Q7Postcode").content = ""
          sales_log_xml.at_xpath("//xmlns:Q7UnknownPostcode").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.ppcodenk).to eq(1) # previous postcode not known
          expect(sales_log&.is_previous_la_inferred).to eq(false)
          expect(sales_log&.previous_la_known).to eq(1) # la known
          expect(sales_log&.prevloc).to eq("E07000142")
          expect(sales_log&.status).to eq("completed")
        end

        it "correctly sets posctode if given" do
          sales_log_xml.at_xpath("//xmlns:Q7Postcode").content = "GL519EX"
          sales_log_xml.at_xpath("//xmlns:Q7UnknownPostcode").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.ppcodenk).to eq(0)
          expect(sales_log&.ppostcode_full).to eq("GL51 9EX")
          expect(sales_log&.status).to eq("completed")
        end

        it "correctly sets location fields for when location cannot be inferred from postcode" do
          sales_log_xml.at_xpath("//xmlns:Q14ONSLACode").content = "E07000142"
          sales_log_xml.at_xpath("//xmlns:Q14Postcode").content = "A11AA"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.pcodenk).to eq(0) # postcode known
          expect(sales_log&.la_known).to eq(1) # la known
          expect(sales_log&.la).to eq("E07000142")
          expect(sales_log&.status).to eq("completed")
        end
      end

      context "when setting default buyer 1 previous tenancy" do
        let(:sales_log_id) { "outright_sale_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets prevten to don't know if not answered" do
          sales_log_xml.at_xpath("//xmlns:Q6PrevTenure").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.prevten).to eq(0) # don't know
        end

        it "sets prevten to correctly if answered" do
          sales_log_xml.at_xpath("//xmlns:Q6PrevTenure").content = "2 Private registered provider (PRP) or housing association tenant"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.prevten).to eq(2)
        end
      end

      context "when mortgage used is don't know" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets mortgageused to don't know if mortlen, mortgage and extrabor are blank" do
          sales_log_xml.at_xpath("//xmlns:MORTGAGEUSED").content = "3 Don't know"
          sales_log_xml.at_xpath("//xmlns:Q35Borrowing").content = ""
          sales_log_xml.at_xpath("//xmlns:Q34b").content = ""
          sales_log_xml.at_xpath("//xmlns:CALCMORT").content = ""
          sales_log_xml.at_xpath("//xmlns:Q36CashDeposit").content = "134750"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.mortgageused).to eq(3)
        end

        it "sets mortgageused to yes if mortgage is given" do
          sales_log_xml.at_xpath("//xmlns:MORTGAGEUSED").content = "3 Don't know"
          sales_log_xml.at_xpath("//xmlns:Q35Borrowing").content = ""
          sales_log_xml.at_xpath("//xmlns:Q34b").content = ""
          sales_log_xml.at_xpath("//xmlns:CALCMORT").content = "134750"
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.mortgageused).to eq(1)
        end

        it "sets mortgageused to yes if mortlen is given" do
          sales_log_xml.at_xpath("//xmlns:MORTGAGEUSED").content = "3 Don't know"
          sales_log_xml.at_xpath("//xmlns:Q35Borrowing").content = ""
          sales_log_xml.at_xpath("//xmlns:Q34b").content = "10"
          sales_log_xml.at_xpath("//xmlns:CALCMORT").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.mortgageused).to eq(1)
        end

        it "sets mortgageused to yes if extrabor is given" do
          sales_log_xml.at_xpath("//xmlns:MORTGAGEUSED").content = "3 Don't know"
          sales_log_xml.at_xpath("//xmlns:Q35Borrowing").content = "3000"
          sales_log_xml.at_xpath("//xmlns:Q34b").content = ""
          sales_log_xml.at_xpath("//xmlns:CALCMORT").content = ""
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.mortgageused).to eq(1)
        end
      end

      context "when the extrabor is not answered" do
        let(:sales_log_id) { "discounted_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:Q35Borrowing").content = ""
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets extrabor to don't know" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.extrabor).to be(3)
        end
      end

      context "when the fromprop is not answered" do
        let(:sales_log_id) { "shared_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:Q21PropertyType").content = ""
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets fromprop to don't know" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.fromprop).to be(0)
        end
      end

      context "when the socprevten is not answered" do
        let(:sales_log_id) { "shared_ownership_sales_log" }

        before do
          sales_log_xml.at_xpath("//xmlns:PrevRentType").content = ""
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "sets socprevten to don't know" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.socprevten).to be(10)
        end
      end
    end
  end
end
