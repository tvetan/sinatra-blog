require 'mongoid'

class Post
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Timestamps

  field :title,   type: String
  field :content, type: String
  field :permalink, type: String, default: -> { make_permalink }

  # Relations
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments

  # Validations
  validates_uniqueness_of :title


  # Helpers
  def make_permalink
    slug
  end

  def slug
   title.downcase.gsub(/\W/,'-').squeeze('-').chomp('-') if title
  end
  
end