require 'sinatra'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'slim'
require 'mongoid'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'builder'

require Dir.pwd + '/helpers/url_helpers'

class BlogApplication < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
  SITE_TITLE = "BlogApplication"

  configure :development do
    enable :sessions
    register Sinatra::Flash
    Mongoid.load!("./mongoid.yml")
  end

  require Dir.pwd + '/models/post'
  require Dir.pwd + '/models/tag'

  helpers UrlHelpers

  get '/' do
    @posts = Post.all
    flash[:error] = 'No posts found.' if @posts.empty?
    @title = "Simple CMS: Page List"
    slim :index
  end

  get '/rss.xml' do
    @posts = Post.all
    builder :rss  
  end

  get '/posts/new' do
    session[:test] = "joro"
    @post = Post.new
    slim :new
  end

  get '/posts/:id/edit' do
    @post = Post.find(params[:id])
    slim :edit
  end

  get '/posts/delete/:id' do
    @post = Post.find(params[:id])
    slim :delete
  end

  delete '/posts/:id' do
    Post.find(params[:id]).destroy
    redirect to('/')
  end

  put '/posts/:id' do
    post = Post.find(params[:id])
    post.update_attributes(params[:post])
    redirect to("/posts/#{post.id}")
  end

  get '/posts/:id' do
    @post = Post.find(params[:id])
    @title = @post.title
    slim :show
  end

  post '/posts' do
     post = Post.create(params[:post])
     redirect to("/posts/#{post.id}")
  end
end