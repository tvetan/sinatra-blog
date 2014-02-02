require 'mongoid'
require 'mongoid-bcrypt-ruby'

class User
  include Mongoid::Document

  field :email, type: String
  field :password, type: String

  def authenticate(attempted_password)
    if password == attempted_password
      true
    else
      false
    end
  end
end