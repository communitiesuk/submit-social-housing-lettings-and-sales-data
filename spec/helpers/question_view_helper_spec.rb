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

    context "when viewing a question without a caption" do
      let(:caption_text) { nil }

      it "returns nil" do
        expect(header).to be_nil
      end
    end
  end

  describe "legend" do
    subject(:question_view_helper) { legend(question, page_header, conditional) }

    let(:question_stub) do
      Struct.new(:header) do
        def question_number_string(_conditional)
          nil
        end

        def plain_label
          nil
        end

        def hide_question_number_on_page
          false
        end
      end
    end

    let(:question) { question_stub.new("Some question header") }
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

    context "when viewing a conditional question" do
      let(:conditional) { true }
      let(:tag) { "" }

      it "returns an options hash with a medium question header" do
        expect(question_view_helper).to eq(legend_options_hash)
      end
    end

    context "when viewing a question with a plain label" do
      let(:question_stub) do
        Struct.new(:header) do
          def question_number_string(_conditional)
            nil
          end

          def plain_label
            true
          end

          def hide_question_number_on_page
            false
          end
        end
      end

      it "returns an options hash with nil size" do
        expect(question_view_helper).to eq({ size: nil, tag: "div", text: "Some question header" })
      end
    end
  end

  describe "select_option_name" do
    context "when value is a location" do
      let(:value) { build(:location)}

      it "returns the location's postcode" do
        expect(select_option_name(value)).to eq(value.postcode)
      end
    end

    context "when value is a hash with a name key" do
      let(:value) { { "name" => "example name" } }

      it "returns the value of the name key" do
        expect(select_option_name(value)).to eq(value["name"])
      end
    end

    context "when value responds to service_name" do
      let(:value) { build(:scheme)}

      it "returns the value of the service_name method" do
        expect(select_option_name(value)).to eq(value.service_name)
      end
    end
  end

  describe "answer_option_hint" do
    context "when not a scheme or location" do
      let(:resource) { { "value" => "not a scheme or location" }}

      it "returns nil" do
        expect(answer_option_hint(resource)).to be_nil
      end
    end

    context "when resource is a scheme" do
      let(:resource) { build(:scheme, primary_client_group: "O", secondary_client_group: "E") }

      it "returns the primary and secondary client groups" do
        expect(answer_option_hint(resource)).to eq("Homeless families with support needs, People with mental health problems")
      end
    end

    context "when resource is a location" do
      let(:resource) { build(:location) }

      it "returns the location's name" do
        expect(answer_option_hint(resource)).to eq(resource.name)
      end
    end
  end
end
