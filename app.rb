require 'sinatra'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'slim'
require 'mongoid'


require Dir.pwd + '/helpers/url_helpers'

class BlogApplication < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets

  configure :development do
    enable :sessions
    Mongoid.load!("./mongoid.yml")
  end
  require Dir.pwd + '/models/post'
  require Dir.pwd + '/models/tag'

  helpers UrlHelpers

  get '/' do
    @tags = Post.all.first.tags
    #@posts1 = Tag.all.first.posts
    @posts = Post.all
    @title = "Simple CMS: Page List"
    slim :index
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