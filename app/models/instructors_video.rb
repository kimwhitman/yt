class InstructorsVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :instructor
end
