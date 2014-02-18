require 'mongoid'
require 'mongoid-bcrypt-ruby'

class User
  include Mongoid::Document

  field :email, type: String
  field :password, type: String
  field :hashed_password
  field :salt
  field :permission_level, :type => Integer, :default => 1

  # Relations

  has_many :posts
  has_many :comments

  # Validations
  validates_uniqueness_of :email
  validates_format_of :email, :with => /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i
  validates_presence_of :password
  validates_confirmation_of :password

  #attr_protected :_id, :salt

  attr_accessor :password, :password_confirmation

  def password=(pass)
    @password = pass
    self.salt = User.random_string(10) if !self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  def admin?
    self.permission_level == -1 || self.id == 1
  end

  def site_admin?
    self.id == 1
  end

  def method_missing(m, *args)
    return false
  end

  def self.authenticate(email, pass)
    current_user = where(:email => email).first
    return nil if current_user.nil?
    return current_user if User.encrypt(pass, current_user.salt) == current_user.hashed_password
    nil
  end

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end