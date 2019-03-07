class AddInvitePriceToInvitations < ActiveRecord::Migration
  def change
  	add_column :invitations, :invite_price, :float
  end
end
