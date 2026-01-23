require "rails_helper"

RSpec.describe FiltersHelper do
  describe "#filter_selected?" do
    context "when no filters are selected" do
      it "returns false for all filters" do
        expect(filter_selected?("status", "completed", "lettings_logs")).to be_falsey
        expect(filter_selected?("status", "in_progress", "lettings_logs")).to be_falsey
      end
    end

    context "when the filter is the user filter but session filters is empty" do
      before do
        session[:lettings_logs_filters] = {}.to_json
      end

      context "when looking at the all value" do
        it "returns true if no filters have been set yet" do
          expect(filter_selected?("assigned_to", :all, "lettings_logs")).to be true
          expect(filter_selected?("assigned_to", :you, "lettings_logs")).to be false
          expect(filter_selected?("assigned_to", :specific_user, "lettings_logs")).to be false
        end
      end
    end

    context "when one filter is selected" do
      before do
        session[:lettings_logs_filters] = { "status": "in_progress" }.to_json
      end

      it "returns false for non selected filters" do
        expect(filter_selected?("status", "completed", "lettings_logs")).to be false
      end

      it "returns true for selected filter" do
        expect(filter_selected?("status", "in_progress", "lettings_logs")).to be true
      end
    end

    context "when support user is using the organisation filter" do
      before do
        session[:lettings_logs_filters] = { "owning_organisation": "1" }.to_json
      end

      it "returns true for the parent owning_organisation_select filter" do
        expect(filter_selected?("owning_organisation_select", :specific_org, "lettings_logs")).to be true
        expect(filter_selected?("owning_organisation_select", :all, "lettings_logs")).to be false
      end
    end

    context "when support user has not set the owning_organisation_select filter" do
      before do
        session[:lettings_logs_filters] = {}.to_json
      end

      it "defaults to all organisations" do
        expect(filter_selected?("owning_organisation_select", :all, "lettings_logs")).to be true
        expect(filter_selected?("owning_organisation_select", :specific_org, "lettings_logs")).to be false
      end
    end

    context "when the specific owning organisation filter is not set" do
      before do
        session[:lettings_logs_filters] = { "status" => [""], "years" => [""], "assigned_to" => "all" }.to_json
      end

      it "marks the all options as checked" do
        expect(filter_selected?("owning_organisation_select", :all, "lettings_logs")).to be true
        expect(filter_selected?("owning_organisation_select", :specific_org, "lettings_logs")).to be false
      end
    end
  end

  describe "#any_filter_selected?" do
    let(:filter_type) { "lettings_logs" }
    let(:result) { any_filter_selected?(filter_type) }
    let(:serialised_filters) { filters&.to_json }
    let(:filters) { nil }

    before do
      session[:lettings_logs_filters] = serialised_filters if serialised_filters
    end

    it "returns false if the session contains no filters" do
      expect(result).to be_falsey
    end

    context "when organisation and user are set to all" do
      let(:filters) { { "owning_organisation_select" => "all", "assigned_to" => "all" } }

      it "returns false" do
        expect(result).to be_falsey
      end
    end

    context "when user is set to 'you'" do
      let(:filters) { { "user" => "you" } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when organisation is filtered" do
      let(:filters) { { "organisation" => 2 } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when status is filtered" do
      let(:filters) { { "status" => %w[in_progress] } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when collection year is filtered" do
      let(:filters) { { "years" => %w[2023] } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when the user is currently in a bulk upload journey" do
      let(:filters) { { "bulk_upload_id" => "3456" } }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when a range of filters is applied" do
      let(:filters) do
        {
          "assigned_to" => "all",
          "status" => %w[in_progress completed],
          "years" => [""],
          "organisation" => 2,
        }
      end

      it "returns true" do
        expect(result).to be true
      end
    end
  end

  describe "#selected_option" do
    before do
      session[:lettings_logs_filters] = {}.to_json
    end

    context "when nothing has been selected" do
      it "returns an empty string" do
        expect(selected_option("organisation", "lettings_logs")).to eq("")
      end
    end
  end

  describe "#owning_organisation_filter_options" do
    let(:parent_organisation) { FactoryBot.create(:organisation, name: "Parent organisation") }
    let(:child_organisation) { FactoryBot.create(:organisation, name: "Child organisation") }
    let!(:absorbed_organisation) { FactoryBot.create(:organisation, name: "Absorbed organisation", absorbing_organisation: child_organisation) }

    before do
      FactoryBot.create(:organisation_relationship, parent_organisation:, child_organisation:)
      FactoryBot.create(:organisation, name: "Other organisation", id: 9_999_999)
      user.organisation.reload
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support, organisation: child_organisation) }

      context "when no organisation is selected in the filters" do
        it "returns an empty list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end

      context "when a specific child organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": child_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          ])
        end
      end

      context "when a specific parent organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": parent_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          ])
        end
      end

      context "when a specific absorbed organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": absorbed_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: absorbed_organisation.id, name: "Absorbed organisation"),
          ])
        end
      end

      context "when a specific non related organisation is selected in the filters" do
        let(:unrelated_organisation) { create(:organisation, name: "Unrelated organisation") }

        before do
          session[:lettings_logs_filters] = { "owning_organisation": unrelated_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: unrelated_organisation.id, name: "Unrelated organisation"),
          ])
        end
      end

      context "when a non existing organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": 143_542_542 }.to_json
        end

        it "returns an empty list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end
    end

    context "with a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator, organisation: child_organisation) }

      context "when no organisation is selected in the filters" do
        it "returns an empty list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end

      context "when a specific child organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": child_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          ])
        end
      end

      context "when a specific parent organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": parent_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          ])
        end
      end

      context "when a specific absorbed organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": absorbed_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: absorbed_organisation.id, name: "Absorbed organisation"),
          ])
        end
      end

      context "when a specific non related organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": create(:organisation).id }.to_json
        end

        it "returns an empty list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end

      context "when a non existing organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "owning_organisation": 143_542_542 }.to_json
        end

        it "returns an empty list" do
          expect(owning_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end
    end
  end

  describe "#managing_organisation_filter_options" do
    let(:parent_organisation) { FactoryBot.create(:organisation, name: "Parent organisation") }
    let(:child_organisation) { FactoryBot.create(:organisation, name: "Child organisation") }
    let!(:absorbed_organisation) { FactoryBot.create(:organisation, name: "Absorbed organisation", absorbing_organisation: parent_organisation) }

    before do
      FactoryBot.create(:organisation_relationship, parent_organisation:, child_organisation:)
      FactoryBot.create(:organisation, name: "Other organisation", id: 9_999_999)
      user.organisation.reload
    end

    context "with a support user" do
      let(:user) { FactoryBot.create(:user, :support, organisation: parent_organisation) }

      context "when no organisation is selected in the filters" do
        it "returns an empty list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end

      context "when a specific child organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": child_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          ])
        end
      end

      context "when a specific parent organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": parent_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          ])
        end
      end

      context "when a specific absorbed organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": absorbed_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: absorbed_organisation.id, name: "Absorbed organisation"),
          ])
        end
      end

      context "when a specific non related organisation is selected in the filters" do
        let(:unrelated_organisation) { create(:organisation, name: "Unrelated organisation") }

        before do
          session[:lettings_logs_filters] = { "managing_organisation": unrelated_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: unrelated_organisation.id, name: "Unrelated organisation"),
          ])
        end
      end

      context "when a non existing organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": 143_542_542 }.to_json
        end

        it "returns an empty list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end
    end

    context "with a data coordinator user" do
      let(:user) { FactoryBot.create(:user, :data_coordinator, organisation: parent_organisation) }

      context "when no organisation is selected in the filters" do
        it "returns an empty list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end

      context "when a specific child organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": child_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: child_organisation.id, name: "Child organisation"),
          ])
        end
      end

      context "when a specific parent organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": parent_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: parent_organisation.id, name: "Parent organisation"),
          ])
        end
      end

      context "when a specific absorbed organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": absorbed_organisation.id }.to_json
        end

        it "returns the selected organisation in the list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: absorbed_organisation.id, name: "Absorbed organisation"),
          ])
        end
      end

      context "when a specific non related organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": create(:organisation).id }.to_json
        end

        it "returns an empty list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end

      context "when a non existing organisation is selected in the filters" do
        before do
          session[:lettings_logs_filters] = { "managing_organisation": 143_542_542 }.to_json
        end

        it "returns an empty list" do
          expect(managing_organisation_filter_options(user.reload, "lettings_logs")).to eq([
            OpenStruct.new(id: "", name: "Select an option"),
          ])
        end
      end
    end
  end

  describe "#collection_year_options" do
    context "with 23/24 as the current collection year" do
      before do
        allow(Time).to receive(:now).and_return(Time.zone.local(2023, 5, 1))
      end

      context "and in crossover period" do
        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
        end

        it "has the correct options" do
          expect(collection_year_options).to eq(
            {
              "2023" => "2023 to 2024", "2022" => "2022 to 2023", "2021" => "2021 to 2022"
            },
          )
        end
      end

      context "and not in crossover period" do
        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(false)
        end

        it "has the correct options" do
          expect(collection_year_options).to eq(
            {
              "2023" => "2023 to 2024", "2022" => "2022 to 2023"
            },
          )
        end
      end
    end

    context "with 24/25 as the current collection year" do
      before do
        allow(Time).to receive(:now).and_return(Time.zone.local(2024, 5, 1))
      end

      context "and in crossover period" do
        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
        end

        it "has the correct options" do
          expect(collection_year_options).to eq(
            {
              "2024" => "2024 to 2025", "2023" => "2023 to 2024", "2022" => "2022 to 2023"
            },
          )
        end
      end

      context "and not in crossover period" do
        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(false)
        end

        it "has the correct options" do
          expect(collection_year_options).to eq(
            {
              "2024" => "2024 to 2025", "2023" => "2023 to 2024"
            },
          )
        end

        context "with future form use turned on" do
          before do
            allow(FeatureToggle).to receive(:allow_future_form_use?).and_return(true)
          end

          it "includes next year in the options" do
            expect(collection_year_options).to eq(
              {
                "2025" => "2025 to 2026", "2024" => "2024 to 2025", "2023" => "2023 to 2024"
              },
            )
          end
        end
      end
    end
  end

  describe "#collection_year_radio_options" do
    context "with 23/24 as the current collection year" do
      before do
        allow(Time).to receive(:now).and_return(Time.zone.local(2023, 5, 1))
      end

      context "and in crossover period" do
        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
        end

        it "has the correct options" do
          expect(collection_year_radio_options).to eq(
            {
              "2023" => { label: "2023 to 2024" }, "2022" => { label: "2022 to 2023" }, "2021" => { label: "2021 to 2022" }
            },
          )
        end
      end

      context "and not in crossover period" do
        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(false)
        end

        it "has the correct options" do
          expect(collection_year_radio_options).to eq(
            {
              "2023" => { label: "2023 to 2024" }, "2022" => { label: "2022 to 2023" }
            },
          )
        end
      end
    end

    context "with 24/25 as the current collection year" do
      before do
        allow(Time).to receive(:now).and_return(Time.zone.local(2024, 5, 1))
        Singleton.__init__(FormHandler)
      end

      it "has the correct options" do
        expect(collection_year_radio_options).to eq(
          {
            "2024" => { label: "2024 to 2025" }, "2023" => { label: "2023 to 2024" }, "2022" => { label: "2022 to 2023" }
          },
        )
      end
    end
  end

  describe "#filters_applied_text" do
    let(:filter_type) { "lettings_logs" }
    let(:result) { filters_applied_text(filter_type) }
    let(:serialised_filters) { filters&.to_json }
    let(:filters) { nil }

    before do
      session[:lettings_logs_filters] = serialised_filters if serialised_filters
    end

    context "when no filters are applied" do
      let(:filters) do
        {
          "assigned_to" => "all",
          "status" => [""],
          "years" => [""],
          "organisation_select" => "all",
        }
      end

      it "returns the correct filters count" do
        expect(result).to eq "No filters applied"
      end
    end

    context "when a range of filters is applied" do
      let(:filters) do
        {
          "assigned_to" => "all",
          "status" => %w[in_progress completed],
          "years" => [""],
          "organisation_select" => "specific_org",
          "managing_organisation" => 2,
        }
      end

      it "returns the correct filters count" do
        expect(result).to eq "3 filters applied"
      end
    end
  end

  describe "#show_scheme_managing_org_filter?" do
    context "when support user" do
      let(:user) { create(:user, :support, organisation: create(:organisation, stock_owners: [])) }

      it "returns true" do
        expect(show_scheme_managing_org_filter?(user)).to be true
      end
    end

    context "when not support user" do
      let(:stock_owner1) { create(:organisation) }
      let(:stock_owner2) { create(:organisation) }

      context "when org's stock_owners > 1" do
        let(:user) { create(:user, organisation: create(:organisation, holds_own_stock: false)) }

        before do
          create(
            :organisation_relationship,
            child_organisation: user.organisation,
            parent_organisation: stock_owner1,
          )
          create(
            :organisation_relationship,
            child_organisation: user.organisation,
            parent_organisation: stock_owner2,
          )
        end

        it "returns true" do
          expect(show_scheme_managing_org_filter?(user)).to be true
        end
      end

      context "when org's stock_owners == 1" do
        before do
          create(
            :organisation_relationship,
            child_organisation: user.organisation,
            parent_organisation: stock_owner1,
          )
        end

        context "when holds own stock" do
          let(:user) { create(:user, organisation: create(:organisation, holds_own_stock: true)) }

          it "returns true" do
            expect(show_scheme_managing_org_filter?(user)).to be true
          end
        end

        context "when does not hold own stock" do
          let(:user) { create(:user, organisation: create(:organisation, holds_own_stock: false)) }

          it "returns false" do
            expect(show_scheme_managing_org_filter?(user)).to be false
          end
        end
      end

      context "when org's stock_owners == 0" do
        let(:user) { create(:user) }

        it "returns false" do
          expect(show_scheme_managing_org_filter?(user)).to be false
        end
      end
    end
  end
end
