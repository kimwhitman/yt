class Cart < ActiveRecord::Base
  belongs_to :user
  has_many :cart_items, :dependent => :destroy

  validates_associated :user, :unless => Proc.new { |c| c.user_id.blank? }
  
  def add_video(video_id)
    video = Video.find_by_id video_id
    cart_items.reload
    return true if cart_items.any? { |ci| ci.product == video }
    cart_items.create :product => video, :product_name => video.title, :amount => Money.new(video.price(user) * 100)
    mark_change!
    true
  end
  def remove_video(video_id)
    cart_items.reload
    ci = cart_items.find_by_product_id_and_product_type video_id, 'Video'
    cart_items.delete(ci) if ci
    mark_change!
    return true
  end
  def has_video?(id)
    video = Video.find_by_id id
    cart_items.reload
    cart_items.any? { |ci| ci.product == video }
  end
  # Get all videos from the shopping cart.
  # by default, only returns valid (model exists) items.
  # call with false to return all items.
  def videos(valid = true)
    cart_items.reload
    items = cart_items.select { |ci| ci.product_type == 'Video' }
    valid ? items.select(&:valid?) : items
  end
  def has_valid_products?
    return true if cart_items.count == 0
    videos.size > 0
  end
  def size
    cart_items.count || 0
  end
  def invalid_cart_items(type = nil)
    cart_items.reload
    if type
      cart_items.select { |item| !item.valid? && item.product_type == type }
    else
      cart_items.select { |item| !item.valid? }
    end
  end
  # Money stuff
  def total
    (taxes + subtotal)
  end
  def subtotal
    videos.inject(Money.new) { |sum, ci| sum += ci.amount } || Money.new
  end
  def taxes
    Money.new 0
  end
  def user=(user)
    write_attribute(:user_id, user.id) if user
    cart_items.reload    
    cart_items.each do |ci|
      # Convert to pennies.
      money = Money.new(ci.product.price(user) * 100)
      (ci.amount = money; ci.save) unless money > ci.amount
    end
  end
  protected
  def mark_change!
    self.last_active_at = DateTime.now
    save
  end
end
