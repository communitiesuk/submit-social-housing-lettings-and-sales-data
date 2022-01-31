require "rails_helper"
require "rake"

describe "rake data_import:organisations", type: :task do
  subject(:task) { Rake::Task["data_import:organisations"] }

  let(:fixture_path) { "spec/fixtures/softwire_imports/organisations" }

  before do
    Rake.application.rake_require("tasks/data_import/organisations")
    Rake::Task.define_task(:environment)
    task.reenable
  end

  it "creates an organisation from the given XML file" do
    expect { task.invoke(fixture_path) }.to change(Organisation, :count).by(1)
    expect(Organisation.find_by(old_visible_id: 1034).name).to eq("HA Ltd")
  end
end
