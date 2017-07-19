module ApplicationHelper
  def full_title(page_title='')
    base_title = 'Set me in app/helpers/application_helper.rb'
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end
end
