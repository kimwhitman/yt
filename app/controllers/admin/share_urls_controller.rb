class Admin::ShareUrlsController < Admin::BaseController
  active_scaffold :share_urls do |config|
    config.columns = [:token, :destination]
    config.create.columns.exclude :user
    config.create.columns.exclude :share_url_redirects
    config.update.columns.exclude :user
    config.update.columns.exclude :share_url_redirects
  end
end
