module UrlHelpers
  def new_post_path
    "/posts/new"
  end

  def link_to(text, path, options = {})
    %Q{<a href='#{path}' class='#{options[:class]}' data-method='#{options[:method]}'>#{text}</a>'}
  end
end