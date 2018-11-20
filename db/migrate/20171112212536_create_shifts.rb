class CreateShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :shifts do |t|
      t.time :start_time
      t.time :end_time
      t.integer :efilers_needed_basic
      t.integer :efilers_needed_advanced
      t.integer :calendar_id
      t.string :day_of_week

      t.timestamps
    end

    remove_column :signups, :site_id, :string
    remove_column :signups, :date, :date
    add_column :signups, :shift_id, :integer
  end
end
