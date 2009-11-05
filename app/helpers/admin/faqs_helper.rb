module Admin::FaqsHelper
  def answer_column(faq)
    if params[:action] == 'show'
      h faq.answer
    else
      h(truncate(faq.answer, 47))
    end
    
  end

  def question_column(faq)    
    if params[:action] == 'show'
      h faq.question
    else
      h(truncate(faq.question, 47))
    end
  end  
end
