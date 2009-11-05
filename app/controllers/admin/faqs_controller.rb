class Admin::FaqsController < Admin::BaseController
  active_scaffold :faq do |config|
    config.columns = [:question, :answer, :faq_category]
    config.columns[:faq_category].form_ui = :select
  end
end
