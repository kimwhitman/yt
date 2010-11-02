class PurchasesController < ApplicationController
  def show
    @purchase = Purchase.find_by_invoice_no params[:id]
    redirect_to root_url if @purchase.blank?
  end

  def download
    # Receiving a purchase_item id here.
    @purchase_item = PurchaseItem.find(params[:id])
    if @purchase_item.downloadable?
      @download_url = @purchase_item.product.download_url
      unless @download_url.blank?
        @purchase_item.last_downloaded_at = DateTime.now
        @purchase_item.save
        render :action => 'download', :layout => 'download'
        # redirect_to url
      else
        flash[:notice] = "That download is not available at this time; please try again, later."
        redirect_to purchase_url(@purchase_item.purchase)
      end
    else
      flash[:notice] = "That download has expired. Please contact customer support for more information."
      redirect_to purchase_url(@purchase_item.purchase)
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
