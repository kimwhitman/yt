class Suggestion    
  attr_accessor :title, :content, :video_id

  def initialize(attribs = {})
    @title = attribs[:title]
    @content = attribs[:content]
    @video_id = attribs[:video_id]
    @errors = []
  end
  def valid?
    @errors = []
    unless @title.blank?
      if @title.size > 255
        @errors << "Title must be less than 255 characters."
      end
    end
    if @content.blank?
      @errors << "Content must be present."
    elsif !(0..1000).include?(@content.size)
      @errors << "Content must be less than 1,000 characters."
    end
    return @errors.blank?
  end
  def errors
    @errors.dup
  end
end
