require 'digest/sha1'

class ShoppingCartController < ApplicationController
  verify :method => :put, :only => [:add]
  verify :method => :delete, :only => [:remove]
  ssl_required :checkout, :confirm_purchase if RAILS_ENV == 'production'

  def show
    @modifying_purchase = params[:confirm_purchase] == 'true'
  end

  def remove
    shopping_cart.remove_video(params[:id])
    if shopping_cart.cart_items.size > 0
      respond_to do |format|
        format.html { redirect_to cart_url }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_url }
        format.js {
          render(:update) do |page|
            page.remove "video_#{params[:id]}"
            page.update_cart
            page.replace_html "wrap", "<h2 style='margin-top: 20px;'>Your shopping cart is empty</h2>"
          end
        }
      end
    end
  end

  def add
    shopping_cart.add_video(params[:id])
    respond_to do |format|
      format.html { redirect_to cart_url }
      format.js
    end
  end

  def checkout
    #skip this step now, go right to confirm purchase
    if request.post?
      current_purchase.reset_credit_card!
      current_purchase.card_expiration = DateTime.parse("#{params[:purchase].delete('card_expiration(2i)')}/#{params[:purchase].delete('card_expiration(1i)')}")
      params[:purchase].delete 'card_expiration(3i)'
      current_purchase.attributes = params[:purchase]

      if current_purchase.valid?
        redirect_to confirm_purchase_url
      end
    end
  end

  def confirm_purchase
    return unless request.post? || request.put?
    current_purchase.reset_credit_card!
  current_purchase.card_expiration = DateTime.parse("#{params[:purchase].delete('card_expiration(2i)')}/#{params[:purchase].delete('card_expiration(1i)')}")
  params[:purchase].delete 'card_expiration(3i)'
  current_purchase.attributes = params[:purchase]
    if current_purchase.valid? && current_purchase.charge_card(shopping_cart)
      empty_cart!
      Rails.logger.info "** #{current_purchase.inspect}"
      destroy_current_purchase!
      empty_cart!
      redirect_to purchase_url(last_purchase)
    else
      flash[:purchase_problem] = current_purchase.gateway_response.message
      redirect_to :action => 'checkout'
    end
  rescue Exception => e
    flash[:purchase_problem] = "<strong>A critical error has occured. Your purchase was not completed. You have not been charged. Please contact <a href='mailto:info@yogatoday.com'>sales@yogatoday.com</a>.</strong>"
    Rails.logger.info "An exception has occured! #{e}\n#{e.backtrace}"
    redirect_to :action => 'checkout'
  end

  def reset
    session[:purchase_record] = nil
    session[:cart_id] = nil
    redirect_to '/'
  end
end
