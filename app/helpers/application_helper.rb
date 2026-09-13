module ApplicationHelper
  def humanized_datetime(time)
    time&.strftime("%B %-d, %Y")
  end
end
