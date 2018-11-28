class ChangeWorkLogFields < ActiveRecord::Migration[5.0]
  def change
    change_table :work_logs do |t|
      t.timestamps
      t.string :date
      t.integer :hours
    end
    remove_columnt :work_logs, :start_time, :datetime
    remove_columnt :work_logs, :end_time, :datetime
  end
end
