module UrlHelpers
    def new_todo_path
      "/todos/new"
    end

    def link_to(text, path, options = {})
      %Q{<a href='#{path}' class='#{options[:class]}' data-method='#{options[:method]}'>#{text}</a>'}
    end
end