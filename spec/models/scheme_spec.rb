require "rails_helper"

RSpec.describe Scheme, type: :model do
  describe "#new" do
    let(:scheme) { FactoryBot.create(:scheme) }

    it "belongs to an organisation" do
      expect(scheme.organisation).to be_a(Organisation)
    end

    describe "scopes" do
      let!(:scheme_1) { FactoryBot.create(:scheme) }
      let!(:scheme_2) { FactoryBot.create(:scheme) }

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

      context "when searching by scheme name" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by_service_name(scheme_1.service_name.upcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_1.service_name.downcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_1.service_name.downcase).first.service_name).to eq(scheme_1.service_name)
          expect(described_class.search_by_service_name(scheme_2.service_name.upcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_2.service_name.downcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_2.service_name.downcase).first.service_name).to eq(scheme_2.service_name)
        end
      end

      context "when searching by all searchable field" do
        it "returns case insensitive matching records" do
          expect(described_class.search_by(scheme_1.code.upcase).count).to eq(1)
          expect(described_class.search_by(scheme_1.code.downcase).count).to eq(1)
          expect(described_class.search_by(scheme_1.code.downcase).first.code).to eq(scheme_1.code)
          expect(described_class.search_by_service_name(scheme_2.service_name.upcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_2.service_name.downcase).count).to eq(1)
          expect(described_class.search_by_service_name(scheme_2.service_name.downcase).first.service_name).to eq(scheme_2.service_name)
        end
      end
    end
  end
end
