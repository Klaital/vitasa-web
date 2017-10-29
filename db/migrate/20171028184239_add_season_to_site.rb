class AddSeasonToSite < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :season_start, :date
    add_column :sites, :season_end, :date
  end
end
