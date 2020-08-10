module ApplicationHelper
  def prettify_date options={}
    options[:value].first.to_date.to_s(:long) # the value of the field
  end
end
