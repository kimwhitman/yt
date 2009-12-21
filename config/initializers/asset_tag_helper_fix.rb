
module ActionView
  module Helpers #:nodoc:
    module AssetTagHelper
      private
        def compute_asset_host(source)
          if host = ActionController::Base.asset_host
            if host.is_a?(Proc)
              case host.arity
              when 2
                if defined? @controller.request
                  host.call(source, @controller.request)
                else
                  host.call(source, nil)
                end
              else
                host.call(source)
              end
            else
              (host =~ /%d/) ? host % (source.hash % 4) : host
            end
          end
        end

    end
  end
end