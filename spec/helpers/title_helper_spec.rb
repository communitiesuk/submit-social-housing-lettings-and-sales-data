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

    context "when coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }

      context "when specific organisation details path" do
        let(:path) { "organisations/1/details" }
        let(:page_title) { "Organisation details" }
        let(:organisation_name) { nil }

        context "when search is missing" do
          let(:expected_title) { page_title }

          it "returns expected title when no search" do
            expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
          end
        end
      end
    end

    context "when support user" do
      let(:user) { FactoryBot.create(:user, :support) }

      context "when highest level links" do
        context "when organisation path" do
          let(:path) { "/organisations" }
          let(:page_title) { "Organisations" }

          context "when search is missing" do
            let(:expected_title) { page_title }

            it "returns expected title when no search" do
              expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title when search is present" do
              expect(format_title(path, search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end

        context "when users path" do
          let(:path) { "/users" }
          let(:page_title) { "Users" }

          context "when search is missing" do
            let(:expected_title) { page_title }

            it "returns expected title when no search" do
              expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title when search is present" do
              expect(format_title(path, search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end

        context "when logs path" do
          let(:path) { "/logs" }
          let(:page_title) { "Logs" }

          context "when search is missing" do
            let(:expected_title) { page_title }

            it "returns expected title when no search" do
              expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{page_title} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title when search is present" do
              expect(format_title(path, search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end
      end

      context "when sub nav links" do
        context "when specific organisation logs path" do
          let(:path) { "organisations/1/logs" }
          let(:page_title) { "Logs" }
          let(:organisation_name) { "Foo Bar" }

          context "when search is missing" do
            let(:expected_title) { "#{organisation_name} (#{page_title})" }

            it "returns expected title when no search" do
              expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{organisation_name} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title when search is present" do
              expect(format_title(path, search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end

        context "when specific organisation users path" do
          let(:path) { "organisations/1/users" }
          let(:page_title) { "Users" }
          let(:organisation_name) { "Foo Bar" }

          context "when search is missing" do
            let(:expected_title) { "#{organisation_name} (#{page_title})" }

            it "returns expected title when no search" do
              expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{organisation_name} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title when search is present" do
              expect(format_title(path, search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end

        context "when specific organisation details path" do
          let(:path) { "organisations/1/details" }
          let(:page_title) { "Organisation details" }
          let(:organisation_name) { "Foo Bar" }

          context "when search is missing" do
            let(:expected_title) { "#{organisation_name} (#{page_title})" }

            it "returns expected title when no search" do
              expect(format_title(path, nil, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end

          context "when search is present" do
            let(:search_item) { "foobar" }
            let(:expected_title) { "#{organisation_name} (#{count} #{item_label} matching ‘#{search_item}’)" }

            it "returns expected title when search is present" do
              expect(format_title(path, search_item, page_title, user, item_label, count, organisation_name)).to eq(expected_title)
            end
          end
        end
      end
    end
  end
end
