# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def find_or_create_user(organisation, email, role)
  case role
  when :data_provider
    FactoryBot.create(:user, :if_unique, :data_provider, email:, organisation:, password: ENV["REVIEW_APP_USER_PASSWORD"])
  when :data_coordinator
    FactoryBot.create(:user, :if_unique, :data_coordinator, email:, organisation:, password: ENV["REVIEW_APP_USER_PASSWORD"])
  when :support
    FactoryBot.create(:user, :if_unique, :support, email:, organisation:, password: ENV["REVIEW_APP_USER_PASSWORD"])
  end
end

unless Rails.env.test?
  if LocalAuthority.count.zero?
    la_path = "config/local_authorities_data/initial_local_authorities.csv"
    service = Imports::LocalAuthoritiesService.new(path: la_path)
    service.call
  end

  if LaRentRange.count.zero?
    Dir.glob("config/rent_range_data/*.csv").each do |path|
      start_year = File.basename(path, ".csv")
      service = Imports::RentRangesService.new(start_year:, path:)
      service.call
    end
  end

  if LaSaleRange.count.zero?
    Dir.glob("config/sale_range_data/*.csv").each do |path|
      start_year = File.basename(path, ".csv")
      service = Imports::SaleRangesService.new(start_year:, path:)
      service.call
    end
  end

  all_rent_periods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

  mhclg = FactoryBot.create(
    :organisation,
    :if_unique,
    name: "MHCLG",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
    rent_periods: all_rent_periods,
  )

  if Rails.env.development? || Rails.env.review?
    stock_owner1 = FactoryBot.create(:organisation, :if_unique, :la, :holds_own_stock, name: "Stock Owner 1", rent_periods: all_rent_periods)
    stock_owner2 = FactoryBot.create(:organisation, :if_unique, :la, :holds_own_stock, name: "Stock Owner 2", rent_periods: all_rent_periods.sample(5))
    managing_agent1 = FactoryBot.create(:organisation, :if_unique, :prp, :holds_own_stock, name: "Managing Agent 1 (PRP)", rent_periods: all_rent_periods)
    managing_agent2 = FactoryBot.create(:organisation, :if_unique, :la, :holds_own_stock, name: "Managing Agent 2", rent_periods: all_rent_periods.sample(5))
    standalone_owns_stock = FactoryBot.create(:organisation, :if_unique, :la, :holds_own_stock, name: "Standalone Owns Stock 1 Ltd", rent_periods: all_rent_periods)
    standalone_no_stock = FactoryBot.create(:organisation, :if_unique, :la, :does_not_own_stock, name: "Standalone No Stock 1 Ltd", rent_periods: all_rent_periods)

    OrganisationRelationship.find_or_create_by!(
      parent_organisation: stock_owner1,
      child_organisation: mhclg,
    )
    OrganisationRelationship.find_or_create_by!(
      parent_organisation: stock_owner2,
      child_organisation: mhclg,
    )
    OrganisationRelationship.find_or_create_by!(
      parent_organisation: mhclg,
      child_organisation: managing_agent1,
    )
    OrganisationRelationship.find_or_create_by!(
      parent_organisation: mhclg,
      child_organisation: managing_agent2,
    )

    provider = find_or_create_user(mhclg, "provider@example.com", :data_provider)
    coordinator = find_or_create_user(mhclg, "coordinator@example.com", :data_coordinator)
    support = find_or_create_user(mhclg, "support@example.com", :support)

    stock_owner1_user = find_or_create_user(stock_owner1, "stock_owner1_dpo@example.com", :data_coordinator)
    stock_owner2_user = find_or_create_user(stock_owner2, "stock_owner2_dpo@example.com", :data_coordinator)

    managing_agent1_user = find_or_create_user(managing_agent1, "managing_agent1_dpo@example.com", :data_coordinator)
    managing_agent2_user = find_or_create_user(managing_agent2, "managing_agent2_dpo@example.com", :data_coordinator)

    provider_owner1 = find_or_create_user(standalone_owns_stock, "provider.owner1@example.com", :data_provider)
    coordinator_owner1 = find_or_create_user(standalone_owns_stock, "coordinator.owner1@example.com", :data_coordinator)

    find_or_create_user(standalone_no_stock, "provider.nostock@example.com", :data_provider)
    find_or_create_user(standalone_no_stock, "coordinator.nostock@example.com", :data_coordinator)

    if Scheme.count.zero?
      scheme1 = FactoryBot.create(:scheme, service_name: "Beulahside Care", owning_organisation: mhclg)
      scheme2 = FactoryBot.create(:scheme, service_name: "Abdullahview Point", owning_organisation: mhclg)
      scheme3 = FactoryBot.create(:scheme, :created_now, owning_organisation: mhclg)
      scheme4 = FactoryBot.create(:scheme, owning_organisation: stock_owner1)

      [scheme1, scheme2, scheme3, scheme4].each do |scheme|
        FactoryBot.create(:location, scheme:)
      end
      [scheme2, scheme3].each do |scheme|
        FactoryBot.create_list(:location, 3, scheme:)
      end
    end

    users_with_logs = [provider, coordinator, support, stock_owner1_user, stock_owner2_user, managing_agent1_user, managing_agent2_user, provider_owner1, coordinator_owner1]

    if SalesLog.count.zero?
      users_with_logs.each do |user|
        FactoryBot.create(:sales_log, :shared_ownership_setup_complete, assigned_to: user)
        FactoryBot.create(:sales_log, :discounted_ownership_setup_complete, assigned_to: user)
        FactoryBot.create(:sales_log, :outright_sale_setup_complete, assigned_to: user)
        FactoryBot.create(:sales_log, :completed, assigned_to: user)
      end

      FactoryBot.create(:sales_log, :completed, assigned_to: managing_agent1_user, owning_organisation: mhclg)
      FactoryBot.create(:sales_log, :completed, assigned_to: provider, owning_organisation: stock_owner1)
    end

    if LettingsLog.count.zero?
      users_with_logs.each do |user|
        FactoryBot.create(:lettings_log, :setup_completed, assigned_to: user)
        FactoryBot.create(:lettings_log, :completed, assigned_to: user)
        if user.organisation.owned_schemes.any?
          scheme = user.organisation.owned_schemes.first
          FactoryBot.create(:lettings_log, :setup_completed, :sh, scheme:, location: scheme.locations.first, assigned_to: user)
        end
      end

      FactoryBot.create(:lettings_log, :completed, assigned_to: managing_agent1_user, owning_organisation: mhclg)
      FactoryBot.create(:lettings_log, :completed, assigned_to: provider, owning_organisation: stock_owner1)
    end

    if LocalAuthorityLink.count.zero?
      links_data_paths = ["config/local_authorities_data/local_authority_links_2023.csv", "config/local_authorities_data/local_authority_links_2022.csv"]
      links_data_paths.each do |path|
        service = Imports::LocalAuthorityLinksService.new(path:)
        service.call
      end
    end
  end
end

if LocalAuthority.count.zero?
  path = "config/local_authorities_data/initial_local_authorities.csv"
  service = Imports::LocalAuthoritiesService.new(path:)
  service.call
end
