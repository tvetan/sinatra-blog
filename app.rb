require 'sinatra'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'slim'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'builder'
require 'haml'
require 'mongoid'
require 'bcrypt'
require 'sinatra/reloader' if development?
require 'redcarpet'
require 'sinatra/paginate'

require Dir.pwd + '/helpers/url_helpers'
require Dir.pwd + '/helpers/content_helpers'
require Dir.pwd + '/helpers/authorization_helpers'



class BlogApplication < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
  use Rack::Session::Cookie, :key => 'rack.session1', :path => '/', :secret => 'nothingissecretontheinternet'
  SITE_TITLE = "BlogApplication"

  register Sinatra::Paginate
  configure :development do
    enable :sessions
    register Sinatra::Flash
    Mongoid.load!("./mongoid.yml")
    set :environment, 'development'
    set :public, 'public'
    set :views,  'views'
  end

  require Dir.pwd + '/models/comment'
  require Dir.pwd + '/models/post'
  require Dir.pwd + '/models/tag'
  require Dir.pwd + '/models/user'
  Struct.new('Result', :total, :size, :posts)

  helpers UrlHelpers
  helpers ContentHelpers
  helpers AuthorizationHelpers

  helpers do
    def page
      [params[:page].to_i - 1, 0].max
    end
  end

  not_found do
    slim :"404"
  end

  get '/' do
    @posts = Post.all.limit(4).skip(page * 4).sort { |a,b| b.created_at <=> a.created_at }
    @result = Struct::Result.new(Post.count, @posts.count, @posts)
    flash[:error] = 'No posts found.' if @posts.empty?
    @title = "Simple CMS: Page List"
    slim :index
  end

  get '/:permalink' do
    begin
      @post = Post.find_by(permalink: params[:permalink])
    rescue
      pass
    end
    #last_modified @post.updated_at
    cache_control :public, :must_revalidate 
    slim :show
  end

  get '/rss.xml' do
    login_required
    @posts = Post.all
    builder :rss  
  end

  # Posts routes
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
    post.user = current_user
    post.save

    redirect to("#{post.permalink}")
  end

  # User Routes

  get '/user/edit' do
    login_required
    @user = current_user
    slim :user_edit
  end

  put '/user' do
    login_required
    user = current_user
    user.update_attributes(params[:user])
    redirect to("/user/edit")
  end

  # Comment Routes


  post '/comment/new' do
    post = Post.find(params[:postId])

    comment = Comment.new(params[:comment])
    comment.post = post
    comment.user = current_user
    comment.save

    redirect to("#{comment.post.permalink}")
  end

  # Authentication

  get '/logged_in' do
    if session[:user]
      "true"
    else
      "false"
    end
  end

  get '/signup/?' do
    if session[:user]
      redirect '/'
    else
      slim :register
    end
  end

  get '/login/?' do
    if session[:user]
      redirect '/'
    else
      slim :login
    end
  end

  post '/login/?' do
    if user = User.authenticate(params[:email], params[:password])
      session[:user] = user.id

      if Rack.const_defined?('Flash')
        flash[:notice] = "Login successful."
      end

      if session[:return_to]
        redirect_url = session[:return_to]
        session[:return_to] = false
        redirect redirect_url
      else
        redirect '/'
      end
    else
      if Rack.const_defined?('Flash')
        flash[:error] = "The email or password you entered is incorrect."
      end
      redirect '/login'
    end
  end

  get '/logout/?' do
    session[:user] = nil
    if Rack.const_defined?('Flash')
      flash[:notice] = "Logout successful."
    end
    return_to = ( session[:return_to] ? session[:return_to] : '/' )
    redirect return_to
  end

  post '/signup/?' do
    @user = User.create(params[:user])
    puts @user.id.to_s + " "+ @user.password + " " + @user.email
    if not @user.id.nil?
      session[:user] = @user.id
      if Rack.const_defined?('Flash')
        flash[:notice] = "Account created."
      end
      redirect '/'
    else
      if Rack.const_defined?('Flash')
        flash[:error] = "There were some problems creating your account: #{@user.errors}."
      end
      redirect '/signup?'# + hash_to_query_string(params['user'])
    end
  end
end