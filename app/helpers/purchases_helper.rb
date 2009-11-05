module PurchasesHelper
  def download_purchased_item_path(purchase_item)
    purchase_item_path(:invoice_no => purchase_item.purchase.invoice_no, :id => purchase_item.id)
  end
end
