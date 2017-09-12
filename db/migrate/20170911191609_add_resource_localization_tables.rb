class AddResourceLocalizationTables < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do 
        Resource.create_translation_table!({
          :text => :text
        }, {
          :migrate_data => true,
          :remove_source_columns => true
        })
      end
      dir.down do
        Resource.drop_translation_table! :migrate_data => true
      end
    end
  end
end
