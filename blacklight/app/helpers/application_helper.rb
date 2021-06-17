module ApplicationHelper
  def prettify_date options={}
    options[:value].first.to_date.to_s(:long) # the value of the field
  end

  def prettify_price options={}
    #options[:value].first.to_date.to_s(:long) # the value of the field
    ActiveSupport::NumberHelper.number_to_currency(options[:value].first.to_i/100)
  end  
end
