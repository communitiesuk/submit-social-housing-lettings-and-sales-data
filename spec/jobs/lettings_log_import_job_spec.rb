require "rails_helper"

RSpec.describe LettingsLogImportJob do
  include Helpers

  let(:job) { described_class.new }

  describe "#perform" do
    context "with valid params" do
      it "executes LettingsLogsImportProcessor" do
        expect(Imports::LettingsLogsImportProcessor).to receive(:new)

        # Very basic example. See fixtures/imports/logs for
        # thorough examples
        xml_document_as_string = <<~XML
          <Group>
            <Group>
              <Q17>7 Weekly for 48 weeks</Q17>
              <Q18aiii override-field=""/>
              <Q19repair/>
            </Group>
          </Group>
        XML

        job.perform("LLRun-202210040105", xml_document_as_string)
      end
    end
  end
end
