class AddEfilersToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :monday_efilers, :integer
    add_column :sites, :tuesday_efilers, :integer
    add_column :sites, :wednesday_efilers, :integer
    add_column :sites, :thursday_efilers, :integer
    add_column :sites, :friday_efilers, :integer
    add_column :sites, :saturday_efilers, :integer
    add_column :sites, :sunday_efilers, :integer

    add_column :calendars, :efilers_needed, :integer
  end
end
