# This class represents the user's shopping cart. Vrrm vrrm!
class ShoppingCart
  attr_reader :token, :user
  def initialize(user = nil)
    @cart_items ||= []
    @user = user
  end
  # Add a video to the shopping cart.
  # We track the current price of the video
  # because if we don't we open up the client
  # to some gnarly bait-and-switch style lawsuits
  # in the event there's a sale / "get it free!"
  # when the user adds the video to their cart,
  # but the sale ends by the time they get to the checkout.
  def add_video(id)
    return false if frozen?
    video = Video.find_by_id(id)
    return false if video.blank?
    return true if cart_items.any? { |item| item.id.to_s == id.to_s }
    @cart_items << ShoppingCartItem.new(video, @user)
    changed!
    true
  end

  # Remove a video from the user cart.
  def remove_video(id)
    return false if frozen?
    @cart_items.delete_if { |item| item.id.to_s == id.to_s && item.type == :video }
    changed!
    true
  end
  
  # Call when updating the prices in a cart. Destructive (you lose the previous video price.
  # Only lowers price (subscribed user logs in, price drop is incurred)
  def update_prices!(user)
    @cart_items.each do |item|
      item.update_price!(item.linked_model.price(user)) if item.valid?
    end
    @user = user
    true
  end
  # Determine if a video exists in the cart.
  def has_video?(id)
    cart_items.any? { |item| item.type == :video && item.id.to_s == id.to_s }
  end
  # Get all videos from the shopping cart.
  # by default, only returns valid (model exists) items.
  # call with false to return all items.
  def videos(valid = true)
    items = cart_items.select { |item| item.type == :video }
    valid ? items.select(&:valid?) : items
  end
  def size
    cart_items.size
  end
  def valid?
    cart_items.all? { |item| item.valid? }
  end
  def empty!
    @cart_items.clear
    unfreeze!
  end
  # only returns invalid cart items of the specified type (nil == all invalid items)
  def invalid_cart_items(type = nil)
    if type
      cart_items.select { |item| !item.valid? && item.type == type }
    else
      cart_items.select { |item| !item.valid? }
    end
  end
  # Returns an Array#dup of the cart_items array.
  # Use the API if you need to add / remove items from the cart.
  def cart_items
    @cart_items.dup # So they can't cart_items#delete_at and etc on the array.
  end
  # This method generates a unique ID that will enable
  # pages to know when the cart is changed.
  # Mainly used for the following scenario:
  # * User gets to confirmation page.
  # * In another window, user adds item to cart.
  # * User goes back to confirmation page (another window) and clicks submit.
  # * Page reloads instead of attempting to process new transaction with
  #   modified amount.
  def changed!
    @token = Digest::SHA1.hexdigest('--#{Time.now.to_s}--#{total}--#{size}')
  end
  
  def freeze!
    @frozen = true
  end
  def unfreeze!
    @frozen = false
  end
  def frozen?
    @frozen ||= false
  end
  # Money-related stuff.
  def total
    (taxes + subtotal).to_f
  end
  def subtotal
    videos.inject(0.00) { |sum, item| sum += item.current_price }.to_f || 0.00
  end
  def taxes
    (0.00).to_f
  end
  def total_to_pennies
    total * 100.0
  end
end
