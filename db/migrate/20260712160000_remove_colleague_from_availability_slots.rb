class RemoveColleagueFromAvailabilitySlots < ActiveRecord::Migration[8.0]
  def change
    remove_column :availability_slots, :colleague_name, :string
    remove_column :availability_slots, :colleague_email, :string
  end
end
