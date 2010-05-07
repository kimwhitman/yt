class Admin::ShareUrlsController < Admin::BaseController
  active_scaffold :share_urls do |config|
    config.list.columns = [:token, :destination]
  end
end
