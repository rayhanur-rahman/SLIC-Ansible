class CreateFgScores < ActiveRecord::Migration
  def change
    create_table :fg_scores do |t|
      t.string :player_guid
      t.integer :level_id
      t.integer :milliseconds

      t.timestamps
    end

    add_index :fg_scores, [:player_guid, :level_id], :unique => true
    add_index :fg_scores, :level_id
  end
end
