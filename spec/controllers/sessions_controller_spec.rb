require "rails_helper"

RSpec.describe SessionsController do
  describe "#clear_filters" do
    context "when filter_type is lettings_logs" do
      let(:filter_type) { "lettings_logs" }

      it "clears only lettings filters" do
        session[:lettings_logs_filters] = "{'some_category':'some_filter'}"
        session[:sales_logs_filters] = "{'some_other_category':'some_other_filter'}"

        get :clear_filters, params: { filter_type: }

        expect(session[:lettings_logs_filters]).to eq("{}")
        expect(session[:sales_logs_filters]).to eq("{'some_other_category':'some_other_filter'}")
      end
    end

    context "when filter_type is sales_logs" do
      let(:filter_type) { "sales_logs" }

      it "clears only sales filters" do
        session[:lettings_logs_filters] = "{'some_category':'some_filter'}"
        session[:sales_logs_filters] = "{'some_other_category':'some_other_filter'}"

        get :clear_filters, params: { filter_type: }

        expect(session[:lettings_logs_filters]).to eq("{'some_category':'some_filter'}")
        expect(session[:sales_logs_filters]).to eq("{}")
      end
    end
  end
end
