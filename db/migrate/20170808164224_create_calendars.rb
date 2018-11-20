class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.date :date
      t.time :open
      t.time :close
      t.boolean :is_closed
      t.text :notes
      t.belongs_to :site

      t.timestamps
    end
  end
end
