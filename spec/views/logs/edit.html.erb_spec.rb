require "rails_helper"

RSpec.describe "logs/edit.html.erb" do
  before do
    assign(:log, log)
  end

  context "when log is in progress" do
    let(:log) { create(:lettings_log, :in_progress) }

    it "there is no link back to log type root" do
      render

      fragment = Capybara::Node::Simple.new(rendered)

      expect(fragment).not_to have_link(text: "Back to lettings logs", href: "/lettings-logs")
    end
  end

  context "when log is completed" do
    context "when showing a lettings log" do
      let(:log) { create(:lettings_log, :completed) }

      it "has link 'Back to lettings logs'" do
        render

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Back to lettings logs", href: "/lettings-logs")
      end
    end

    context "when showing a sales log" do
      let(:log) { create(:sales_log, :completed) }

      it "has link 'Back to sales logs'" do
        render

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Back to sales logs", href: "/sales-logs")
      end
    end
  end
end
