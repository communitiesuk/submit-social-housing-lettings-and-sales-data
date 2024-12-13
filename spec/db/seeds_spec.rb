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

  # Doing this in one test should save ~2 minutes
  it "sets up correct data idempotently" do
    expect {
      Rails.application.load_seed
    }.to change(User, :count)
     .and change(Organisation, :count)
     .and change(OrganisationRelationship, :count)
     .and change(Scheme, :count)
     .and change(Location, :count)
     .and change(LaRentRange, :count)

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
