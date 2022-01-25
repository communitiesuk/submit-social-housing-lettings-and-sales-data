require "rails_helper"

RSpec.describe QuestionViewHelper do
  let(:page_header) { "Some Page Header" }
  let(:conditional) { false }

  describe "caption" do
    let(:subject) { caption(caption_text, page_header, conditional) }
    let(:caption_text) { "Some text" }
    let(:caption_options_hash) { { text: caption_text.html_safe, size: "l" } }

    context "a page without a header" do
      let(:page_header) { nil }

      it "returns an options hash" do
        expect(subject).to eq(caption_options_hash)
      end
    end

    context "a page with a header" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "a conditional question" do
      let(:conditional) { true }
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "a question without a caption" do
      let(:caption_text) { nil }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe "legend" do
    let(:question) { OpenStruct.new(header: "Some question header") }
    let(:subject) { legend(question, page_header, conditional) }
    let(:size) { "m" }
    let(:tag) { "h2" }
    let(:legend_options_hash) do
      { text: "Some question header".html_safe, size: size, tag: tag }
    end

    context "a page with a header" do
      it "returns an options hash with a medium question header" do
        expect(subject).to eq(legend_options_hash)
      end
    end

    context "a page without a header" do
      let(:page_header) { nil }
      let(:size) { "l" }
      let(:tag) { "h1" }

      it "returns an options hash with a large question header" do
        expect(subject).to eq(legend_options_hash)
      end
    end

    context "a conditional question" do
      let(:conditional) { true }

      it "returns an options hash with a medium question header" do
        expect(subject).to eq(legend_options_hash)
      end
    end
  end
end
