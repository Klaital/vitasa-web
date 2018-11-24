class EnableManyCoordinators < ActiveRecord::Migration[5.0]
  def change
    create_table :users_sites, id: false do |t|
      t.belongs_to :site, index: true
      t.belongs_to :user, index: true
    end
  end
end
