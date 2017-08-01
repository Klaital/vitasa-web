class AddIndexesToSiteHits < ActiveRecord::Migration[5.0]
  def change
    add_index :site_hits, :timestamp
    add_index :site_hits, :method
    add_index :site_hits, :path
    add_index :site_hits, :format
    add_index :site_hits, :status
  end
end
