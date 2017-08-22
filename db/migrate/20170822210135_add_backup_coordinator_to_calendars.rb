class AddBackupCoordinatorToCalendars < ActiveRecord::Migration[5.0]
  def change
    add_column :calendars, :backup_coordinator_today, :boolean
  end
end
