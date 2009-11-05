# This is an immutable class that represents an item in the user's shopping cart.
class ShoppingCartItem
  attr_reader :id, :type, :name, :current_price
  def initialize(model, user = nil)
    @id = model.id
    @type = model.class.name.underscore.to_sym
    @name = model.cart_name
    @current_price = model.price(user)
  end

  def valid?
    !linked_model.blank?
  end

  def update_price!(price)
    unless @current_price <= price
      @current_price = price
    end
  end

  def current_price_to_cents
    current_price.to_f * 100
  end

  # Get the associated model for this shopping cart item.
  # eg, if #type == :video then a Video is returned.
  # Not cached.
  def linked_model
    model = type.to_s.classify.constantize.find_by_id(id)
    model.readonly! if model
    model
  end
end
