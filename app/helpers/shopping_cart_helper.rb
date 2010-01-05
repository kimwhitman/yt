module ShoppingCartHelper
  include ActionView::Helpers::NumberHelper
  def update_cart
    shopping_cart = page.context.shopping_cart
    # page.replace_html 'cart_link', "Cart (#{shopping_cart.size})"
    page.replace_html 'header_cart_size', "(#{shopping_cart.size})"
    page.replace_html 'cart_taxes', number_to_currency(shopping_cart.taxes.to_dollars)
    page.replace_html 'cart_subtotal', number_to_currency(shopping_cart.subtotal.to_dollars)
    page.replace_html 'cart_total', number_to_currency(shopping_cart.total.to_dollars)
  end

  def add_video_to_cart_link(text, video, opts = {})
    html_opts = opts.dup
    if !shopping_cart.has_video?(video.id)
      html_opts.reverse_merge! :class => 'button',
        :id => "#{dom_id(video)}_cart",
        :style => 'color:#488a1a;',
        :onmouseover => "this.style.color='#333333';",
        :onmouseout => "this.style.color='#488a1a';"
    else shopping_cart.has_video?(video.id)
      html_opts[:style] = "#{html_opts[:style]};color:#666666;"
      html_opts.reverse_merge! :class => 'button',
        :id => "#{dom_id(video)}_cart",
        :style => 'color:#666666;',
        :onmouseover => "this.style.color='#333333';",
        :onmouseout => "this.style.color='#666666';"
      return link_to "<strong>In Cart</strong>", cart_path, html_opts
    end
    ajax_opts = {
      :url => url_for(:controller => 'shopping_cart', :action => 'add', :id => video.id),
      :method => :put
    }
    link_to_remote text, ajax_opts, html_opts
  end
end
