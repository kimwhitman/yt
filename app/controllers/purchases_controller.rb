class PurchasesController < ApplicationController
  def show
    @purchase = Purchase.find_by_invoice_no params[:id]
    redirect_to root_url if @purchase.blank?
  end

  def download
    # Receiving a purchase_item id here.
    pi = PurchaseItem.find(params[:id])
    if pi.downloadable?
      url = pi.product.download_url
      unless url.blank?
        pi.last_downloaded_at = DateTime.now
        pi.save
        redirect_to url
      else
        flash[:notice] = "That download is not available at this time; please try again, later."
        redirect_to purchase_url(pi.purchase)
      end
    else
      flash[:notice] = "That download has expired. Please contact customer support for more information."
      redirect_to purchase_url(pi.purchase)
    end
  end

  def test
    # TODO: Remove before production
    Rails.logger.info "Current Purchase Object: #{current_purchase.inspect}"
    Rails.logger.info "Current Purchase Object URL: #{purchase_url(current_purchase)}"
  end

  def reset
    session[:purchase_record] = nil
  end
end
