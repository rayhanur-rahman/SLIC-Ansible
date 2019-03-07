class CreateProducts < ActiveRecord::Migration

  def change
    create_table :products do |t|
    	t.string :name
    	t.float :price
    	t.integer :total_sessions
    	t.float :storage
    	t.string :total_usage
    	t.integer :total_persons
    	t.integer :duration
    end
  end

end

