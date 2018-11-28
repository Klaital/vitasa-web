class ChangeWorkLogFields < ActiveRecord::Migration[5.0]
  def change
    change_table :work_logs do |t|
      t.string :date
      t.integer :hours
    end
    remove_column :work_logs, :start_time, :datetime
    remove_column :work_logs, :end_time, :datetime
  end
end
