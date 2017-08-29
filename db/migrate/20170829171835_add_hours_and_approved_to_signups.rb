class AddHoursAndApprovedToSignups < ActiveRecord::Migration[5.0]
  def change
    add_column :signups, :hours, :float
    add_column :signups, :approved, :boolean
  end
end
