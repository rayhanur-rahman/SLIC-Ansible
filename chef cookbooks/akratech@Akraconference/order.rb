class Order < ActiveRecord::Base

# 	def purchase
#      response = EXPRESS_GATEWAY.purchase(5000, express_purchase_options)
#      response.success?
#   end
#   def express_token=(token)
#       self[:express_token]=token
#       if new_record? && !token.blank?
#         details = EXPRESS_GATEWAY.details_for(token)
#         self.express_payer_id = details.payer_id
#        end
#     end 
#   private 
#     def express_purchase_options {
#       :ip = ip, 
#       :express_payer_id => express_payer_id,
#       :user_id => 1
#     }
#    end
# end


def create
    @order = Order.new(order_params)
    if @order.save
      checkout_paypal(@order)
    else
      render 'new'
    end
  end

  def success
    @order = Order.find(params[:id])
    @order.paypal_payer_id = params[:PayerID] # Paypal return payerid if success. Save it to db
    @order.save
    # Your success code - here & view
  end

  def error
    @order = Order.find(params[:id])
    @s = GATEWAY.details_for(@order.paypal_token) # To get details of payment
    # @s.params['message'] gives you error
  end

  private
    def checkout_paypal
      paypal_response = ::GATEWAY.setup_purchase(
        (order.amount * 100).round, # paypal amount is in cents
        ip: request.remote_ip,
        return_url: success_order_url(order), # return here if payment success
        cancel_return_url: error_order_url(order) # return here if payment failed
      )
      order.paypal_token = paypal_response.token # save paypal token to db
      order.save
      redirect_to ::GATEWAY.redirect_url_for(paypal_response.token) and return  # redirect to paypal for payment
    end


end
