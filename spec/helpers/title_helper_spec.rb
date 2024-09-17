require "rails_helper"

RSpec.describe TitleHelper do
  describe "#format_label" do
    let(:item) { "organisation" }

    it "returns singular when count is 1" do
      expect(format_label(1, item)).to eq("organisation")
    end

    it "returns plural when count greater than 1" do
      expect(format_label(2, item)).to eq("organisations")
    end
  end

  describe "#format_title" do
    let(:page_title) { "Title" }
    let(:item_label) { "label" }
    let(:search_item)  { nil }
    let(:count) { 1 }
    let(:organisation_name) { nil }

    context "when provider user" do
      let(:user) { FactoryBot.create(:user) }

      context "when any specific path" do
        let(:page_title) { "Users" }
        let(:organisation_name) { nil }

        context "when search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title" do
            expect(format_title(nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title" do
              expect(format_title(search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end
      end
    end

    context "when coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }

      context "when any specific path" do
        let(:page_title) { "Users" }
        let(:organisation_name) { nil }

        context "when search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title" do
            expect(format_title(nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title" do
              expect(format_title(search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end
      end
    end

    context "when support user" do
      let(:user) { FactoryBot.create(:user, :support) }

      context "when no organisation is specified" do
        let(:page_title) { "Organisations" }

        context "when search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title" do
            expect(format_title(nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end
        end

        context "when search is present" do
          let(:search_item) { "foobar" }
          let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

          it "returns expected title" do
            expect(format_title(search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end
        end
      end

      context "when organisation is specified" do
        let(:page_title) { "Organisations" }
        let(:organisation_name) { "Some Name" }

        context "when search is missing" do
          let(:expected_title) { "#{organisation_name} (#{page_title})" }

          it "returns expected title" do
            expect(format_title(nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end
        end

        context "when search is present" do
          let(:search_item) { "foobar" }
          let(:expected_title) { "#{organisation_name} (#{count} #{item_label} matching ‘#{search_item}’)" }

          it "returns expected title" do
            expect(format_title(search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end
        end
      end
    end
  end
end
