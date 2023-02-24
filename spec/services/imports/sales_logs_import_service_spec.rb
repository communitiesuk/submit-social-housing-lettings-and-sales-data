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
    { "GL519EX" => "E07000078",
      "SW1A2AA" => "E09000033",
      "SW1A1AA" => "E09000033",
      "SW147QP" => "E09000027",
      "B955HZ" => "E07000221" }.each do |postcode, district_code|
        WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/#{postcode}/).to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"#{district_code}\",\"codes\":{\"admin_district\":\"#{district_code}\"}}}", headers: {})
      end

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
                                  .and_return(%W[#{remote_folder}/shared_ownership_sales_log.xml #{remote_folder}/shared_ownership_sales_log2.xml #{remote_folder}/outright_sale_sales_log.xml #{remote_folder}/discounted_ownership_sales_log.xml])
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

      context "and it's an outright sale" do
        let(:sales_log_id) { "outright_sale_sales_log" }

        before do
          allow(logger).to receive(:warn).and_return(nil)
        end

        it "infers mscharge_known as no" do
          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log.mscharge_known).to eq(0)
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

        it "sets hholdcount to hhmemb - 1 if not answered and not joint purchase" do
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
          sales_log_xml.at_xpath("//xmlns:joint").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:LiveInOther").content = ""

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(2)
        end

        it "sets hholdcount to hhmemb - 2 if not answered and joint purchase" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "3"
          sales_log_xml.at_xpath("//xmlns:LiveInOther").content = ""

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(1)
        end

        it "sets hholdcount to 0 if HHMEMB is 0" do
          sales_log_xml.at_xpath("//xmlns:joint").content = "1 Yes"
          sales_log_xml.at_xpath("//xmlns:JointMore").content = "2 No"
          sales_log_xml.at_xpath("//xmlns:HHMEMB").content = "0"
          sales_log_xml.at_xpath("//xmlns:LiveInOther").content = ""

          sales_log_service.send(:create_log, sales_log_xml)

          sales_log = SalesLog.find_by(old_id: sales_log_id)
          expect(sales_log&.hholdcount).to eq(0)
        end
      end
    end
  end
end
