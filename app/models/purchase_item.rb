class PurchaseItem < ActiveRecord::Base
  belongs_to :purchase  
  validates_presence_of :name, :purchase_type, :purchase_id, :price_in_cents, :purchased_item_id
  def downloadable?
    # EAE get rid of last_downloaded_at
    # self.created_at > 10.days.ago && (last_downloaded_at.blank? ? true : last_downloaded_at > 1.hour.ago)
    return self.created_at > 120.days.ago
  end
  def price_in_dollars
    price_in_cents / 100.0
  end
  def product
    case purchase_type
    when 'Video'
      Video.find(purchased_item_id)
    end
  end
end
