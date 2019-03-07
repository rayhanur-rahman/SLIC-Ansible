class SubscriptionsController < ApplicationController

  # def express_checkout
  #   response = EXPRESS_GATEWAY.setup_purchase(5000,
  #     ip: request.remote_ip,
  #     return_url: "http://localhost:4000/orders/success_url",
  #     cancel_return_url: "http://localhost:4000/",
  #     currency: "USD",
  #     allow_guest_checkout: true,
  #     items: [{name: "Order", description: "Order description", quantity: "1", amount: 5000}]
  #   )
  #   redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
  # end

  # def new
  #   @subscription = Subscription.new(:express_token => params[:token])
  # end

  # def success_url
  #   params
  # end

  # def create
  #   @subscription = Order.build_order(order_params)
  #   @subscription.ip = request.remote_ip

  #   if @subscription.save
  #     if @subscription.purchase # this is where we purchase the order. refer to the model method below
  #       redirect_to order_url(@subscription)
  #     else
  #       render :action => "failure"
  #     end
  #   else
  #     render :action => 'new'
  #   end
  # end

  def create
    @subscription = Subscription.new({user_id: params["user_id"], price: params["price"], product_id: params["product_id"]})
    if @subscription.save
      checkout_paypal(@subscription)
    else
      render 'new'
    end
  end

  def success_url
    @subscription = Subscription.find_by(id: params["format"])
    @subscription.paypal_payer_id = params["PayerID"] # Paypal return payerid if success. Save it to db
    @subscription.save
    # Your success code - here & view
  end

  def error_url
    @subscription = Subscription.find_by(id: params[:format])
    @subscription = EXPRESS_GATEWAY.details_for(@subscription.paypal_token) # To get details of payment
    # @s.params['message'] gives you error
  end

  
  private
    def checkout_paypal(subscription)
      paypal_response = EXPRESS_GATEWAY.setup_purchase(
        (subscription.price * 100).round, # paypal amount is in cents
        ip: request.remote_ip,
        return_url: success_url_subscriptions_url(subscription), # return here if payment success
        cancel_return_url: error_url_subscriptions_url(subscription) # return here if payment failed
      )
      subscription.paypal_token = paypal_response.token # save paypal token to db
      subscription.save
      redirect_to EXPRESS_GATEWAY.redirect_url_for(paypal_response.token) and return  # redirect to paypal for payment
    end



end