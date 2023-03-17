require "rails_helper"
require "rake"

RSpec.describe "data_import" do
  describe ":local_authority_links", type: :task do
    subject(:task) { Rake::Task["data_import:local_authority_links"] }

    before do
      LocalAuthorityLink.destroy_all
      Rake.application.rake_require("tasks/local_authority_links")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:local_authority_links_file_path) { "./spec/fixtures/files/local_authority_links_2023.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }

      it "creates new local authority links records" do
        expect { task.invoke(local_authority_links_file_path) }.to change(LocalAuthorityLink, :count).by(5)
        expect(LocalAuthorityLink.where(local_authority_id: LocalAuthority.find_by(code: "E06000063").id).exists?).to be true
      end

      it "raises an error when no path is given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake data_import:local_authority_links['path/to/csv_file']")
      end

      it "raises an error when no file exists at the given path" do
        expect { task.invoke(wrong_file_path) }.to raise_error(Errno::ENOENT)
      end

      context "when a record already exists with a matching ids" do
        it "does not create a new link" do
          task.invoke(local_authority_links_file_path)
          expect { task.invoke(local_authority_links_file_path) }.to change(LocalAuthorityLink, :count).by(0)
        end
      end
    end
  end
end
