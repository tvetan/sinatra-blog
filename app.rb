require 'sinatra'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'

require Dir.pwd + '/models/post'
require Dir.pwd + '/helpers/url_helpers'

class BlogApplication < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets

  helpers UrlHelpers

  get "/" do
    redirect new_todo_path
  end

  get "/todos/new" do
    #@todos = Todo.all
    erb :index
  end
end