class Admin::ShareUrlsController < Admin::BaseController
  active_scaffold :share_urls do |config|
    config.create.columns.exclude :user
    config.create.columns.exclude :share_url_redirects
  end
end
