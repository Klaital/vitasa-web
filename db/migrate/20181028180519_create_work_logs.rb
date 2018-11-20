class CreateWorkLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :work_logs do |t|
      t.integer :user_id
      t.integer :site_id
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :approved, default: false
      
      t.timestamps
    end
  end
end
