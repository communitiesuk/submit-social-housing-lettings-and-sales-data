require "rails_helper"

RSpec.describe Scheme, type: :model do
  describe "#new" do
    let(:scheme) { FactoryBot.create(:scheme) }

    it "belongs to an organisation" do
      expect(scheme.organisation).to be_a(Organisation)
    end

    describe "scopes" do
      let(:organisation) { FactoryBot.create(:organisation, name: "Foo") }
      let(:different_organisation) { FactoryBot.create(:organisation, name: "Bar") }
      let!(:scheme_1) { FactoryBot.create(:scheme, organisation: organisation) }
      let!(:scheme_2) { FactoryBot.create(:scheme, organisation: different_organisation) }

      context "when searching by code" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by_code(scheme_1.code.upcase).count).to eq(1)
          expect(described_class.search_by_code(scheme_1.code.downcase).count).to eq(1)
          expect(described_class.search_by_code(scheme_1.code.downcase).first.code).to eq(scheme_1.code)
          expect(described_class.search_by_code(scheme_2.code.upcase).count).to eq(1)
          expect(described_class.search_by_code(scheme_2.code.downcase).count).to eq(1)
          expect(described_class.search_by_code(scheme_2.code.downcase).first.code).to eq(scheme_2.code)
        end
      end

      context "when searching by service name" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by_organisation(organisation.name.upcase).count).to eq(1)
          expect(described_class.search_by_organisation(organisation.name.downcase).count).to eq(1)
          expect(described_class.search_by_organisation(organisation.name.upcase).first.organisation.name).to eq(scheme_1.organisation.name)
          expect(described_class.search_by_organisation(different_organisation.name.upcase).count).to eq(1)
          expect(described_class.search_by_organisation(different_organisation.name.downcase).count).to eq(1)
          expect(described_class.search_by_organisation(different_organisation.name.upcase).first.organisation.name).to eq(scheme_2.organisation.name)
        end
      end
    end
  end
end
