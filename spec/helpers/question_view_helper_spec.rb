require "rails_helper"

RSpec.describe QuestionViewHelper do
  let(:page_header) { "Some Page Header" }
  let(:conditional) { false }

  describe "caption" do
    subject(:header) { caption(caption_text, page_header, conditional) }

    let(:caption_text) { "Some text" }
    let(:caption_options_hash) { { text: caption_text.html_safe, size: "l" } }

    context "when viewing a page without a header" do
      let(:page_header) { nil }

      it "returns an options hash" do
        expect(header).to eq(caption_options_hash)
      end
    end

    context "when viewing a page with a header" do
      it "returns nil" do
        expect(header).to be_nil
      end
    end

    context "when viewing a conditional question" do
      let(:conditional) { true }

      it "returns nil" do
        expect(header).to be_nil
      end
    end

    context "when viewig a question without a caption" do
      let(:caption_text) { nil }

      it "returns nil" do
        expect(header).to be_nil
      end
    end
  end

  describe "legend" do
    subject(:question_view_helper) { legend(question, page_header, conditional) }

    let(:question) { OpenStruct.new(header: "Some question header") }
    let(:size) { "m" }
    let(:tag) { "div" }
    let(:legend_options_hash) do
      { text: "Some question header".html_safe, size:, tag: }
    end

    context "when viewing a page with a header" do
      it "returns an options hash with a medium question header" do
        expect(question_view_helper).to eq(legend_options_hash)
      end
    end

    context "when viewing a page without a header" do
      let(:page_header) { nil }
      let(:size) { "l" }
      let(:tag) { "h1" }

      it "returns an options hash with a large question header" do
        expect(question_view_helper).to eq(legend_options_hash)
      end
    end

    context "when viewinng a conditional question" do
      let(:conditional) { true }
      let(:tag) { "" }

      it "returns an options hash with a medium question header" do
        expect(question_view_helper).to eq(legend_options_hash)
      end
    end
  end

  describe "#example_date_in_tax_year_of" do
    subject(:result) { example_date_in_tax_year_of(input) }

    context "when called with nil" do
      let(:input) { nil }

      it "returns the current date" do
        expect(result).to eq(Time.zone.today)
      end
    end

    context "when called with a date after April" do
      calendar_year = 2030
      let(:input) { Date.new(calendar_year, 7, 7) }

      it "returns the first of September from that year" do
        expect(result).to eq(Date.new(calendar_year, 9, 1))
      end
    end

    context "when called with a date before April" do
      calendar_year = 2040
      let(:input) { Date.new(calendar_year, 2, 7) }

      it "returns the first of September from the previous year" do
        expect(result).to eq(Date.new(calendar_year - 1, 9, 1))
      end
    end

    context "when called with a date in April after the fifth" do
      calendar_year = 2050
      let(:input) { Date.new(calendar_year, 4, 7) }

      it "returns the first of September from that year" do
        expect(result).to eq(Date.new(calendar_year, 9, 1))
      end
    end

    context "when called with a date in April before the sixth" do
      calendar_year = 2060
      let(:input) { Date.new(calendar_year, 4, 4) }

      it "returns the first of September from the previous year" do
        expect(result).to eq(Date.new(calendar_year - 1, 9, 1))
      end
    end
  end
end
