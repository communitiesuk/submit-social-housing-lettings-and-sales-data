require "rails_helper"
require "rake"

RSpec.describe "seeding process", type: task do
  # rubocop:disable RSpec/ExpectOutput
  around do |example|
    original_stdout = $stdout
    $stdout = File.open(File::NULL, "w")

    example.run

    $stdout = original_stdout
  end
  # rubocop:enable RSpec/ExpectOutput

  before do
    Rake.application.rake_require("tasks/rent_ranges")
    Rake::Task.define_task(:environment)

    allow(Rails.env).to receive(:test?).and_return(false)
    allow(Rails.env).to receive(:review?).and_return(true)
  end

  it "sets up correct data" do
    expect {
      Rails.application.load_seed
    }.to change(User, :count).by(8)
     .and change(Organisation, :count).by(8)
     .and change(OrganisationRelationship, :count).by(4)
     .and change(Scheme, :count).by(3)
     .and change(Location, :count).by(3)
     .and change(LaRentRange, :count).by(22_850)
  end

  it "is idempotent" do
    Rails.application.load_seed

    expect {
      Rails.application.load_seed
    }.to not_change(User, :count)
     .and not_change(Organisation, :count)
     .and not_change(OrganisationRelationship, :count)
     .and not_change(Scheme, :count)
     .and not_change(Location, :count)
     .and not_change(LaRentRange, :count)
  end
end
