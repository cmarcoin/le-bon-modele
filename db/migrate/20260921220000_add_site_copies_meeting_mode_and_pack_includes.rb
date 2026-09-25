class AddSiteCopiesMeetingModeAndPackIncludes < ActiveRecord::Migration[8.1]
  def change
    create_table :site_copies do |t|
      t.string :key, null: false
      t.string :label, null: false
      t.string :group, null: false
      t.text :value, null: false, default: ""

      t.timestamps
    end

    add_index :site_copies, :key, unique: true
    add_index :site_copies, :group

    add_column :packs, :includes_text, :text
    add_column :bookings, :meeting_mode, :string
  end
end
