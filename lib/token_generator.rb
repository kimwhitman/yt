require 'guid'

module TokenGenerator
  def self.included(base)
    base.before_create :set_token
  end
  
  def set_token
    self.token = Guid.new.to_s
  end
  
  module Simple
    TOKEN_LENGTH = 8
    
    def generate_token(length = TOKEN_LENGTH)
      if (temp_token = random_token(length)) and self.class.find_by_token(temp_token).nil?
        self.token = temp_token
      else
        generate_token
      end
    end
    
    def random_token(length = TOKEN_LENGTH)
      characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
      temp_token = ''
      srand
      length.times do
        pos = rand(characters.length)
        temp_token += characters[pos..pos]
      end
      temp_token
    end
  end
end