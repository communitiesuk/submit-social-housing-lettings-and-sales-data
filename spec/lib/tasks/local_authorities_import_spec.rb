require "rails_helper"
require "rake"

RSpec.describe "data_import" do
  describe ":local_authorities", type: :task do
    subject(:task) { Rake::Task["data_import:local_authorities"] }

    before do
      LocalAuthority.destroy_all
      Rake.application.rake_require("tasks/local_authorities")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:local_authorities_file_path) { "./spec/fixtures/files/local_authorities.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }

      it "creates new local authorities records" do
        expect { task.invoke(local_authorities_file_path) }.to change(LocalAuthority, :count).by(5)
        expect(LocalAuthority.where(code: "S12000041").exists?).to be true
      end

      it "raises an error when no path is given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:local_authorities['path/to/csv_file']")
      end

      it "raises an error when no file exists at the given path" do
        expect { task.invoke(wrong_file_path) }.to raise_error(Errno::ENOENT)
      end

      context "when a record already exists with a matching code index" do
        let!(:local_authority) { LocalAuthority.create(code: "S12000041", name: "Something else", start_date: Time.zone.local(2021, 4, 1)) }

        it "updates local authority if the record is matched on code" do
          task.invoke(local_authorities_file_path)
          local_authority.reload
          expect(local_authority.name).to eq("Angus")
        end
      end
    end
  end
end
