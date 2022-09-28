require "rails_helper"

RSpec.describe Log, type: :model do
  it "has two child log classes" do
    expect(SalesLog).to be < described_class
    expect(LettingsLog).to be < described_class
  end
end
