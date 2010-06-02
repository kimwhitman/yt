class <<ActiveRecord::Base
  alias_method :[], :find
end