class RemoveCountriesAndStates < ActiveRecord::Migration
  def up
    add_column :spree_addresses, :country_code, :string
    add_column :spree_addresses, :region_code, :string
    add_column :spree_stock_locations, :country_code, :string
    add_column :spree_stock_locations, :region_code, :string
    add_column :spree_zone_members, :country_code, :string
    add_column :spree_zone_members, :region_code, :string

    #TODO: probably a more ActiveRecordy way to do this:
    if ActiveRecord::Base.connection.adapter_name.downcase.include? "mysql"
      execute %{
        update spree_addresses, spree_countries, spree_states
        set spree_addresses.country_code = spree_countries.iso
          , spree_addresses.region_code = spree_states.abbr
        where (spree_addresses.country_id is null or spree_addresses.country_id = spree_countries.id)
          and (spree_addresses.state_id is null or spree_addresses.state_id = spree_states.id);

        update spree_stock_locations, spree_countries, spree_states
        set spree_stock_locations.country_code = spree_countries.iso
          , spree_stock_locations.region_code = spree_states.abbr
        where (spree_stock_locations.country_id is null or spree_stock_locations.country_id = spree_countries.id)
          and (spree_stock_locations.state_id is null or spree_stock_locations.state_id = spree_states.id);

        update spree_zone_members, spree_countries, spree_states
        set spree_zone_members.country_code = spree_countries.iso
        where spree_zone_members.zoneable_type = 'Spree::Country'
          and spree_zone_members.zoneable_id = spree_countries.id;

        update spree_zone_members, spree_countries, spree_states
        set spree_zone_members.country_code = spree_countries.iso
          , spree_zone_members.region_code = spree_states.abbr
        where spree_zone_members.zoneable_type = 'Spree::State'
          and spree_zone_members.zoneable_id = spree_states.id
          and spree_states.country_id = spree_countries.id;
      }
    else
      execute %{
        update spree_addresses
        set country_code = spree_countries.iso
          , region_code = spree_states.abbr
        from spree_countries, spree_states
        where (spree_addresses.country_id is null or spree_addresses.country_id = spree_countries.id)
          and (spree_addresses.state_id is null or spree_addresses.state_id = spree_states.id);

        update spree_stock_locations
        set country_code = spree_countries.iso
          , region_code = spree_states.abbr
        from spree_countries, spree_states
        where (spree_stock_locations.country_id is null or spree_stock_locations.country_id = spree_countries.id)
          and (spree_stock_locations.state_id is null or spree_stock_locations.state_id = spree_states.id);

        update spree_zone_members
        set country_code = spree_countries.iso
        from spree_countries
        where spree_zone_members.zoneable_type = 'Spree::Country'
          and spree_zone_members.zoneable_id = spree_countries.id;

        update spree_zone_members
        set country_code = spree_countries.iso
          , region_code = spree_states.abbr
        from spree_countries, spree_states
        where spree_zone_members.zoneable_type = 'Spree::State'
          and spree_zone_members.zoneable_id = spree_states.id
          and spree_states.country_id = spree_countries.id;
      }
    end

    #TODO: handle when just state name set? does that happen?

    remove_column :spree_addresses, :country_id
    remove_column :spree_addresses, :state_id
    remove_column :spree_addresses, :state_name

    remove_column :spree_stock_locations, :country_id
    remove_column :spree_stock_locations, :state_id
    remove_column :spree_stock_locations, :state_name

    remove_column :spree_zone_members, :zoneable_id
    remove_column :spree_zone_members, :zoneable_type

    drop_table :spree_states
    drop_table :spree_countries
  end

  def down
    #Can't roll back since we probably can't recreate the table data
    raise 'Rolling back this migration not supported.'
  end
end
