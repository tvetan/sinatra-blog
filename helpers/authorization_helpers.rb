module AuthorizationHelpers

  def login_required
    user = current_user
    if user && user.class != GuestUser
      return true
    else
      session[:retur_to] = request.fullpath
      redirect '/login'
      return false
    end
  end
   def current_user
    if session[:user]
      User.where(:id => session[:user]).first
    else
      GuestUser.new
    end
  end

  def logged_in
    !!session[:user]
  end

  class GuestUser
    def guest?
      true
    end

    def permission_level
      0
    end

    # current_user.admin? returns false. current_user.has_a_baby? returns false.
    # (which is a bit of an assumption I suppose)
    def method_missing(m, *args)
      return false
    end
  end

end