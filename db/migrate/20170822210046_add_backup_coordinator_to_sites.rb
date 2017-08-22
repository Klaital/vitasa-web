class AddBackupCoordinatorToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :backup_coordinator_id, :integer
  end
end
