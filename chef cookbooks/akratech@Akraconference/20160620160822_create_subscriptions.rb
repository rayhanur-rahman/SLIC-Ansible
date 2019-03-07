class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
    	t.integer :user_id
    	t.integer :product_id
    	t.float :price
    	t.string :paypal_token
    	t.string :paypal_payer_id
    	t.datetime :start_date
    	t.datetime :end_date

    	t.timestamps
    end
  end
end
