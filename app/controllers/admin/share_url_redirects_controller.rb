class Admin::ShareUrlRedirectsController < Admin::BaseController
  active_scaffold :share_url_redirects do |config|
    config.list.columns = [:share_url_id, :user_id, :remote_ip, :referrer, :domain]
  end
end
