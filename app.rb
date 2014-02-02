require 'sinatra'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'slim'
require 'mongoid'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'builder'
require 'warden'

require Dir.pwd + '/helpers/url_helpers'

class BlogApplication < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
  use Rack::Session::Cookie, :key => 'rack.session1', :path => '/', :secret => 'nothingissecretontheinternet'
  SITE_TITLE = "BlogApplication"

  configure :development do
    enable :sessions
    register Sinatra::Flash
    Mongoid.load!("./mongoid.yml")
  end

  require Dir.pwd + '/models/post'
  require Dir.pwd + '/models/tag'
  require Dir.pwd + '/models/user'

  use Warden::Manager do |config|

    config.serialize_into_session{ |user| user.id }

    config.serialize_from_session{ |id| User.find(id) }

    config.scope_defaults :default,

      strategies: [:password],

      action: 'auth/unauthenticated'

    config.failure_app = self
  end

  Warden::Manager.before_failure do |env, opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      return false if params['user'].nil?
      params['user']['email'] || params['user']['password']
    end

    def authenticate!
      user = User.where(email: params['user']['email']).first
      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

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

  # Authentication

  get '/auth/login' do
    erb :login
  end

  get '/auth/register' do
    @user = User.new
    erb :register
  end

  post '/auth/register' do
    user = User.create(params[:user])
    redirect to("/")
  end

  post '/auth/login' do
    env['warden'].authenticate!

    flash[:success] = env['warden'].message

    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    puts "unauthenticated"
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash[:error] = env['warden'].message || "You must log in"
    redirect '/auth/login'
  end

  get '/protected' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    erb :protected
  end
end