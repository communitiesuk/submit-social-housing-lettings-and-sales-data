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
    context "coordinator user" do
      let(:user) { FactoryBot.create(:user, :support) }
      let(:page_title) { "Title" }
      let(:item_label) { "label" }
      let(:search_item)  { nil }
      let(:count)  { 1 }

      context "organisation path" do
        let(:path) { "/organisations" }
        let(:page_title) { "Organisations" }

        context "search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title when no search" do
            expect(format_title(path, nil, page_title, user, item_label, count)).to eq(expected_title)
          end
        end

        context "search is present" do
          let(:search_item)  { "foobar" }
          let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

          it "returns expected title when search is present" do
            expect(format_title(path, search_item, page_title, user, item_label, count)).to eq(expected_title)
          end
        end
      end

      context "users path" do
        let(:path) { "/users" }
        let(:page_title) { "Users" }

        context "search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title when no search" do
            expect(format_title(path, nil, page_title, user, item_label, count)).to eq(expected_title)
          end
        end

        context "search is present" do
          let(:search_item)  { "foobar" }
          let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

          it "returns expected title when search is present" do
            expect(format_title(path, search_item, page_title, user, item_label, count)).to eq(expected_title)
          end
        end
      end

      context "logs path" do
        let(:path) { "/logs" }
        let(:page_title) { "Logs" }

        context "search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title when no search" do
            expect(format_title(path, nil, page_title, user, item_label, count)).to eq(expected_title)
          end
        end

        context "search is present" do
          let(:search_item)  { "foobar" }
          let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

          it "returns expected title when search is present" do
            expect(format_title(path, search_item, page_title, user, item_label, count)).to eq(expected_title)
          end
        end
      end
    end
  end
end
