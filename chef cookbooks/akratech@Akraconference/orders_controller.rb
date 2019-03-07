class OrdersController < ApplicationController

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
  #   @order = Order.new(:express_token => params[:token])
  # end

  # def success_url
  #   params
  # end

  # def create
  #   @order = Order.build_order(order_params)
  #   @order.ip = request.remote_ip

  #   if @order.save
  #     if @order.purchase # this is where we purchase the order. refer to the model method below
  #       redirect_to order_url(@order)
  #     else
  #       render :action => "failure"
  #     end
  #   else
  #     render :action => 'new'
  #   end
  # end

  def create
    @order = Order.new({user_id: params["user_id"], price: params["price"]})
    if @order.save
      checkout_paypal(@order)
    else
      render 'new'
    end
  end

  def success_url
    @order = Order.find_by(id: params["format"])
    @order.paypal_payer_id = params["PayerID"] # Paypal return payerid if success. Save it to db
    @order.save
    redirect_to session[:paypal_success_url]
    # Your success code - here & view
  end

  def error_url
    @order = Order.find_by(id: params[:format])
    @s = EXPRESS_GATEWAY.details_for(@order.paypal_token) # To get details of payment
    # @s.params['message'] gives you error
  end

  
  private
    def checkout_paypal(order)
      paypal_response = EXPRESS_GATEWAY.setup_purchase(
        (order.price * 100).round, # paypal amount is in cents
        ip: request.remote_ip,
        return_url: success_url_orders_url(order), # return here if payment success
        cancel_return_url: error_url_orders_url(order) # return here if payment failed
      )
      order.paypal_token = paypal_response.token # save paypal token to db
      order.save
      redirect_to EXPRESS_GATEWAY.redirect_url_for(paypal_response.token) and return  # redirect to paypal for payment
    end



end