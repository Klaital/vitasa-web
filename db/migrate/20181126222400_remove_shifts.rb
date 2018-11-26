class RemoveShifts < ActiveRecord::Migration[5.0]
  def change
    drop_table :shifts
    drop_table :signups
  end
end
