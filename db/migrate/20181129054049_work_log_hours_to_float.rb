class WorkLogHoursToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :work_logs, :hours, :float
  end
end
